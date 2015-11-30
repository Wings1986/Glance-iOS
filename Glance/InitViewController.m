//
//  InitViewController.m
//  Glance
//
//  Created by Avramov on 3/14/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import "InitViewController.h"
#import "Signup2_AddPhotoVC.h"
#import "LoginViewController.h"
#import "PrivacyVC.h"

@interface InitViewController ()

@end

@implementation InitViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"goto_privacy"]) {
        PrivacyVC * vc = segue.destinationViewController;
        vc.m_title = @"Privacy Policy";
    }
    if ([segue.identifier isEqualToString:@"goto_terms"]) {
        PrivacyVC * vc = segue.destinationViewController;
        vc.m_title = @"Terms of Use";
    }
}


#pragma mark - IBAction methods
- (IBAction)FBLogin:(id)sender{
    //for test
}

- (IBAction)TWLogin:(id)sender{
    
}

@end
