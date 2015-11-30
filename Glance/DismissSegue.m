//
//  DismissSegue.m
//  DismissSegueExample
//

#import "DismissSegue.h"

@implementation DismissSegue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
//    UIViewController *sourceViewContreoller = [self sourceViewController];
//    [sourceViewContreoller.navigationController popViewControllerAnimated:YES];
}
@end
