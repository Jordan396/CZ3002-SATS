import 'package:flutter/material.dart';
import 'package:sats/start_session.dart';
import 'package:sats/size_config.dart';

class StartScreen extends StatelessWidget {
  static String routeName = "/splash";
  @override
  Widget build(BuildContext context) {
    // You have to call it on your starting screen
    SizeConfig().init(context);
    return Scaffold(
      body: Body(),
    );
  }
}
