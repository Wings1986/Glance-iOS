//
//  ExplorePageVC.m
//  Glance
//
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import "ExplorePageVC.h"


#import "NSDate+TimeAgo.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "VideoPlayerVC.h"

#import "UIImage+Blur.h"
#import "AppDelegate.h"

@interface ExplorePageVC ()
{
    
    IBOutlet UIActivityIndicatorView *loading;
    
}
@end

@implementation ExplorePageVC

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.clipsToBounds = YES;
//    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-66);
    
    [self setInterface];
    [self showDetail:YES];
    
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

- (void) setInterface
{
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
    
    
    //main photo
    loading.hidden = NO;
    [loading startAnimating];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[self.feedItem[@"thumbnail"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                      placeholderImage:nil
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 loading.hidden = YES;
                                 [loading stopAnimating];
                             }
     ];
    
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo:)]];
    
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
        thumbPhotoView.alpha = show ? 1.0f : 0.0f;
        nameLabel.alpha = show ? 1.0f : 0.0f;
        timeLabel.alpha = show ? 1.0f : 0.0f;
        headlineView.alpha = show ? 1.0f : 0.0f;
        
        commentButton.alpha = show ? 1.0f : 0.0f;
        commentsLabel.alpha = show ? 1.0f : 0.0f;
        
    } completion:^(BOOL finished) {
        thumbPhotoView.hidden = !show;
        nameLabel.hidden = !show;
        timeLabel.hidden = !show;
        headlineView.hidden = !show;
        
        commentButton.hidden = !show;
        commentsLabel.hidden = !show;
        
    }];
    
}

- (void)playVideo:(UIGestureRecognizer*) gesture{
    
    VideoPlayerVC * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayerVC"];
    vc.feedItem = self.feedItem;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
    


@end
