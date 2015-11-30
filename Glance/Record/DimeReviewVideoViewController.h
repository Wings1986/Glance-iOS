//
//  DimeReviewVideoViewController.h
//
//

#import "ReviewVideoViewController.h"


@protocol DimeReviewVideoViewControllerDelegate <NSObject>

- (void)retakeVideo;

@end


@interface DimeReviewVideoViewController : UIViewController

@property (strong, nonatomic) NSString *videoPath;

@property (nonatomic, weak) id <DimeReviewVideoViewControllerDelegate> delegate;

@end
