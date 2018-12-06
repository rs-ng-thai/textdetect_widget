//
//  CameraViewController.h
//  Pods-Runner
//
//  Created by ll on 2018/11/19.
//

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>
NS_ASSUME_NONNULL_BEGIN

@protocol CompanyDetectDelegate <NSObject>
@optional
- (void)companyDetected:(NSString*)nickname;
- (void)companyMovedOut:(NSString*)nickname;
@end

@interface CameraViewController : UIViewController <FlutterTextureRegistry>

@property (nonatomic, retain) NSDictionary* companies;
@property (nonatomic, weak) id<CompanyDetectDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
