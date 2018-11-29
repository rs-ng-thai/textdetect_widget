import 'dart:async';

import 'package:flutter/services.dart';

class TextdetectWidget {
  static const MethodChannel _channel =
      const MethodChannel('textdetect_widget');
  static Future<String> openCamera(Map<String, String> companies) async {
    final String result = await _channel.invokeMethod('openCamera',{"companies":companies});
    return result;
  }
}
