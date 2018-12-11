import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:textdetect_widget/textdetect_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Map<String, String> companies;
  TextdetectController textdetectController;
  String tickerString;

  @override
  void initState() {
    super.initState();
    companies = <String, String>{
      "Telstra Corporation Limited": "THL.NZ",
      "Pacific Edge Limited": "POT.NZ",
      "Trade Me Limited and Serko Limited": "MET.NZ"
    };
//    for (int i=0;i<500;i++) {
//      companies["companyname_$i"] = "comapny_`$i";
//    }
  }

  Future<dynamic> _handelTextDetect(MethodCall call) async {
    switch(call.method) {
      case "detect":
        debugPrint(call.arguments);
        setState(() {
          tickerString = call.arguments;
        });
        break;
      case "moveout":
        debugPrint(call.arguments);
        setState(() {
          tickerString = "Move out";
        });
        break;
      default:
        break;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Stack(
              alignment: FractionalOffset.center,
              children: <Widget>[
                TextdetectWidget(
                  onTextDetectWidgetCreated: _onTextDetectCreated,
                  companies: companies,
                ),
                Text(
                  tickerString != null ? tickerString : '',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 60.0
                  ),
                )
              ],
            )
        )
    );

  }

  void _onTextDetectCreated(TextdetectController controller) {
    textdetectController = controller;
    controller.setHandler(_handelTextDetect);
  }
}
