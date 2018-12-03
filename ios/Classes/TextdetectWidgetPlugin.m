#import "TextdetectWidgetPlugin.h"
#import "CameraViewController.h"
#import <Firebase/Firebase.h>

FlutterMethodChannel* channel;
@implementation TextdetectWidgetPlugin{
    FlutterResult flutterResult;
    CameraViewController* cameraVC;
}

- (instancetype)initWithTextures:(NSObject<FlutterTextureRegistry> *)textures {
    self = [super init];
    if (self) {
        _textures = textures;
    }
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel
      methodChannelWithName:@"textdetect_widget"
            binaryMessenger:[registrar messenger]];
  TextdetectWidgetPlugin* instance = [[TextdetectWidgetPlugin alloc] initWithTextures:[registrar textures]];
  
  [registrar addMethodCallDelegate:instance channel:channel];
  [FIRApp configure];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"create" isEqualToString:call.method]) {
//        CGFloat width = [call.arguments[@"width"] floatValue];
//        CGFloat height = [call.arguments[@"height"] floatValue];
        NSInteger __block textureId;
//        UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
//        id<FlutterTextureRegistry> __weak registry = self.textures;
//        textureId = [self.textures registerTexture:vc];
        result(@(textureId));
    }
    if ([@"openCamera" isEqualToString:call.method]) {
        NSDictionary* companies = (NSDictionary*)call.arguments[@"companies"];
        [self openCameraResult:result companies:companies];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

-(void)openCameraResult:(FlutterResult) result companies:(NSDictionary*)companies{
    flutterResult = result;
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
     cameraVC = [CameraViewController new];
//    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:cameraVC];
    cameraVC.companies = companies;
    [vc addChildViewController:cameraVC];
    [vc.view addSubview:cameraVC.view];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint
                                              constraintWithItem:cameraVC.view
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:vc.view
                                              attribute:NSLayoutAttributeBottom
                                              multiplier:1.0
                                              constant:0];
        NSLayoutConstraint *_topConstraint = [NSLayoutConstraint
                                             constraintWithItem:cameraVC.view
                                             attribute:NSLayoutAttributeTop
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:vc.view
                                             attribute:NSLayoutAttributeTop
                                             multiplier:1.0
                                             constant:80];
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint
                                                constraintWithItem:cameraVC.view
                                                attribute:NSLayoutAttributeLeft
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:vc.view
                                                attribute:NSLayoutAttributeLeft
                                                multiplier:1.0
                                                constant:0];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint
                                               constraintWithItem:cameraVC.view
                                               attribute:NSLayoutAttributeRight
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:vc.view
                                               attribute:NSLayoutAttributeRight
                                               multiplier:1.0
                                               constant:0];
//    [vc presentViewController:navController animated:true completion:nil];
    [cameraVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [vc.view addConstraint:_topConstraint];
    [vc.view addConstraint:bottomConstraint];
    [vc.view addConstraint:leftConstraint];
    [vc.view addConstraint:rightConstraint];
    [NSLayoutConstraint activateConstraints:@[_topConstraint,bottomConstraint, leftConstraint,rightConstraint]];
}

@end
