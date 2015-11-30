//
//  BaseTableViewController.m
//  Glance
//

#import "BaseTableViewController.h"



@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak BaseTableViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.mTableView addPullToRefreshWithActionHandler:^{
        if (!weakSelf._loading) {
            weakSelf._loading = YES;
            [weakSelf startRefresh];
        }
        
    }];
    
    if (!m_bMoreLoad) {
        // setup infinite scrolling
        [self.mTableView addInfiniteScrollingWithActionHandler:^{
            if (!weakSelf._loading) {
                weakSelf._loading = YES;
                [weakSelf startMoreLoad];
            }
        }];
    }

    
    m_limit = 10;
    m_offset = 0;
    m_total_count = 10;
}

- (void)startRefresh {
    
}

- (void)startMoreLoad {
    
}

- (void) disableMoreLoad {
    __weak BaseTableViewController *weakSelf = self;
    
    [weakSelf.mTableView.infiniteScrollingView stopAnimating];
    weakSelf._loading = NO;
}
- (void) doneLoadingTableViewData
{
    __weak BaseTableViewController *weakSelf = self;
    
    [weakSelf.mTableView reloadData];
    
    [weakSelf.mTableView.pullToRefreshView stopAnimating];
    [weakSelf.mTableView.infiniteScrollingView stopAnimating];
    
    weakSelf._loading = NO;
}

@end
