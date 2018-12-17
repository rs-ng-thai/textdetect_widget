//
//
#import "CameraViewController.h"
#import "TextdetectWidgetPlugin.h"
#import "UIUtilities.h"
@import AVFoundation;
@import CoreVideo;
#import <Firebase/Firebase.h>
#import <AudioToolbox/AudioToolbox.h>

static NSString *const alertControllerTitle = @"Vision Detectors";
static NSString *const alertControllerMessage = @"Select a detector";
static NSString *const cancelActionTitleText = @"Cancel";
static NSString *const videoDataOutputQueueLabel = @"com.google.firebaseml.visiondetector.VideoDataOutputQueue";
static NSString *const sessionQueueLabel = @"com.google.firebaseml.visiondetector.SessionQueue";
static NSString *const noResultsMessage = @"No Results";
static const CGFloat FIRSmallDotRadius = 4.0;
static const CGFloat FIRconstantScale = 1.0;


@interface CameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    SystemSoundID mySound;
    CIContext *context;
}
@property (nonatomic) BOOL isPaused;
@property (nonatomic) BOOL isFocused;
@property (nonatomic) int focusedId;
@property (nonatomic) bool isUsingFrontCamera;
@property (nonatomic, nonnull) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) FIRVision *vision;
@property (nonatomic) UIView *annotationOverlayView;
@property (nonatomic) UIImageView *previewOverlayView;
@property (nonatomic) UIView *cameraView;
@property (nonatomic) UIImageView *plusImageView;
@property (nonatomic) UIView *focusView;
@property (nonatomic) CMSampleBufferRef lastFrame;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _focusedId = 0;
    _isPaused = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartDetection:) name:@"startDetection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStopDetection:) name:@"stopDetection" object:nil];
     _cameraView = [[UIView alloc] init];
    _cameraView.backgroundColor = UIColor.blackColor;
        [self.view addSubview:_cameraView];
        [_cameraView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.cameraView
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                            attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                            constant:0];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint
                                              constraintWithItem:self.cameraView
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:self.view
                                              attribute:NSLayoutAttributeTop
                                              multiplier:1.0
                                              constant:0];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
                                                  constraintWithItem:self.cameraView
                                                  attribute:NSLayoutAttributeHeight
                                                  relatedBy:NSLayoutRelationEqual
                                                  toItem:self.view
                                                  attribute:NSLayoutAttributeHeight
                                                  multiplier:1.0
                                                  constant:0];
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
                                  constraintWithItem:self.cameraView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                                  attribute:NSLayoutAttributeWidth
                                  multiplier:1.0
                                  constant:0];

        [self.view addConstraint:leftConstraint];
        [self.view addConstraint:widthConstraint];
        [self.view addConstraint:topConstraint];
        [self.view addConstraint:heightConstraint];

    _focusView = [[UIView alloc] init];
    [self.view addSubview:_focusView];
    [_focusView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *_centerConstraint = [NSLayoutConstraint
                                          constraintWithItem:_focusView
                                          attribute:NSLayoutAttributeCenterX
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:self.view
                                          attribute:NSLayoutAttributeCenterX
                                          multiplier:1.0
                                          constant:0];
    NSLayoutConstraint *_topConstraint = [NSLayoutConstraint
                                         constraintWithItem:_focusView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.view
                                         attribute:NSLayoutAttributeTop
                                         multiplier:1.0
                                         constant:200];
    NSLayoutConstraint *_widthConstraint = [NSLayoutConstraint
                                            constraintWithItem:_focusView
                                            attribute:NSLayoutAttributeWidth
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                            attribute:NSLayoutAttributeNotAnAttribute
                                            multiplier:1.0
                                            constant:300];
    NSLayoutConstraint *_heightConstraint = [NSLayoutConstraint
                                           constraintWithItem:_focusView
                                           attribute:NSLayoutAttributeHeight
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:nil
                                           attribute:NSLayoutAttributeNotAnAttribute
                                           multiplier:1.0
                                           constant:60];
    
    [self.view addConstraint:_topConstraint];
    [self.view addConstraint:_centerConstraint];
    [self.view addConstraint:_widthConstraint];
    [self.view addConstraint:_heightConstraint];
    [NSLayoutConstraint activateConstraints:@[_topConstraint,_centerConstraint, widthConstraint,heightConstraint]];
    
    UIImageView* focusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
    NSString* focusPath = [[NSBundle mainBundle] pathForResource:@"flutter_assets/packages/textdetect_widget/asset/focus_camera.png" ofType:nil];
    NSString* plusPath = [[NSBundle mainBundle] pathForResource:@"flutter_assets/packages/textdetect_widget/asset/plus_icon.png" ofType:nil];
    NSURL *focus_url = [NSURL fileURLWithPath:focusPath];
    NSURL *plus_url = [NSURL fileURLWithPath:plusPath];
    UIImage* focusImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:focus_url]];
    UIImage* plusImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:plus_url]];
    focusImageView.image = focusImage;
    _plusImageView = [[UIImageView alloc] initWithFrame:CGRectMake((focusImageView.bounds.size.width - 25) / 2, (focusImageView.bounds.size.height - 25) / 2, 25, 25)];
    _plusImageView.image = plusImage;
    [_focusView addSubview:focusImageView];
    [_focusView addSubview:_plusImageView];
    _focusView.layer.zPosition = 100;
    
    _isUsingFrontCamera = NO;
    _isFocused = NO;
    _captureSession = [[AVCaptureSession alloc] init];
    _sessionQueue = dispatch_queue_create(sessionQueueLabel.UTF8String, nil);
    _vision = [FIRVision vision];
    _previewOverlayView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _previewOverlayView.translatesAutoresizingMaskIntoConstraints = NO;
    _annotationOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
    _annotationOverlayView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addBackButton];
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    [self setUpPreviewOverlayView];
    [self setUpAnnotationOverlayView];
    [self setUpCaptureSessionOutput];
    [self setUpCaptureSessionInput];
}

- (void)didStartDetection:(NSNotification*) notification {
    _isPaused = NO;
}

- (void)didStopDetection:(NSNotification*) notification {
    _isPaused = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        //Your main thread code goes in here
        [self removeDetectionAnnotations];
    });
}

- (void)addBackButton {
    self.title = @"Live Camera Detection";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(onBack)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)onBack {
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startSession];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopSession];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _previewLayer.frame = _cameraView.frame;
}

- (IBAction)switchCamera:(id)sender {
    self.isUsingFrontCamera = !_isUsingFrontCamera;
    [self removeDetectionAnnotations];
    [self setUpCaptureSessionInput];
}

#pragma mark - On-Device Detection
- (void)handleDetection:(FIRVisionText*)result width:(CGFloat)width height:(CGFloat)height{
    for (int i=0; i< self.companies.count; i ++) {
        NSString* company = self.companies.allKeys[i];
        if (![result.text containsString:company]) {
            continue;
        }
        for (FIRVisionTextBlock* block in result.blocks) {
            if (![block.text containsString:company]) {
                continue;
            }
            
            for (FIRVisionTextLine *line in block.lines) {
                if (![line.text containsString:company]) {
                    continue;
                }
                
                CGFloat min = 0,max = 0;
                for (FIRVisionTextElement *element in line.elements) {
                    if ([company containsString:element.text]) {
                        if (min == 0) {
                            min = element.frame.origin.y;
                            max = element.frame.origin.y + element.frame.size.height;
                        }
                        if (min > element.frame.origin.y) {
                            min = element.frame.origin.y;
                        }
                        if (max < element.frame.origin.y + element.frame.size.height) {
                            max = element.frame.origin.y + element.frame.size.height;
                        }
                    }
                }
                CGRect normalizedRect = CGRectMake(line.frame.origin.x / width,  min/ height,  line.frame.size.width / width,  (max - min)/ height);
                CGRect convertedRect = [self->_previewLayer rectForMetadataOutputRectOfInterest:normalizedRect];
                CGRect newRect = CGRectMake(convertedRect.origin.x + convertedRect.size.width / 2 - 40, convertedRect.origin.y, 80, convertedRect.size.height);
                
                UILabel *label = [[UILabel alloc] initWithFrame:newRect];
                label.textColor = UIColor.whiteColor;
                label.text = self->_companies.allValues[i];
                label.adjustsFontSizeToFitWidth = YES;
                [self.annotationOverlayView addSubview:label];
                CGFloat left = (self.view.bounds.size.width - 300) / 2;
                CGFloat right = (self.view.bounds.size.width - 300) / 2 + 300;
                CGFloat top = 200;
                CGFloat bottom = 260;
                if (label.frame.origin.x  > left && label.frame.origin.x + label.frame.size.width < right && label.frame.origin.y > top && label.frame.origin.y + label.frame.size.height < bottom) {
                    [self removeDetectionAnnotations];
                    [self.annotationOverlayView addSubview:label];
                    if (!self.isFocused) {
                        NSLog(@"%@",@"Focused");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.plusImageView setHidden:YES];
                            [UIView animateWithDuration:0.5 animations:^{
                                self->_focusView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                            } completion:^(BOOL finished) {
                                self->_focusView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                            }];
                            NSString* soundPath = [[NSBundle mainBundle] pathForResource:@"flutter_assets/packages/textdetect_widget/asset/detect_sound.mp3" ofType:nil]; AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)([[NSURL alloc] initWithString:soundPath]), &self->mySound);
                            AudioServicesPlaySystemSound(self->mySound);
                            [self.delegate companyDetected:label.text];
                            self.isFocused = YES;
                            self.focusedId = i;
                        });
                    }
                    return;
                } else {
                    if (self.isFocused) {
                        if (self.focusedId == i) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self->_plusImageView setHidden:NO];
                                self.isFocused = NO;
                            });
                        }
                    }
                }
            }
        }
    }
}

- (void)recognizeTextOnDeviceInImage:(FIRVisionImage *)image width:(CGFloat) width height:(CGFloat)height {
    
    FIRVisionTextRecognizer *textRecognizer = [_vision onDeviceTextRecognizer];
    [textRecognizer processImage:image completion:^(FIRVisionText * _Nullable text, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Your main thread code goes in here
            [self removeDetectionAnnotations];
            [self updatePreviewOverlayView];
            if (text == nil) {
                NSLog(@"On-Device text recognizer error: %@", error ? error.localizedDescription : noResultsMessage);
                self.isFocused = false;
                return;
            }
            [self handleDetection:text width:width height:height];
        });
        
        
    }];
}

#pragma mark - Private

- (void)setUpCaptureSessionOutput {
    dispatch_async(_sessionQueue, ^{
        [self->_captureSession beginConfiguration];
        // When performing latency tests to determine ideal capture settings,
        // run the app in 'release' mode to get accurate performance metrics
        self->_captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        output.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
        dispatch_queue_t outputQueue = dispatch_queue_create(videoDataOutputQueueLabel.UTF8String, nil);
        output.alwaysDiscardsLateVideoFrames = YES;
        [output setSampleBufferDelegate:self queue:outputQueue];
        
        if ([self.captureSession canAddOutput:output]) {
            [self.captureSession addOutput:output];
            [self.captureSession commitConfiguration];
        } else {
            NSLog(@"%@", @"Failed to add capture session output.");
        }
    });
}

- (void)setUpCaptureSessionInput {
    dispatch_async(_sessionQueue, ^{
        AVCaptureDevicePosition cameraPosition = self.isUsingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
        AVCaptureDevice *device = [self captureDeviceForPosition:cameraPosition];
        if (device) {
            [self->_captureSession beginConfiguration];
            NSArray<AVCaptureInput *> *currentInputs = self.captureSession.inputs;
            for (AVCaptureInput *input in currentInputs) {
                [self.captureSession removeInput:input];
            }
            NSError *error;
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            if (error) {
                NSLog(@"Failed to create capture device input: %@", error.localizedDescription);
                return;
            } else {
                if ([self.captureSession canAddInput:input]) {
                    [self.captureSession addInput:input];
                } else {
                    NSLog(@"%@", @"Failed to add capture session input.");
                }
            }
            [self.captureSession commitConfiguration];
        } else {
            NSLog(@"Failed to get capture device for camera position: %ld", (long)cameraPosition);
        }
    });
}

- (void)startSession {
    dispatch_async(_sessionQueue, ^{
        [self->_captureSession startRunning];
    });
}

- (void)stopSession {
    dispatch_async(_sessionQueue, ^{
        [self->_captureSession stopRunning];
    });
}

- (void)setUpPreviewOverlayView {
    [_cameraView addSubview:_previewOverlayView];
    
    [NSLayoutConstraint activateConstraints:@[
                                              [_previewOverlayView.topAnchor constraintEqualToAnchor:_cameraView.topAnchor],
                                               [_previewOverlayView.leadingAnchor constraintEqualToAnchor:_cameraView.leadingAnchor],
                                              [_previewOverlayView.trailingAnchor constraintEqualToAnchor:_cameraView.trailingAnchor],
                                              [_previewOverlayView.bottomAnchor constraintEqualToAnchor:_cameraView.bottomAnchor]
                                              ]];
}
- (void)setUpAnnotationOverlayView {
    [_cameraView addSubview:_annotationOverlayView];
    [NSLayoutConstraint activateConstraints:@[
                                              [_annotationOverlayView.topAnchor constraintEqualToAnchor:_cameraView.topAnchor],
                                              [_annotationOverlayView.leadingAnchor constraintEqualToAnchor:_cameraView.leadingAnchor],
                                              [_annotationOverlayView.trailingAnchor constraintEqualToAnchor:_cameraView.trailingAnchor],
                                              [_annotationOverlayView.bottomAnchor constraintEqualToAnchor:_cameraView.bottomAnchor]
                                              ]];
}

- (AVCaptureDevice *)captureDeviceForPosition:(AVCaptureDevicePosition)position  {
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                                                                                               mediaType:AVMediaTypeVideo
                                                                                                                position:AVCaptureDevicePositionUnspecified];
    for (AVCaptureDevice *device in discoverySession.devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (void)removeDetectionAnnotations {
    for (UIView *annotationView in _annotationOverlayView.subviews) {
        [annotationView removeFromSuperview];
    }
}

- (void)updatePreviewOverlayView {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(_lastFrame);
    if (imageBuffer == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
        if (context == nil) {
            context = [[CIContext alloc] initWithOptions:nil];
        }
        CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];
        if (cgImage == nil) {
            return;
        }
        UIImage *rotatedImage = [UIImage imageWithCGImage:cgImage scale:FIRconstantScale orientation:UIImageOrientationRight];
        if (_isUsingFrontCamera) {
            CGImageRef rotatedCGImage = rotatedImage.CGImage;
            if (rotatedCGImage == nil) {
                return;
            }
            UIImage *mirroredImage = [UIImage imageWithCGImage:rotatedCGImage scale:FIRconstantScale orientation:UIImageOrientationLeftMirrored];
            _previewOverlayView.image = mirroredImage;
        } else {
            _previewOverlayView.image = rotatedImage;
        }
        CGImageRelease( cgImage );
    });
    
    
    
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%@",@"Did Receive Memory warning");
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (imageBuffer) {
        _lastFrame = sampleBuffer;
        FIRVisionImage *visionImage = [[FIRVisionImage alloc] initWithBuffer:sampleBuffer];
        FIRVisionImageMetadata *metadata = [[FIRVisionImageMetadata alloc] init];
        UIImageOrientation orientation = [UIUtilities imageOrientationFromDevicePosition:_isUsingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack];
        FIRVisionDetectorImageOrientation visionOrientation = [UIUtilities visionImageOrientationFromImageOrientation:orientation];
        metadata.orientation = visionOrientation;
        visionImage.metadata = metadata;
        CGFloat imageWidth = CVPixelBufferGetWidth(imageBuffer);
        CGFloat imageHeight = CVPixelBufferGetHeight(imageBuffer);
        if (!_isPaused) {
            
            [self recognizeTextOnDeviceInImage:visionImage width:imageWidth height:imageHeight];
        }
    } else {
        NSLog(@"%@", @"Failed to get image buffer from sample buffer.");
    }
}
@end
