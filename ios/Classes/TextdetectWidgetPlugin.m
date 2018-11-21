#import "TextdetectWidgetPlugin.h"
#import "CameraViewController.h"
#import <Firebase/Firebase.h>
@implementation TextdetectWidgetPlugin{
    FlutterResult flutterResult;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"textdetect_widget"
            binaryMessenger:[registrar messenger]];
  TextdetectWidgetPlugin* instance = [[TextdetectWidgetPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  [FIRApp configure];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"openCamera" isEqualToString:call.method]) {
        NSArray* companies = (NSArray*)call.arguments[@"companies"];
        [self openCameraResult:result companies:companies];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

-(void)openCameraResult:(FlutterResult) result companies:(NSArray*)companies{
    flutterResult = result;
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    CameraViewController* cameraVC = [CameraViewController new];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:cameraVC];
    cameraVC.companies = companies;
    [vc presentViewController:navController animated:true completion:nil];
}

@end
