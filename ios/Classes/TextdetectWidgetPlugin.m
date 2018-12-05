#import "TextdetectWidgetPlugin.h"
#import "CameraViewController.h"
#import <Firebase/Firebase.h>
#import "FlutterCameraView.h"

@implementation TextdetectWidgetPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FLTWebViewFactory* webviewFactory =
    [[FLTWebViewFactory alloc] initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:webviewFactory withId:@"textdetect_widget"];
    [FIRApp configure];
}
@end
