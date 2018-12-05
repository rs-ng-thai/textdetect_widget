//
//  FlutterCameraView.m
//  FirebaseCore
//
//  Created by ll on 2018/12/5.
//

#import "FlutterCameraView.h"
#import "CameraViewController.h"
@implementation FLTWebViewFactory {
    NSObject<FlutterBinaryMessenger>* _messenger;
}
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        _messenger = messenger;
    }
    return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
    FlutterCameraView* flutterCameraView =
    [[FlutterCameraView alloc] initWithWithFrame:frame
                                     viewIdentifier:viewId
                                          arguments:args
                                    binaryMessenger:_messenger];
    return flutterCameraView;
}

@end


@implementation FlutterCameraView{
    int64_t _viewId;
    FlutterMethodChannel* _channel;
    NSDictionary* companies;
}
- (instancetype)initWithWithFrame:(CGRect)frame
                   viewIdentifier:(int64_t)viewId
                        arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    if ([super init]) {
        _viewId = viewId;
        companies = (NSDictionary*)args;
        NSString* channelName = [NSString stringWithFormat:@"textdetect_widget_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
    }
    return self;
}

- (UIView*)view {
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    CameraViewController* cameraVC = [CameraViewController new];
    cameraVC.companies = companies;
    cameraVC.delegate = self;
    [vc addChildViewController:cameraVC];
    UIView* view = [[UIView alloc] init];
    [view addSubview:cameraVC.view];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint
                                            constraintWithItem:cameraVC.view
                                            attribute:NSLayoutAttributeBottom
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:view
                                            attribute:NSLayoutAttributeBottom
                                            multiplier:1.0
                                            constant:0];
    NSLayoutConstraint *_topConstraint = [NSLayoutConstraint
                                          constraintWithItem:cameraVC.view
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:view
                                          attribute:NSLayoutAttributeTop
                                          multiplier:1.0
                                          constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint
                                          constraintWithItem:cameraVC.view
                                          attribute:NSLayoutAttributeLeft
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:view
                                          attribute:NSLayoutAttributeLeft
                                          multiplier:1.0
                                          constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint
                                           constraintWithItem:cameraVC.view
                                           attribute:NSLayoutAttributeRight
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:view
                                           attribute:NSLayoutAttributeRight
                                           multiplier:1.0
                                           constant:0];
    [cameraVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addConstraint:_topConstraint];
    [view addConstraint:bottomConstraint];
    [view addConstraint:leftConstraint];
    [view addConstraint:rightConstraint];
    [NSLayoutConstraint activateConstraints:@[_topConstraint,bottomConstraint, leftConstraint,rightConstraint]];
    return view;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([[call method] isEqualToString:@"openCamera"]) {
        
    } else if ([[call method] isEqualToString:@"hideFocus"]) {
        NSLog(@"%@","Success");
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)companyDetected:(NSString *)nickname {
    [_channel invokeMethod:@"detect" arguments:nickname];
}

@end
