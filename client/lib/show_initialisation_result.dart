///Popup Notification when class is not selected

import 'package:flutter/material.dart';

show_initialisation_result(BuildContext context) {
  // set up the button
  Widget closeButton = FlatButton(
    child: Text("Close"),
    onPressed: () => Navigator.pop(context),
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Error"),
    // Text changes according to result from model
    content: Text(
        "Please select a class"),
    actions: [
      closeButton,
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

Future navigateToSubPage(context, func) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => func));
}