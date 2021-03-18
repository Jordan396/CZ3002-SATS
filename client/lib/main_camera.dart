import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pats/service.dart';
import 'package:pats/select_loc.dart';
import 'package:http/http.dart' as http;
import 'package:pats/start_screen.dart';
import 'package:pats/end_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

String line, result, matric;
var status;
Loc session = new Loc();
var classID = session.selectClass();
var matricList = new List(10);
int o = 0, num=0;


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  Loc session = new Loc();
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new Container(),
        title: Text("SATS",
            style: TextStyle(
            color: Colors.black,
        )),
        centerTitle: true,
        actions: <Widget>[

          IconButton(
            icon: Icon(Icons.indeterminate_check_box),
            tooltip: "End Session",
            onPressed: () async{
              confirmEndSession(context);
              //await endSession();
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.25,
                child: FutureBuilder(
                  future: _getImage(context),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Text('Please wait');
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');
                        else {
                          return selectedImage != null
                              ? Image.file(selectedImage)
                              : Center(
                            child: Text("Please Get the Image"),
                          );
                        }
                    }
                  },
                ),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[500])),
              ),
            ],
          ),
          SizedBox(height: 20,),
          RaisedButton(
            onPressed: () async{
              setState(() async{
                await getImage();
                await submitSubscription();
                show_attendance_result(context);
                print(classID);
              });
          },
            child: Icon(Icons.add_a_photo),
          )
        ],
      ),
      /*floatingActionButton: RaisedButton(
        onPressed: () async{
          await getImage();
          await submitSubscription();
          show_attendance_result(context);
        },
        child: Icon(Icons.add_a_photo),

      ),*/
    );
  }

  Future getImage() async {
    PickedFile image = await ImagePicker().getImage(source: ImageSource.camera);

    setState(() {
      if (image != null) {
        //print(image.path);
        selectedImage = File(image.path);
        print(selectedImage.path);
      } else {
        print('No image.');
      }
    });
    //selectedImage = image;
    //});
    //return image;
  }

  ///upload image to server
  submitSubscription()async{
    classID = await session.selectClass();

    print(classID);
    ///MultiPart request
    var request = http.MultipartRequest('POST', Uri.parse('http://172.21.148.169:5000/attendance/submit?class=$classID'));

    Map<String,String> headers={
      "Content-type": "multipart/form-data"
    };
    request.files.add(await http.MultipartFile.fromPath('image', selectedImage.path));
    //request.files.add(await http.MultipartFile.fromPath('image', 'assets\U1922030E.jpeg'));

    request.headers.addAll(headers);
    /*request.fields.addAll({
      "class":"test",
      //"email":"test@gmail.com",
      //"id":"12345"
    });*/

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      //print(await response.stream.bytesToString());
      line = await response.stream.bytesToString();
      print(line);
      status = line.contains("true");
      print(status);
      if(status == true){ //matching photos
        matric = line.substring(33,42);
        print(matric);
        result = "Attendance Taken. Thank you.";
        await Firestore.instance.collection('Attendance')
            .document(classID)
            .updateData({matric: true})
            .then((value) => print("Attendance Updated"))
            .catchError((error) => print("Failed to update attendance: $error"));
      }
      else{
        result = "Not found.";
      }
      if(matric != null) {
        matricList[o] = matric;
        print(matricList);
        o++;
        num++;
        matric = null;
      }


    }
    else {
      print(response.reasonPhrase);
      print(response.statusCode);
    }
  }
  ///End Class Session
  endSession() async {
    print(classID);
    o=0;
    var request = http.Request('POST', Uri.parse('http://172.21.148.169:5000/classes/terminate?class=$classID'));

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      /*for(int j=0; j<num; j++){
        Firestore.instance.collection('Attendance')
            .document(classID)
            .updateData({matricList[j]: false})
            .then((value) => print("Session Ended"));
        //.catchError((error) => print("Failed to update attendance: $error"));
      }*/
      matricList = new List(10);
    }
    else {
      print(response.reasonPhrase);
    }

  }

  ///Popup Notification to confirm whether attendance is taken
  show_attendance_result(BuildContext context) {
    // set up the button
    /*Widget closeButton = FlatButton(
      child: Text("Close"),
      onPressed: () => Navigator.pop(context),
    );*/
    Future.delayed(Duration(milliseconds: 1300), () {
      Navigator.of(context).pop(true);
    });
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Attendance Result"),
      // Text changes according to result from model
      content: Text(
          result),
      /*actions: [
        closeButton,
      ],*/
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future navigateToSubPage(context, func) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => func));
  }

  //resize the image
  Future<void> _getImage(BuildContext context) async {
    if (selectedImage != null) {
      var imageFile = selectedImage;
      /*var image = imageLib.decodeImage(imageFile.readAsBytesSync());
      fileName = basename(imageFile.path);
      image = imageLib.copyResize(image,
          width: (MediaQuery.of(context).size.width * 0.8).toInt(),
          height: (MediaQuery.of(context).size.height * 0.7).toInt());
      _image = image;*/
    }
  }

  ///Popup Notification to confirm end session
  confirmEndSession(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop(true);
      },
    );
    Widget endButton = FlatButton(
      child: Text("End"),
      onPressed:  () {
        endSession();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StartScreen()));
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("End Session"),
      content: Text("Would you like end session?"),
      actions: [
        cancelButton,
        endButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
