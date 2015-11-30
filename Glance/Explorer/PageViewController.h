//
//  PageViewController.h
//  
//

#import <UIKit/UIKit.h>

@interface PageViewController : UIViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    
}

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NSIndexPath *cellPath;
@property (nonatomic, retain) NSMutableArray *videoFeedList;
@property (nonatomic, readwrite) int shopIndex;


@end
