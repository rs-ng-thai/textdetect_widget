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
  @override
  void initState() {
    super.initState();
    companies = <String, String>{
      "Tourism Holdings Limited": "THL.NZ",
      "Port of Tauranga Limited": "POT.NZ",
      "Metlifecare Limited": "MET.NZ"
    };
  }

  Future<dynamic> _handelTextDetect(MethodCall call) async {
    switch(call.method) {
      case "detect":
        debugPrint(call.arguments);
        setState(() {

        });
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('Flutter TextView example')),
            body: Column(children: [
              Center(
                  child: Container(
                      width: 300,
                      height: 500,
                      child: TextdetectWidget(
                        onTextDetectWidgetCreated: _onTextDetectCreated,
                        companies: companies,
                      ))),
              Expanded(
                  flex: 3,
                  child: Container(
                      color: Colors.blue[100],
                      child: Center(child: Text("Hello from Flutter!"))))
            ]))
    );

  }

  void _onTextDetectCreated(TextdetectController controller) {
    textdetectController = controller;
    controller.setHandler(_handelTextDetect);
  }
}
