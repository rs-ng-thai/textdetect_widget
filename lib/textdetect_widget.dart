import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class TextdetectWidget {
  static const MethodChannel _channel =
      const MethodChannel('textdetect_widget');

  TextdetectWidget(Future<dynamic> handler(MethodCall call)) : super() {
    _channel.setMethodCallHandler(handler);
  }

  Future<String> openCamera(Map<String, String> companies) async {
    final String result = await _channel.invokeMethod('openCamera',{"companies":companies});
    return result;
  }

  Future<dynamic> _handelTextDetect(MethodCall call) async {
    switch(call.method) {
      case "detect":
        debugPrint(call.arguments);
        return new Future.value("");
    }
  }
}
