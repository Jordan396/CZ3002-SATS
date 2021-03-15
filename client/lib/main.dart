import 'package:flutter/material.dart';
import 'package:sats/start_screen.dart';
import 'package:sats/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SATS Prototype',
      theme: theme(),
      home: StartScreen(),
      // We use routeName so that we dont need to remember the name
      //initialRoute: SplashScreen.routeName,
      //routes: routes,
    );
  }
}
