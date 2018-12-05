import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef void TextdetectWidgetCreatedCallback(TextdetectController controller);

class TextdetectWidget extends StatefulWidget {
  const TextdetectWidget({
    Key key,
    this.onTextDetectWidgetCreated,
    this.companies,
  }) : super(key: key);

  final TextdetectWidgetCreatedCallback onTextDetectWidgetCreated;
  final Map<String, String> companies;
  @override
  TextdetectWidgetState createState() => new TextdetectWidgetState();
}

class TextdetectController {

  TextdetectController._(int id)
      : _channel = new MethodChannel('textdetect_widget_$id');

  final MethodChannel _channel;

  setHandler(Future<dynamic> handler(MethodCall call)) {
    _channel.setMethodCallHandler(handler);
  }

  hideFocus() async {
    await _channel.invokeMethod('hideFocus');
  }

}
class TextdetectWidgetState extends State<TextdetectWidget> with WidgetsBindingObserver{

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'textdetect_widget',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: widget.companies,
        creationParamsCodec: new StandardMessageCodec(),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: "textdetect_widget",
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: widget.companies,
        creationParamsCodec: new StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the text_view plugin');
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onTextDetectWidgetCreated == null) {
      return;
    }
    widget.onTextDetectWidgetCreated(new TextdetectController._(id));
  }
}

