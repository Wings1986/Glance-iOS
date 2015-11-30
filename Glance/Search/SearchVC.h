//
//  SearchVC.h
//  Glance
//

#import <UIKit/UIKit.h>

#import "BaseTableViewController.h"

#import "AppDelegate.h"

@interface SearchVC : BaseTableViewController <UISearchBarDelegate>{

    IBOutlet UISearchBar *mSearchBar;
    IBOutlet UISegmentedControl *searchTypeControl;

    NSMutableArray *feedList;
}

@end
