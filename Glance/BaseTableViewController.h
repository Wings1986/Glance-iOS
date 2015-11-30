//
//  BaseTableViewController.h
//  Glance
//

#import <UIKit/UIKit.h>

#import "SVPullToRefresh.h"

@interface BaseTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    BOOL    m_bMoreLoad;
    
    int     m_limit;
    int     m_offset;
    int     m_total_count;
}

@property(nonatomic, strong) IBOutlet UITableView * mTableView;
@property (nonatomic, assign) BOOL _loading;



- (void)startRefresh;
- (void)startMoreLoad;

- (void) disableMoreLoad;
- (void) doneLoadingTableViewData;

@end
