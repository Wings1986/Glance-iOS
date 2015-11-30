//
//  DimeReviewVideoViewController.m
//  TheDime
//
//  Created by Kevin McNeish on 6/27/14.
//  Copyright (c) 2014 Anonoymous - ICN. All rights reserved.
//

#import "DimeReviewVideoViewController.h"

#import "AppDelegate.h"
#import "ShareVC.h"

#import "ChooseCategoryDlg.h"


#import "PBJVideoPlayerController.h"

typedef enum {
    UploadOperationVideo,
    UploadOperationThumbnail,
    UploadOperationAd
} UploadOperation;

typedef enum {
    UploadStatusCancelled = 1,
    UploadStatusSuccessful,
    UploadStatusS3VideoFailed,
    UploadStatusS3ThumbnailFailed,
    UploadStatusDynamoDBFailed
} UploadStatus;

@interface DimeReviewVideoViewController ()<PBJVideoPlayerControllerDelegate, ChooseCategoryDlgDelegate>
{
    
    IBOutlet UIImageView *ivThumbnail;
    IBOutlet UITextField *tfHeadline;
    IBOutlet UIButton *btnChooseTopic;
    
    ChooseCategoryDlg * categoryDlg;
    
    UploadOperation currentUploadOperation;
    NSString *uniqueID;
}

@end

@implementation DimeReviewVideoViewController
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ivThumbnail.image = [self getThumbnail];
    
    PBJVideoPlayerController *videoPlayerController = [[PBJVideoPlayerController alloc] init];
    videoPlayerController.delegate = self;
    videoPlayerController.view.frame = self.view.bounds;
    
    [self addChildViewController:videoPlayerController];
    [self.view insertSubview:videoPlayerController.view atIndex:1];
    [videoPlayerController didMoveToParentViewController:self];
    
    videoPlayerController.videoPath = self.videoPath;
    videoPlayerController.videoFillMode = AVLayerVideoGravityResizeAspectFill;
    
    [videoPlayerController playFromBeginning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"Share"]) {
        ShareVC *dest = (ShareVC*)segue.destinationViewController;
        dest.videoPath = self.videoPath;
        dest.thumbImage = ivThumbnail.image;
        dest.headline = tfHeadline.text;
        dest.category = [btnChooseTopic titleForState:UIControlStateNormal];
        
    }
}


#pragma mark Video Delegate
#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    NSLog(@"Max duration of the video: %f", videoPlayer.maxDuration);
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    if (videoPlayer.playbackState == PBJVideoPlayerPlaybackStatePlaying) {
    }
    else if (videoPlayer.playbackState == PBJVideoPlayerPlaybackStatePaused) {
    }
    
}

- (void)videoPlayerBufferringStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    switch (videoPlayer.bufferingState) {
        case PBJVideoPlayerBufferingStateUnknown:
            NSLog(@"Buffering state unknown!");
            break;
            
        case PBJVideoPlayerBufferingStateReady:
            NSLog(@"Buffering state Ready! Video will start/ready playing now.");
            break;
            
        case PBJVideoPlayerBufferingStateDelayed:
            NSLog(@"Buffering state Delayed! Video will pause/stop playing now.");
            [videoPlayer playFromCurrentTime];
            break;
    }
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    [videoPlayer playFromBeginning];
}


#pragma mark button event
- (IBAction)next:(id)sender {
}

- (IBAction)onChooseCategory:(id)sender {
    
//    categoryDlg = [[ChooseCategoryDlg alloc] initWithNibName:@"ChooseCategoryDlg" bundle:nil];
//    categoryDlg.delegate = self;
//    categoryDlg.mode = MODE_SELECT_ONE;
//    
//    [self presentPopupViewController:categoryDlg animationType:MJPopupViewAnimationFade];
    
    categoryDlg = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseCategoryDlg"];
    categoryDlg.delegate = self;
    categoryDlg.mode = MODE_SELECT_ONE;
    categoryDlg.backImage = [[AppDelegate sharedInstance] getScreencapture];
    [self presentViewController:categoryDlg animated:NO completion:^{
        
    }];

    
}
- (void) chooseCategory:(NSMutableArray*) arrCategory;
{
//    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
//    categoryDlg = nil;

    if (arrCategory.count > 0) {
        [btnChooseTopic setTitle:arrCategory[0] forState:UIControlStateNormal];
    }
    
}
- (IBAction)onClickNext:(id)sender {
    
    if ([[btnChooseTopic titleForState:UIControlStateNormal] containsString:@"Choose"] || [btnChooseTopic titleForState:UIControlStateNormal].length < 1 ) {
        [[AppDelegate sharedInstance] showAlertMessage:@"NOTE" message:@"Please choose a topic"];
        return;
    }
    if (tfHeadline.text.length < 1) {
        [[AppDelegate sharedInstance] showAlertMessage:@"NOTE" message:@"Please input headline"];
        return;
    }
    
    [self performSegueWithIdentifier:@"Share" sender:nil];
}


- (NSString*)documentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSLog(@"%@",paths);
    BOOL isDirectory;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[paths objectAtIndex:0] isDirectory:&isDirectory]) {
        return [paths objectAtIndex:0];
    }else{
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:[paths objectAtIndex:0] withIntermediateDirectories:NO attributes:nil error:nil];
        if (success) {
            return [paths objectAtIndex:0];
        }else{
            return nil;
        }
    }
}

- (UIImage*) getThumbnail{
    // Create a thumbnail from the beginning of the video
    NSURL *url = [NSURL fileURLWithPath:self.videoPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];

//    NSData *imageData = UIImageJPEGRepresentation(thumb, 50);
//    NSString *thumbName = [uniqueID stringByAppendingString:@".jpg"];
    
    return thumb;
}

@end
