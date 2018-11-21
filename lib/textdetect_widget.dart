import 'dart:async';

import 'package:flutter/services.dart';

class TextdetectWidget {
  static const MethodChannel _channel =
      const MethodChannel('textdetect_widget');
  static openCamera(List<String> companies) {
    _channel.invokeMethod('openCamera',{"companies":companies});
  }
}
