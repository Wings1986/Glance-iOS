//
//  VideoPlayerVC.m
//  Glance
//

#import "VideoPlayerVC.h"

#import "PBJVideoPlayerController.h"

#import "NSDate+TimeAgo.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import <AVFoundation/AVAnimation.h>

#import "URBAlertView.h"
#import "UIImage+Blur.h"


@interface VideoPlayerVC ()<PBJVideoPlayerControllerDelegate, UIGestureRecognizerDelegate>
{

    IBOutlet UIImageView *nameOverlayImage;

}

@end

@implementation VideoPlayerVC

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tabBarController.tabBar setHidden:YES];
    
    [self setInterface];
    [self showDetail:NO];
    
    if (self.feedItem[@"video"] == nil || [self.feedItem[@"video"] isEqualToString:@""]) {
        [self showDlg:@"NOTE" message:@"Video file error\nTry again later"];
        return;
    }

//    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    PBJVideoPlayerController *videoPlayerController = [[PBJVideoPlayerController alloc] init];
    videoPlayerController.delegate = self;
    videoPlayerController.view.frame = self.view.bounds;
    
    [self addChildViewController:videoPlayerController];
//    [self.view addSubview:videoPlayerController.view];
    [self.view insertSubview:videoPlayerController.view atIndex:0];
    [videoPlayerController didMoveToParentViewController:self];
    
    videoPlayerController.videoPath = self.feedItem[@"video"];
    videoPlayerController.videoFillMode = AVLayerVideoGravityResizeAspectFill;
    
    [videoPlayerController playFromBeginning];
    
    UISwipeGestureRecognizer *downSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    downSwipeGestureRecognizer.delaysTouchesEnded = YES;
    downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    downSwipeGestureRecognizer.delegate = self;
    [videoPlayerController.view addGestureRecognizer:downSwipeGestureRecognizer];
    
    
    [videoPlayerController.view addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onClickMore:)]];


}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)handleSwipes:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionDown
        && gesture.state == UIGestureRecognizerStateEnded) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }

}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (void) setInterface
{
    imageView.image = self.imgThumb;
    imageView.hidden = NO;
    
    thumbPhotoView.layer.borderColor = [UIColor whiteColor].CGColor;
    thumbPhotoView.layer.borderWidth = 3;
    thumbPhotoView.layer.cornerRadius = thumbPhotoView.frame.size.height/2.0f;
    thumbPhotoView.clipsToBounds = YES;
    
    [thumbPhotoView sd_setImageWithURL:[NSURL URLWithString:[self.feedItem[@"user"][@"avatar"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                             placeholderImage:[UIImage imageNamed:@"my_avatar_icon.png"]];
    
    [thumbPhotoView setUserInteractionEnabled:YES];
    [thumbPhotoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfile:)]];
    
    
    
    nameLabel.text = self.feedItem[@"user"][@"username"];
    nameLabel.userInteractionEnabled = YES;
    [nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfile:)]];
    
    
    // days ago
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS"]; //2015-04-07T06:24:30.225935
    NSDate *dateFromString = [dateFormatter dateFromString:self.feedItem[@"created_datetime"]];
    timeLabel.text = [dateFromString dateTimeAgo];
    
    locLabel.text = [NSString stringWithFormat:@"%@, %@", self.feedItem[@"city"][@"pretty_name"], self.feedItem[@"city"][@"country_code"]];
    
    
    descLabel.text = [self.feedItem objectForKey:@"headline"];
    
    commentsLabel.text = [[self.feedItem objectForKey:@"comments"] stringValue];
    likeLabel.text = [[self.feedItem objectForKey:@"likes"] stringValue];
    
    [likeButton setImage:[UIImage imageNamed:@"like-button.png"] forState:UIControlStateNormal];
    if (self.feedItem[@"didlike"] != nil && ![self.feedItem[@"didlike"] isKindOfClass:[NSNull class]]) {
        if ([self.feedItem[@"didlike"] boolValue]) {
            [likeButton setImage:[UIImage imageNamed:@"like-button-tapped.png"] forState:UIControlStateNormal];
        }
    }
}

- (void) showDetail:(BOOL) show
{
    nameOverlayImage.alpha = show ? 1.0f : 0.0f;
    nameOverlayImage.hidden = !show;
    thumbPhotoView.alpha = show ? 1.0f : 0.0f;
    thumbPhotoView.hidden = !show;
    nameLabel.alpha = show ? 1.0f : 0.0f;
    nameLabel.hidden = !show;
    timeLabel.alpha = show ? 1.0f : 0.0f;
    timeLabel.hidden = !show;
    headlineView.alpha = show ? 1.0f : 0.0f;
    headlineView.hidden = !show;
    
    commentButton.alpha = show ? 1.0f : 0.0f;
    commentButton.hidden = !show;
    commentsLabel.alpha = show ? 1.0f : 0.0f;
    commentsLabel.hidden = !show;
    
    
    [UIView animateWithDuration:0.5f animations:^{
        nameOverlayImage.alpha = show ? 1.0f : 0.0f;
        thumbPhotoView.alpha = show ? 1.0f : 0.0f;
        nameLabel.alpha = show ? 1.0f : 0.0f;
        timeLabel.alpha = show ? 1.0f : 0.0f;
        headlineView.alpha = show ? 1.0f : 0.0f;
        
        commentButton.alpha = show ? 1.0f : 0.0f;
        commentsLabel.alpha = show ? 1.0f : 0.0f;
        
    } completion:^(BOOL finished) {
        nameOverlayImage.hidden = !show;
        thumbPhotoView.hidden = !show;
        nameLabel.hidden = !show;
        timeLabel.hidden = !show;
        headlineView.hidden = !show;
        
        commentButton.hidden = !show;
        commentsLabel.hidden = !show;
        
    }];
    
}


#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    NSLog(@"Max duration of the video: %f", videoPlayer.maxDuration);
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
//    PBJVideoPlayerPlaybackStateStopped = 0,
//    PBJVideoPlayerPlaybackStatePlaying,
//    PBJVideoPlayerPlaybackStatePaused,
//    PBJVideoPlayerPlaybackStateFailed,
    
    if (videoPlayer.playbackState == PBJVideoPlayerPlaybackStatePlaying) {
        [self showDetail:NO];
    }
    else if (videoPlayer.playbackState == PBJVideoPlayerPlaybackStatePaused) {
        [self showDetail:YES];
    }
    
}

- (void)videoPlayerBufferringStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    switch (videoPlayer.bufferingState) {
        case PBJVideoPlayerBufferingStateUnknown:{
            NSLog(@"Buffering state unknown!");
            
            [self showDlg:@"NOTE" message:@"Buffering error\nTry again later"];
        }

     break;
     
     case PBJVideoPlayerBufferingStateReady:
            NSLog(@"Buffering state Ready! Video will start/ready playing now.");

            imageView.hidden = YES;
            
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
    // when end video playing
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//    }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) showDlg:(NSString*) title message:(NSString*) msg
{
    URBAlertView* alertView = [[URBAlertView alloc] initWithTitle:title message:msg cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        
        [alertView hideWithCompletionBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationFade];

}
@end
