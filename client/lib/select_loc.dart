import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main_camera.dart';
import 'package:http/http.dart' as http;
import 'package:sats/students.dart';
import 'package:sats/show_initialisation_result.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

void main() {
  runApp(Loc());
}

GlobalKey<FormState> formkey = GlobalKey<FormState>();
final List<String> studList = [];
final List<String> studnameList = [];
final List<String> studimageList = [];
var classId;
String status;

void validate() {
  if (formkey.currentState.validate()) {
    print("Validated");
  } else {
    print("Not Validated");
  }
}

List<String> classList = List<String>();

class Loc extends StatelessWidget {
  // This widget is the root of your application.

  //get class
  selectClass() {
    return classId;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LocPage(),
    );
  }
}

class LocPage extends StatefulWidget {
  LocPage({Key key, this.title}) : super(key: key);

  final String title;

  // void displayClass(){
  //   Firestore firestoreInstance = Firestore.instance;
  //   firestoreInstance.collection("Classes").getDocuments().then((querySnapshot) {
  //     querySnapshot.documents.forEach((result) {
  //       print(result.data);
  //       classList.add(result.data.toString());
  //     });
  //   });}

  @override
  _LocPageState createState() => _LocPageState();
}

class _LocPageState extends State<LocPage> {
  //displayClass();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
            alignment: Alignment.center,
            child: Text("Select Class",
                style: TextStyle(
                  color: Colors.black,
                )),
          ),
        ),
        body: Form(
          child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              children: <Widget>[
                SizedBox(height: 80.0),
                StreamBuilder<QuerySnapshot>(
                    stream:
                        Firestore.instance.collection("Classes").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return new Text("Loading.....");
                      else {
                        List<DropdownMenuItem> classList = [];
                        for (int i = 0;
                            i < snapshot.data.documents.length;
                            i++) {
                          DocumentSnapshot snap = snapshot.data.documents[i];
                          classList.add(
                            DropdownMenuItem(
                              child: Text(
                                snap.documentID,
                              ),
                              value: "${snap.documentID}",
                            ),
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 50.0,
                              width: 200.0,
                              child: DropdownButton(
                                items: classList,
                                onChanged: (classVal) async {
                                  setState(() {
                                    classId = classVal;
                                  });
                                  Firestore.instance
                                      .collection("Classes")
                                      .document(classId)
                                      .get()
                                      .then(
                                    (value) {
                                      value.data['Students'].forEach((result) {
                                        studList.add(result);
                                      });
                                      //print(studList);
                                      for (int i = 0;
                                          i < studList.length;
                                          i++) {
                                        Firestore.instance
                                            .collection("Students")
                                            .document(studList[i])
                                            .get()
                                            .then((value) {
                                          studnameList.add(value.data['Name']);
                                          //print(studnameList);
                                        });
                                        //print(studnameList);

                                      }
                                      for (int i = 0;
                                          i < studList.length;
                                          i++) {
                                        Firestore.instance
                                            .collection("Students")
                                            .document(studList[i])
                                            .get()
                                            .then((value) {
                                          studimageList
                                              .add(value.data['Image']);
                                          //print(studimageList);
                                        });
                                      }
                                    },
                                  );
                                },
                                value: classId,
                                isExpanded: false,
                                hint: new Text(
                                  "Select Class",
                                ),
                              ),
                            )
                          ],
                        );
                      }
                    }),
                // SizedBox(
                //   height: 150.0,
                // ),
                Column(children: <Widget>[
                  RaisedButton(
                      child: Text("Start"),
                      onPressed: () async {
                        if (classId != null) {
                          await initialiseClass();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyHomePage()));
                        } else {
                          show_initialisation_result(context);
                        }
                      })
                ]),
              ]),
        ));
  }

  initialiseClass() async {
    ///adding student details into an array for request body
    List<String> data = [];
    for (int m = 0; m < studList.length; m++) {
      data.add(
          '{"name": "${studnameList[m]}","matric": "${studList[m]}","image": "${studimageList[m]}"}'
              .toString());
      print(data);
    }

    ///sending the POST request - initialise class
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST',
        Uri.parse('http://172.21.148.169:5000/classes/init?class=$classId'));
    request.body = '''{"students": $data}''';
    request.headers.addAll(headers);
    print(request.body);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      print(response.reasonPhrase);
    } else {
      print(response.reasonPhrase);
    }
  }
}
