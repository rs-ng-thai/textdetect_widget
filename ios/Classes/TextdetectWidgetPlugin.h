#import <Flutter/Flutter.h>
@interface TextdetectWidgetPlugin : NSObject<FlutterPlugin>

@property (nonatomic, strong) NSObject<FlutterTextureRegistry> *textures;

@end

extern FlutterMethodChannel* channel;
