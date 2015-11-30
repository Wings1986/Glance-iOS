//
//  FollowerVC.h
//  Glance
//

#import "BaseTableViewController.h"

typedef enum
{
    USER_LIKES = 0,
    USER_FOLLOWER,
    USER_FOLLOWING
} MODEVC;

@interface FollowerVC : BaseTableViewController

@property (nonatomic, strong) NSString* userID;
@property (nonatomic, strong) UIImage * backImage;
@property (nonatomic, assign) MODEVC mode;

@end
