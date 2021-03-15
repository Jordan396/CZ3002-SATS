import 'package:flutter/material.dart';
import 'package:sats/select_loc.dart';

import 'package:sats/size_config.dart';

// This is the best practice
import 'components/default_button.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    //Spacer();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Text("Start Session", style: TextStyle(fontSize: 30)),
        SizedBox(
          width: double.infinity,
          child: RaisedButton(
            //icon: Icon(Icons.add_circle, size: 90, semanticLabel: "Start Session",),
            //tooltip: 'Start Session',
            //icon: Icon(Icons.add_circle, size: 90, semanticLabel: "Start Session",),
            //tooltip: 'Start Session',
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => LocPage()));
            },
          ),
        )
      ],
    );
  }
}

//     return Column(
//       children: [
//         SizedBox(height: SizeConfig.screenHeight * 0.1),
//         Image.asset(
//           "Assets/images/login.png",
//           height: SizeConfig.screenHeight * 0.4, //40%
//         ),
//         SizedBox(height: SizeConfig.screenHeight * 0.1),
//         Padding(
//             padding: new EdgeInsets.all(2.0)),
//         Align(
//           alignment: Alignment.bottomCenter,),
//         SizedBox(
//
//           width: SizeConfig.screenWidth * 0.6,
//           height: SizeConfig.screenHeight * 0.07,
//           child: DefaultButton(
//             text: "Start Session",
//
//             press: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => LocPage()));
//             },
//           ),
//         ),
//
//       ],
//     );
//   }
// }
