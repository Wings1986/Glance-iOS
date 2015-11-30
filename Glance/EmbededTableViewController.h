//
//  EmbededTableViewController.h
//  Glance
//

#import <UIKit/UIKit.h>

#import "SVPullToRefresh.h"

#import "BaseFeedViewController.h"

@interface EmbededTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) BaseFeedViewController * parentController;

@property(nonatomic, strong) IBOutlet UITableView * mTableView;
@property (nonatomic, assign) BOOL _loading;


@property (nonatomic, assign) BOOL    m_bMoreLoad;


- (void)startRefresh;
- (void)startMoreLoad;

- (void) disableMoreLoad;
- (void) doneLoadingTableViewData:(NSArray*) arryData;

- (void) setUserInfo:(NSDictionary*) info;
- (void) setNumberOfFollower:(NSNumber*) followers;
- (void) setNumberOfFollowing:(NSNumber*) following;

@end
