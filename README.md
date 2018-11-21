# textdetect_widget


A flutter plugin to integrate the Google MLKit for iOS and Android. Live Camera Text Detection is available on current version.

## USAGE

To open camera from device, we need to pass companies list to detect in camera.
```
void _openCamera() {
    var companies = ["Tourism Holdings Limited","Port of Tauranga Limited","Metlifecare Limited"];
    TextdetectWidget.openCamera(companies);
}
```

## 