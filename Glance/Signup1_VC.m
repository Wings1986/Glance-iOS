//
//  SignupViewController.m
//  Glance
//
//  Created by Conqueror on 12/20/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import "Signup1_VC.h"
#import "Signup2_AddPhotoVC.h"
#import "PrivacyVC.h"


@interface Signup1_VC ()
@end

@implementation Signup1_VC

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

    if ([segue.identifier isEqualToString:@"gotoSignup2"]) {
        
        NSLog(@"%@", [AppDelegate sharedInstance].signupParam);

    }
    else if ([segue.identifier isEqualToString:@"goto_privacy"]) {
        PrivacyVC * vc = segue.destinationViewController;
        vc.m_title = @"Privacy Policy";
    }
    else if ([segue.identifier isEqualToString:@"goto_terms"]) {
        PrivacyVC * vc = segue.destinationViewController;
        vc.m_title = @"Terms of Use";
    }

}

#pragma mark - UITextField delegate methods
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == userTxtField) {
        [AppDelegate sharedInstance].userStr = userTxtField.text;
    }else if(textField == passTxtField){
        [AppDelegate sharedInstance].passStr = passTxtField.text;
    }else if(textField == emailTxtField){
        [AppDelegate sharedInstance].emailStr = emailTxtField.text;        
    }
    [textField resignFirstResponder];
}

#define MAX_LENGTH 20

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    if (textField.text.length >= MAX_LENGTH && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else
    {
        return YES;
    }
    
}

- (IBAction)onClickNext:(id)sender {
    
    NSString * email = emailTxtField.text;
    if (email.length < 1) {
        [[AppDelegate sharedInstance] showAlertMessage:@"NOTE" message:@"Please input email address"];
        return;
    }
    if (![AppDelegate isValidEmail:email]) {
        [[AppDelegate sharedInstance] showAlertMessage:@"NOTE" message:@"Your email is invalid"];
        return;
    }
    NSString * username = userTxtField.text;
    if (username.length < 1) {
        [[AppDelegate sharedInstance] showAlertMessage:@"NOTE" message:@"Please input username"];
        return;
    }
    if (![AppDelegate isValidCharactorLength:username length:4]) {
        [[AppDelegate sharedInstance] showAlertMessage:@"NOTE" message:@"Your name should be a minimun of 4 characters in length"];
        return;
    }
    NSString * password = passTxtField.text;
    if (password.length < 1) {
        [[AppDelegate sharedInstance] showAlertMessage:@"NOTE" message:@"Please input password"];
        return;
    }
    if (![AppDelegate isValidCharactorLength:password length:6]) {
        [[AppDelegate sharedInstance] showAlertMessage:@"NOTE" message:@"Your password should be a minimun of 4 characters in length"];
        return;
    }
    NSString * confirm = confirmTxtField.text;
    if (![confirm isEqualToString:password]) {
        [[AppDelegate sharedInstance] showAlertMessage:@"NOTE" message:@"The passwords provided do not match"];
        return;
    }
    
    if ([username isEqualToString:password]) {
        [[AppDelegate sharedInstance] showAlertMessage:@"NOTE" message:@"Password can't be same as username."];
        return;
    }
    
    
    [[AppDelegate sharedInstance].signupParam setObject:username forKey:@"username"];
    [[AppDelegate sharedInstance].signupParam setObject:email forKey:@"email"];
    [[AppDelegate sharedInstance].signupParam setObject:password forKey:@"password"];
    
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString * urlString = [[NSString stringWithFormat:@"%@/user/", BASICURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [manager POST:urlString
       parameters:[AppDelegate sharedInstance].signupParam constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
           
           
       } success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
           
           NSDictionary * result = (NSDictionary*)responseObject;
           NSLog(@"result = %@", result);
           
           
           NSString *authStr = [NSString stringWithFormat:@"%@:%@",
                                [AppDelegate sharedInstance].signupParam[@"username"],
                                [AppDelegate sharedInstance].signupParam[@"password"]];
           NSString *encodedLoginData = [Base64 encode:[authStr dataUsingEncoding:NSUTF8StringEncoding]];
           [AppDelegate sharedInstance].authData = [NSString stringWithFormat:@"Basic %@", encodedLoginData];
           
           [AppDelegate sharedInstance].bLoginToken = YES;
           [AppDelegate sharedInstance].userInfo = result[@"objects"];
           
           
           //set value into NSUserDefaults
           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
           [defaults setObject:[AppDelegate sharedInstance].userInfo forKey:@"user"];
           [defaults setBool:[AppDelegate sharedInstance].bLoginToken forKey:@"token"];
           [defaults setObject:[AppDelegate sharedInstance].authData forKey:@"auth"];
           [defaults synchronize];
           
           
           [self performSegueWithIdentifier:@"gotoSignup2" sender:nil];
           
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
           
           NSLog(@"error = %@", error.description);
           
           [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"Signup error"];
           
       }];

    
}

@end