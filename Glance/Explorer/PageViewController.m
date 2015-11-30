//
//  PageViewController.m
//  Sportagory
//

#import "PageViewController.h"
//#import "ExploreDetailVC.h"
#import "ExplorePageVC.h"




@interface PageViewController ()<UIGestureRecognizerDelegate>
{
    NSUInteger cur_index;
}
@end

@implementation PageViewController

#pragma mark - Lifecycle methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
//    self.pageController.delegate = self;
    
    
    UISwipeGestureRecognizer *downSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    downSwipeGestureRecognizer.delaysTouchesEnded = YES;
    downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    downSwipeGestureRecognizer.delegate = self;
    [self.pageController.view addGestureRecognizer:downSwipeGestureRecognizer];
    
    
//    CGRect orgRect = [[self view] bounds];
//    CGRect rect1 = CGRectMake(orgRect.origin.x, orgRect.origin.y + 64, orgRect.size.width, orgRect.size.height-64);
//    [[self.pageController view] setFrame:rect1];
    
    ExplorePageVC *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    NSArray * subViews = self.pageController.view.subviews;
    UIPageControl * thisControl = nil;
    for (int i = 0 ; i < [subViews count]; i ++) {
        if ([[subViews objectAtIndex:i] isKindOfClass:[UIPageControl class]]) {
            thisControl = (UIPageControl*) [subViews objectAtIndex:i];
        }
    }
    thisControl.hidden = YES;
    self.pageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+40);
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction delegate methods

- (void)handleSwipes:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionDown
        && gesture.state == UIGestureRecognizerStateEnded) {
        
        [self dismissViewControllerAnimated:NO completion:nil];
//        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - PageController delegate
- (ExplorePageVC *)viewControllerAtIndex:(NSUInteger)index {
    cur_index = index;
    
    ExplorePageVC *childViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ExplorePageVC"];
    childViewController.m_index = index;
    childViewController.feedItem = [[self.videoFeedList objectAtIndex:index] mutableCopy];
    return childViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [(ExplorePageVC *)viewController m_index];

    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(ExplorePageVC *)viewController m_index];
    index++;
    
    if (index == self.videoFeedList.count) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return self.videoFeedList.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
//    ExplorePageVC *viewController = [previousViewControllers objectAtIndex:0];
//    if ([viewController m_index] == 0 || [viewController m_index] == self.videoFeedList.count)
//    {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    ExplorePageVC *viewController = [pendingViewControllers objectAtIndex:0];
    if ([viewController m_index] == 0 || [viewController m_index] == self.videoFeedList.count)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
