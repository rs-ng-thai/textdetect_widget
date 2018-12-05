# textdetect_widget


A flutter plugin to integrate the Google MLKit for iOS and Android. Live Camera Text Detection is available on current version.

## USAGE

TextdetectWidget is a live camera detection widget which detects companies from camera frame.

```
TextdetectWidget(
   onTextDetectWidgetCreated: _onTextDetectCreated,
   companies: companies,
)))
```

And then add detection handler like below.

```
void _onTextDetectCreated(TextdetectController controller) {
    textdetectController = controller;
    controller.setHandler(_handelTextDetect);
}
```

```
Future<dynamic> _handelTextDetect(MethodCall call) async {
    switch(call.method) {
      case "detect":
        debugPrint(call.arguments);
        setState(() {

        });
    }
    return 0;
}
```
## 