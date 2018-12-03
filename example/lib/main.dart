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
  String _platformVersion = 'Unknown';

  TextdetectWidget _controller;
  final _width = 200.0;
  final _height = 200.0;

  @override
  void initState() {
    super.initState();
    _controller = TextdetectWidget(_handelTextDetect);
  }

  void _openCamera() {
    var companies = <String, String>{
      "Tourism Holdings Limited": "THL.NZ",
      "Port of Tauranga Limited": "POT.NZ",
      "Metlifecare Limited": "MET.NZ"
    };

    _controller.openCamera(companies).then((String result) {
      print("result:  $result");
    });
  }

  Future<Null> initializeController() async {

    await _controller.initialize(_width, _height);
    var textureId = _controller.textureId;
    print("Texture ID is $textureId");
    setState(() {});
  }

  Future<dynamic> _handelTextDetect(MethodCall call) async {
    switch(call.method) {
      case "detect":
        debugPrint(call.arguments);
        initializeController();
        return new Future.value("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Text Detection Sample'),
        ),
        body: Center(
          child: CupertinoButton(
            onPressed: _openCamera,
            child: _controller.isInitialized
                ? new Texture(textureId: _controller.textureId)
                : Text("Open Camera"),

          )
        ),
      ),
    );
  }
}
