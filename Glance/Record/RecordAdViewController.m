//
//  RecordAdViewController.m
//  TheDime
//
//  Created by Kevin McNeish on 6/20/14.
//  Copyright (c) 2014 Anonoymous - ICN. All rights reserved.
//

#import "RecordAdViewController.h"
#import "mmUIViewController.h"
#import "PBJStrobeView.h"
#import "PBJFocusView.h"
#import "PBJVision.h"
#import "PBJVisionUtilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <GLKit/GLKit.h>
#import "UIView+Toast.h"

#import "AppDelegate.h"
#import "DimeReviewVideoViewController.h"

#define VIDEO_LENGTH 18


@interface ExtendedHitButton : UIButton

+ (instancetype)extendedHitButton;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end

@implementation ExtendedHitButton

+ (instancetype)extendedHitButton{
    return (ExtendedHitButton *)[ExtendedHitButton buttonWithType:UIButtonTypeCustom];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect relativeFrame = self.bounds;
    UIEdgeInsets hitTestEdgeInsets = UIEdgeInsetsMake(-35, -35, -35, -35);
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

@end

@interface RecordAdViewController () <UIGestureRecognizerDelegate,PBJVisionDelegate, UIAlertViewDelegate, DimeReviewVideoViewControllerDelegate>{
    __weak IBOutlet UILabel *lblTime;
    __weak IBOutlet UIProgressView *progressView;
    __weak IBOutlet UIButton *nextButton;
    
    __weak IBOutlet UIButton *flipButton;
    __weak IBOutlet UIButton *recordButton;
    __weak IBOutlet UIButton *flashButton;

//    GLKViewController *effectsViewController;
//    PBJStrobeView *strobeView;
//    PBJFocusView *focusView;
    UIView *previewView;
//    UIView *captureDock;
    AVCaptureVideoPreviewLayer *previewLayer;

//    UIButton *doneButton;
    
    UILongPressGestureRecognizer *longPressGestureRecognizer;
//    UITapGestureRecognizer *tapGestureRecognizer;
    ALAssetsLibrary *assetLibrary;

    CFTimeInterval startTime;
    int elapsedSeconds;
    BOOL recording;
    BOOL nextButtonTapped;
    BOOL startedRecording;

}
@end

@implementation RecordAdViewController

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - init

- (void)dealloc
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    longPressGestureRecognizer.delegate = nil;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // preview and AV layer
    previewView = [[UIView alloc] initWithFrame:CGRectZero];
    previewView.backgroundColor = [UIColor blackColor];
    CGRect previewFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    previewView.frame = previewFrame;
    previewLayer = [[PBJVision sharedInstance] previewLayer];
    previewLayer.frame = previewView.bounds;
    NSLog(@"width = %f, height = %f", previewLayer.frame.size.width, previewLayer.frame.size.height);
    
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [previewView.layer addSublayer:previewLayer];

    
    // touch button to record
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
    longPressGestureRecognizer.delegate = self;
    longPressGestureRecognizer.minimumPressDuration = 0.05f;
    longPressGestureRecognizer.allowableMovement = 10.0f;

    [recordButton addGestureRecognizer:longPressGestureRecognizer];
    
 
    PBJVision *vision = [PBJVision sharedInstance];
//    if (!vision.flashAvailable) {
//        flashButton.hidden = YES;
//    }
    if (!vision.supportsVideoCapture) {
        flipButton.hidden = YES;
    }
    
    
    progressView.progressTintColor = THEME_COLOR;
    
    [[progressView layer]setCornerRadius:4.0f];
    [[progressView layer]setBorderWidth:1.0f];
    [[progressView layer]setMasksToBounds:TRUE];
    progressView.clipsToBounds = YES;
    [[progressView layer] setFrame:CGRectMake((self.view.frame.size.width-progressView.frame.size.width)/2, 30, progressView.frame.size.width, 25)];
    [[progressView  layer] setBorderColor:[UIColor whiteColor].CGColor];
    progressView.trackTintColor = [UIColor clearColor];
    
    // Set the maximum recorded video length
    [PBJVision sharedInstance].maximumCaptureDuration = CMTimeMake(VIDEO_LENGTH, 1);
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //tab bar controller setting
//    UIImage* tabBarBackground = [UIImage imageNamed:@"bottom-tab-bar2.png"];
//    [self.tabBarController.tabBar setBackgroundImage:tabBarBackground];
//    [self.tabBarController.tabBar setSelectedImageTintColor:[UIColor colorWithRed:77/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]];
    [self.tabBarController.tabBar setHidden:YES];

    self.videoPath = nil;
    [self resetCapture];
    [[PBJVision sharedInstance] startPreview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];    
    [[PBJVision sharedInstance] stopPreview];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"RecordToReview"]) {
        DimeReviewVideoViewController *rvc = segue.destinationViewController;
        rvc.videoPath = self.videoPath;
        rvc.delegate = self;
    }
}

- (void)retakeVideo
{
    // Delete the temporary video file and clear the reference to it
    [[NSFileManager defaultManager] removeItemAtPath:self.videoPath error:NULL];
    self.videoPath = nil;
}

- (IBAction)close:(id)sender {
    
    if (recording) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Discard Video"
                                                        message: @"If you close the camera your video will be discarded. Are you sure?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // User has chosen to discard the video
        [self cancelRecording];
    }
}

- (void)cancelRecording
{
    [[PBJVision sharedInstance] cancelVideoCapture];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - private start/stop helper methods

- (void)startCapture
{
    startedRecording = YES;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

    } completion:^(BOOL finished) {
    }];
    [[PBJVision sharedInstance] startVideoCapture];
}

- (void)pauseCapture
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

    } completion:^(BOOL finished) {
    }];
    
    [[PBJVision sharedInstance] pauseVideoCapture];
}

- (void)resumeCapture
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

    } completion:^(BOOL finished) {
    }];
    
    [[PBJVision sharedInstance] resumeVideoCapture];
//    effectsViewController.view.hidden = YES;
}

- (void)endCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[PBJVision sharedInstance] endVideoCapture];
//    effectsViewController.view.hidden = YES;
}

- (void)resetCapture
{
//    [strobeView stop];
    longPressGestureRecognizer.enabled = YES;
    
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    
    if ([vision isCameraDeviceAvailable:PBJCameraDeviceBack]) {
        [vision setCameraDevice:PBJCameraDeviceBack];
        flipButton.hidden = NO;
    } else {
        [vision setCameraDevice:PBJCameraDeviceFront];
        flipButton.hidden = YES;
    }
    
    //[vision setCaptureSessionPreset:AVCaptureSessionPreset640x480];
    [vision setCameraMode:PBJCameraModeVideo];
    [vision setCameraOrientation:PBJCameraOrientationPortrait];
    [vision setFocusMode:PBJFocusModeContinuousAutoFocus];
    [vision setOutputFormat:PBJOutputFormatPreset];
    [vision setVideoRenderingEnabled:YES];
    
    // KJM
    recordButton.enabled = YES;
    nextButtonTapped = NO;
    [self setNextButtonEnabled:NO];
    [self resetElapsedTime];
}

- (void)resetElapsedTime
{
    elapsedSeconds = 0;
    lblTime.text = @"00:00";
    progressView.progress = 0;
}

- (void)setNextButtonEnabled:(BOOL)enabled
{
    if (enabled) {
        nextButton.enabled = YES;
        nextButton.alpha = 1;
    }else{
        nextButton.enabled = NO;
        nextButton.alpha = .5;
    }
}

#pragma mark - UIButton
- (IBAction)handleCloseButton:(UIButton*)button{
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)handleFlashButton:(UIButton*)button{
    UIImage *flashImage = [UIImage imageNamed:@"flash-notselected.png"];
    
    if ([PBJVision sharedInstance].flashMode == AVCaptureFlashModeOn) {
        [PBJVision sharedInstance].flashMode = AVCaptureFlashModeOff;
    }else{
        flashImage = [UIImage imageNamed:@"flash-activated.png"];
        [PBJVision sharedInstance].flashMode = AVCaptureFlashModeOn;
    }
    [flashButton setImage:flashImage forState:UIControlStateNormal];
}

- (IBAction)handleFlipButton:(UIButton *)button
{
    PBJVision *vision = [PBJVision sharedInstance];
    if (vision.cameraDevice == PBJCameraDeviceBack) {
        [vision setCameraDevice:PBJCameraDeviceFront];
    } else {
        [vision setCameraDevice:PBJCameraDeviceBack];
    }
}

- (IBAction)handleNextButton:(UIButton *)button
{
    nextButtonTapped = YES;
    // resets long press
    longPressGestureRecognizer.enabled = NO;
    longPressGestureRecognizer.enabled = YES;

//    [self endCapture];
//    [self performSegueWithIdentifier:@"RecordToReview" sender:self];
    
    [self endCapture];
    
//    if (self.videoPath){
//        // Video already saved go to the review scene
//        [self performSegueWithIdentifier:@"RecordToReview" sender:self];
//    }else{
//        // Video not saved yet
//        
//    }
}

#pragma mark - UIGestureRecognizer

- (void)handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [recordButton setImage:[UIImage imageNamed:@"record-button-tap.png"] forState:UIControlStateNormal];
            
            if (!recording)
                [self startCapture];
            else
                [self resumeCapture];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [recordButton setImage:[UIImage imageNamed:@"record-button.png"] forState:UIControlStateNormal];

            [self pauseCapture];
            break;
        }
        default:
            break;
    }
}
/*
- (void)handleFocusTapGesterRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:previewView];
    
    // auto focus is occuring, display focus view
    CGPoint point = tapPoint;
    
    CGRect focusFrame = focusView.frame;
#if defined(__LP64__) && __LP64__
    focusFrame.origin.x = rint(point.x - (focusFrame.size.width * 0.5));
    focusFrame.origin.y = rint(point.y - (focusFrame.size.height * 0.5));
#else
    focusFrame.origin.x = rintf(point.x - (focusFrame.size.width * 0.5f));
    focusFrame.origin.y = rintf(point.y - (focusFrame.size.height * 0.5f));
#endif
    [focusView setFrame:focusFrame];
    
    [previewView addSubview:focusView];
    [focusView startAnimation];
    
    CGPoint adjustPoint = [PBJVisionUtilities convertToPointOfInterestFromViewCoordinates:tapPoint inFrame:previewView.frame];
    [[PBJVision sharedInstance] focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:adjustPoint];
}
*/
#pragma mark - PBJVisionDelegate

// session

- (void)visionSessionWillStart:(PBJVision *)vision
{
}

- (void)visionSessionDidStart:(PBJVision *)vision
{
    if (![previewView superview]) {
        [self.view insertSubview:previewView atIndex:0];
    }
}

- (void)visionSessionDidStop:(PBJVision *)vision
{
    [previewView removeFromSuperview];
}

// preview

- (void)visionSessionDidStartPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did start");
    
}

- (void)visionSessionDidStopPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did stop");
}

// device

- (void)visionCameraDeviceWillChange:(PBJVision *)vision
{
    NSLog(@"Camera device will change");
}

- (void)visionCameraDeviceDidChange:(PBJVision *)vision
{
    NSLog(@"Camera device did change");
}

// mode

- (void)visionCameraModeWillChange:(PBJVision *)vision
{
    NSLog(@"Camera mode will change");
}

- (void)visionCameraModeDidChange:(PBJVision *)vision
{
    NSLog(@"Camera mode did change");
}

// format

- (void)visionOutputFormatWillChange:(PBJVision *)vision
{
    NSLog(@"Output format will change");
}

- (void)visionOutputFormatDidChange:(PBJVision *)vision
{
    NSLog(@"Output format did change");
}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture
{
}

// focus / exposure

- (void)visionWillStartFocus:(PBJVision *)vision
{
}

- (void)visionDidStopFocus:(PBJVision *)vision
{
//    if (focusView && [focusView superview]) {
//        [focusView stopAnimation];
//    }
}

- (void)visionWillChangeExposure:(PBJVision *)vision
{
}

- (void)visionDidChangeExposure:(PBJVision *)vision
{
//    if (focusView && [focusView superview]) {
//        [focusView stopAnimation];
//    }
}

// flash

- (void)visionDidChangeFlashMode:(PBJVision *)vision
{
    NSLog(@"Flash mode did change");
}

// photo

- (void)visionWillCapturePhoto:(PBJVision *)vision
{
}

- (void)visionDidCapturePhoto:(PBJVision *)vision
{
}

- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error
{
}

// video capture

- (void)visionDidStartVideoCapture:(PBJVision *)vision
{
//    [strobeView start];
    recording = YES;
    // KJM
    [self setNextButtonEnabled:YES];
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision
{
//    [strobeView stop];
}

- (void)visionDidResumeVideoCapture:(PBJVision *)vision
{
//    [strobeView start];
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error{
    recording = NO;
    
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }

    recordButton.enabled = NO;
    
    self.videoPath = [videoDict objectForKey:PBJVisionVideoPathKey];

    NSLog(@"video path = %@", self.videoPath);
    
    [self performSegueWithIdentifier:@"RecordToReview" sender:self];
}

// progress

- (void)visionDidCaptureAudioSample:(PBJVision *)vision
{
    //    NSLog(@"captured audio (%f) seconds", vision.capturedAudioSeconds);
}

- (void)visionDidCaptureVideoSample:(PBJVision *)vision
{
    float captureSeconds = vision.capturedVideoSeconds;
    
    int seconds = floor(captureSeconds);
    if (seconds > elapsedSeconds) {
        lblTime.text = [NSString stringWithFormat:@"00:%02d", seconds];
        elapsedSeconds = seconds;
    }
    
    progressView.progress = vision.capturedVideoSeconds / vision.maximumCaptureDuration.value;
}

@end
