//
//  PopupSegue.m
//  PopupSegueExample
//

#import "PopupSegue.h"

@implementation PopupSegue

- (void)perform {
//    UIViewController *sourceViewController = self.sourceViewController;
//    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    UIViewController *sourceViewContreoller = [self sourceViewController];
    [sourceViewContreoller.navigationController popViewControllerAnimated:NO];
}

@end
