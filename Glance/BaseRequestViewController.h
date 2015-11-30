//
//  BaseRequestViewController.h
//  Glance
//

#import <UIKit/UIKit.h>

@interface BaseRequestViewController : UIViewController
{

    IBOutlet UIImageView *imageView;
    
    IBOutlet UIImageView *thumbPhotoView;
    
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *locLabel;
    IBOutlet UILabel *descLabel;
    IBOutlet UILabel *commentsLabel;
    IBOutlet UILabel *likeLabel;
    
    
    IBOutlet UIButton *likeButton;
    IBOutlet UIButton *commentButton;
    
    IBOutlet UIImageView *imgBlurMoreView;
    IBOutlet UIButton *shareButton;
    IBOutlet UIButton *reportButton;
    
    IBOutlet UIView *headlineView;
    IBOutlet UIView *toolView;
    IBOutlet UIView *moreView;

}

@property (nonatomic, strong) NSMutableDictionary * feedItem;

- (void) setInterface;

- (void)userProfile:(UIGestureRecognizer*) gesture;

- (IBAction)onClickComment:(id)sender;
- (IBAction)onClickLikeList:(id)sender;
- (IBAction)onClickShare:(id)sender;
- (IBAction)onClickLike:(id)sender;
- (IBAction)onClickReport:(id)sender;

- (void)onClickMore:(UIGestureRecognizer*) gesture;
    
@end
