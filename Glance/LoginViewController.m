//
//  LoginViewController.m
//  Glance
//
//  Created by Conqueror on 12/20/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import "LoginViewController.h"
#import "PrivacyVC.h"

@interface LoginViewController ()
@property (nonatomic, strong) FSNConnection *connection;
@end

@implementation LoginViewController
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
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



- (FSNConnection*)loginConnection:(NSDictionary*)param{
    NSURL *url = [NSURL URLWithString:LOGIN];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // to make a successful foursquare api request, add your own api credentials here.
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", _userTxtField.text, _passTxtField.text];
    NSString *encodedLoginData = [Base64 encode:[authStr dataUsingEncoding:NSUTF8StringEncoding]];
    [AppDelegate sharedInstance].authData = [NSString stringWithFormat:@"Basic %@", encodedLoginData];
    
    // for more information see: https://developer.foursquare.com/overview/auth
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:[AppDelegate sharedInstance].authData, @"Authorization", nil];
    
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST  
                          headers:headers
                       parameters:nil
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSDictionary *d = [c.responseData dictionaryFromJSONWithError:error];
                           if (!d) return nil;
                           
                           // example error handling.
                           // since the demo ships with invalid credentials,
                           // running it will demonstrate proper error handling.
                           // in the case of the 4sq api, the meta json in the response holds error strings,
                           // so we create the error based on that dictionary.
                           if (c.response.statusCode != 200) {
                               *error = [NSError errorWithDomain:@"FSAPIErrorDomain"
                                                            code:1
                                                        userInfo:[d objectForKey:@"meta"]];
                           }
                           
                           return d;
                       }
                  completionBlock:^(FSNConnection *c) {
                      [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                      NSLog(@"complete: %@\n\nerror: %@\n\n", c, c.error);
                      NSLog(@"%@",c.parseResult);
                      if (c.parseResult != nil){
                          [AppDelegate sharedInstance].bLoginToken = YES;
                          
                          if ([c.parseResult[@"objects"] isKindOfClass:[NSDictionary class]]) {
                              [AppDelegate sharedInstance].userInfo = c.parseResult[@"objects"];
                          }else if ([c.parseResult[@"objects"] isKindOfClass:[NSArray class]]){
                              [AppDelegate sharedInstance].userInfo = [c.parseResult[@"objects"] lastObject];
                          }

                          NSLog(@"%@", [AppDelegate sharedInstance].userInfo);
                          
                          //Set value into NSUserDefaults
                          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                          [defaults setObject:[AppDelegate sharedInstance].userInfo forKey:@"user"];
                          [defaults setObject:[AppDelegate sharedInstance].authData forKey:@"auth"];
                          [defaults setObject:_passTxtField.text forKey:@"pass"];
                          [defaults setBool:[AppDelegate sharedInstance].bLoginToken forKey:@"token"];
                          [defaults synchronize];
                          
//                          [self dismissViewControllerAnimated:NO completion:Nil];
                          UITabBarController *rootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"tabMain"];
                          [AppDelegate sharedInstance].window.rootViewController = rootVC;

                          
                      }else{
                          [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Try again please"];
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
//                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

- (FSNConnection*)signUpConnection:(NSDictionary*)param{
    NSURL *url = [NSURL URLWithString:SIGNUP];
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:APIKEY,@"Authorization", nil];
    
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST
                          headers:headers
                       parameters:param
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSDictionary *d = [c.responseData dictionaryFromJSONWithError:error];
                           if (!d) return nil;
                           
                           if (c.response.statusCode != 200) {
                               *error = [NSError errorWithDomain:@"FSAPIErrorDomain"
                                                            code:1
                                                        userInfo:[d objectForKey:@"meta"]];
                           }
                           return d;
                       }
                  completionBlock:^(FSNConnection *c) {
                      NSLog(@"complete: %@\n\nerror: %@\n\n", c, c.error);
                      NSLog(@"%@",c.parseResult);
                      
                      NSDictionary *lParameters =
                      [NSDictionary dictionaryWithObjectsAndKeys:
                       emailString,@"email",
                       @"facebook",@"password",
                       APIKEY,@"leclamonet",
                       nil];

                      self.connection = nil;
                      self.connection = [self loginConnection:lParameters];
                      [self.connection start];
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

#pragma mark - Facebook SDK Delegate
-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user{
//    NSString *first_name = user.first_name;
//    NSString *last_name = user.last_name;
//    NSString *username = [NSString stringWithFormat:@"%@ %@", first_name, last_name];
//    NSString *birthday = user.birthday;
//    NSString *link = user.link;
    emailString = [user objectForKey:@"email"];
    fbIdString = user.id;
    
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", user.id];
    NSLog(@"%@", userImageURL);
    
    if (fbIdString != nil) {
        NSDictionary *sParameters =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"", @"username",
         @"", @"password",
         emailString, @"email",
         @"nTbnHDHUGHjMAQ56kc0yCjLO4WzWwpoyq3SgNQvv9YvhinL6rqwwR3Pl9UeOzrTy6zbLNQnWv/NWQ5VLroM0NA==",@"leclamonet",
         nil];
        
//        self.connection = nil;
//        self.connection = [self signUpConnection:sParameters];
//        [self.connection start];
    }
}

#pragma mark - IBAction Methods
- (IBAction)Login:(id)sender{
    NSDictionary *parameters =
    [NSDictionary dictionaryWithObjectsAndKeys:
     _userTxtField.text,@"username",
     _passTxtField.text,@"password",
//     @"true", @"token",
     nil];

    self.connection = nil;
    self.connection = [self loginConnection:parameters];
    [self.connection start];
}

- (IBAction)onClickForgotPassword:(id)sender {
}

#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self keyboardWillShow];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self keyboardWillHide];
    [textField resignFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        //        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0){
        //        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp){
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_KEYBOARD;
    }
    else{
        // revert back to the normal state.
        rect.origin.y += kOFFSET_KEYBOARD;
        //        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

@end
