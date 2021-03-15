///Popup Notification to confirm end session

import 'package:flutter/material.dart';
import 'package:sats/select_loc.dart';
import 'package:sats/start_screen.dart';

Loc session = new Loc();
var classID = session.selectClass();

confirmEndSession(BuildContext context) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {},
  );
  Widget endButton = FlatButton(
    child: Text("End"),
    onPressed: () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => StartScreen()));
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("End Session"),
    content: Text("Would you like end session for class $classID?"),
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
