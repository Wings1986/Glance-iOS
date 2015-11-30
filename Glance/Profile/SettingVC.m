//
//  SettingVC.m
//  Glance
//
//  Created by Vanguard on 12/29/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import "SettingVC.h"
#import "ChangePassVC.h"
#import "Signup3_InviteFriendsVC.h"
#import "PrivacyVC.h"

#import <MessageUI/MFMailComposeViewController.h>//mail controller

@interface SettingVC ()<MFMailComposeViewControllerDelegate>
{
    NSMutableDictionary *addressDictionary;
    
    NSMutableDictionary *changeInfoDict;
    
    IBOutlet UIImageView *ivBackground;
    
    //profile
    IBOutlet UILabel *lbLoc;
    IBOutlet UITextField *tfName;
    IBOutlet UITextField *tfBio;
    
    IBOutlet UITextField *tfEmail;
    IBOutlet UITextField *tfPhone;
    
    IBOutlet UILabel *lbVersion;
    
    IBOutlet UIScrollView *mainScrView;
}

@end

@implementation SettingVC

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    ivBackground.image = self.backImage;
    
    [mainScrView setContentSize:CGSizeMake(mainScrView.frame.size.width, 872)];
    [mainScrView setScrollEnabled:YES];
    [mainScrView setPagingEnabled:NO];
    
    
    changeInfoDict = [[NSMutableDictionary alloc] init];
    
    addressDictionary = [[NSMutableDictionary alloc] init];
    addressDictionary[@"country_code"] = [AppDelegate sharedInstance].userInfo[@"city"][@"country_code"];
    addressDictionary[@"name"] = [AppDelegate sharedInstance].userInfo[@"city"][@"name"];
    
    
    lbLoc.text = [NSString stringWithFormat:@"%@, %@", addressDictionary[@"country_code"], addressDictionary[@"name"]];
    tfName.text = [AppDelegate sharedInstance].userInfo[@"username"];
    tfBio.text = [AppDelegate sharedInstance].userInfo[@"bio"];
    
    tfEmail.text = [AppDelegate sharedInstance].userInfo[@"email"];
    tfPhone.text = [AppDelegate sharedInstance].userInfo[@"phone_number"];

    lbVersion.text = [NSString stringWithFormat:@"Version: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of  any resources that can be recreated.
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
    else if ([segue.identifier isEqualToString:@"goto_terms"]) {
        PrivacyVC * vc = segue.destinationViewController;
        vc.m_title = @"Term of Service";
    }
}


#pragma mark - SAVE
- (IBAction)onClickSave:(id)sender {

    [self save];
}

- (IBAction)onClickLoc:(id)sender {

    [self reverseGeocoding];
    
}
- (IBAction)onClickNotification:(id)sender {
}

#pragma mark - social
- (IBAction)onFindFriends:(id)sender {
}
- (IBAction)onInviteFriends:(id)sender {
}
- (IBAction)onClickLikedAccount:(id)sender {
}

#pragma mark - support
- (IBAction)onClickContactUS:(id)sender {
    if(![MFMailComposeViewController canSendMail]){
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please configure your mail settings to send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    MFMailComposeViewController* mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"Contact US"];
    
    [self presentViewController:mc animated:YES completion:nil];
}

- (IBAction)onClickDeleteAccount:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Settings" message:@"Do you want to delete this account?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    alert.tag = 1000;
    [alert show];
}
- (IBAction)onClickLogout:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Settings" message:@"Do you want to log out?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    alert.tag = 2000;
    [alert show];
}

- (void)save{
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/", BASICURL, [AppDelegate sharedInstance].userInfo[@"id"]];
//    NSURL *urlLink = [NSURL URLWithString:urlString];
//    [self sendWebService:urlLink serviceName:@"updateUser" parameter:changeInfoDict method:FSNRequestMethodPOST];
    
//    [[AppDelegate sharedInstance] postResource:@"" andMethod:@"PUT" andWithParams:changeInfoDict andLink:urlString
//           AndCallback:^(id result, NSError *error) {
//               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//               NSLog(@"%@", result);
//               
//               if (result != NULL) {
//                   if ([result[@"objects"] isKindOfClass:[NSDictionary class]]) {
//                       [AppDelegate sharedInstance].userInfo = result[@"objects"];
//                   }
//                   
//                   [self.navigationController popViewControllerAnimated:YES];
//               }else{
//                   [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Try again."];
//               }
//           }];
}

- (void)logoutProcess{
    [AppDelegate sharedInstance].bLoginToken = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[AppDelegate sharedInstance].bLoginToken forKey:@"token"];
    [defaults synchronize];
    
    UINavigationController *rootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"naviRoot"];
    [AppDelegate sharedInstance].window.rootViewController = rootVC;
}

- (void)reverseGeocoding{

    NSLog(@"cur loc = lat = %f, lng = %f", [AppDelegate sharedInstance].startLocation.coordinate.latitude, [AppDelegate sharedInstance].startLocation.coordinate.longitude);
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *newLocation = [[CLLocation alloc]
                               initWithLatitude:[AppDelegate sharedInstance].startLocation.coordinate.latitude
                               longitude:[AppDelegate sharedInstance].startLocation.coordinate.longitude];
    
    [geocoder reverseGeocodeLocation:newLocation
                   completionHandler:^(NSArray *placemarks,
                                       NSError *error) {
                       
                       if (error) {
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       
                       if (placemarks && placemarks.count > 0)
                       {
                           CLPlacemark *placemark = placemarks[0];
                           
                           if (placemark.ISOcountryCode != nil) {
                               addressDictionary[@"country_code"] = placemark.ISOcountryCode;
                           }
                           if (placemark.locality != nil) {
                               addressDictionary[@"name"] = placemark.locality;
                           }
                           
//                           addressDictionary = placemark.addressDictionary;
//                           NSString *address = [addressDictionary
//                                                objectForKey:
//                                                (NSString *)kABPersonAddressStreetKey];
//                           NSString *city = [addressDictionary
//                                             objectForKey:
//                                             (NSString *)kABPersonAddressCityKey];
//                           NSString *state = [addressDictionary
//                                              objectForKey:
//                                              (NSString *)kABPersonAddressStateKey];
//                           NSString *zip = [addressDictionary
//                                            objectForKey:
//                                            (NSString *)kABPersonAddressZIPKey];
//                           
//                           NSLog(@"%@ %@ %@ %@", address,city, state, zip);
                           
                           
                           lbLoc.text = [NSString stringWithFormat:@"%@, %@", addressDictionary[@"country_code"], addressDictionary[@"name"]];

                       }
                   }];
}



- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    switch (result) {
        case MFMailComposeResultSent:
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Password delegate
- (void)changePassword:(NSString*)newPass{
    [changeInfoDict setObject:newPass forKey:@"password"];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (alertView.tag == 1000) {
            NSString *urlString = [NSString stringWithFormat:@"%@/user/", BASICURL];
            NSURL *url = [NSURL URLWithString:urlString];
//            NSString *testURL = [NSString stringWithFormat:@"%@/video/117/like/", BASICURL];
//            [self sendWebService:url serviceName:@"deleteUser" parameter:nil method:FSNRequestMethodPOST];
            
//            [[AppDelegate sharedInstance] postResource:@"" andMethod:@"DELETE" andWithParams:nil andLink:urlString
//                             AndCallback:^(id result, NSError *error) {
//                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                                 NSLog(@"%@", result);
//                                 
//                                 if (result != NULL) {
//                                     [self.navigationController popViewControllerAnimated:YES];
//                                 }else{
//                                     [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Try again."];
//                                 }
//                             }];
        }else if (alertView.tag == 2000){
            [self logoutProcess];
        }
    }
}
#pragma mark - Communication methods
- (FSNConnection*)sendWebService:(NSURL*)link serviceName:(NSString*)alias parameter:(NSMutableDictionary*)param method:(FSNRequestMethod)Type{
    // to make a successful foursquare api request, add your own api credentials here.
    // for more information see: https://developer.foursquare.com/overview/auth
    NSDictionary *headers;
    
    if ([alias isEqualToString:@"deleteUser"]) {
        headers = [NSDictionary dictionaryWithObjectsAndKeys:[AppDelegate sharedInstance].authData, @"Authorization", @"DELETE", @"X-HTTP-Method-Override", nil];
    }else if ([alias isEqualToString:@"updateUser"]){
        headers = [NSDictionary dictionaryWithObjectsAndKeys:[AppDelegate sharedInstance].authData, @"Authorization", @"PUT", @"X-HTTP-Method-Override", nil];
    }else{
        headers = [NSDictionary dictionaryWithObjectsAndKeys:[AppDelegate sharedInstance].authData, @"Authorization", nil];
    }
    
    NSLog(@"%@", headers);
    return [FSNConnection withUrl:link
                           method:FSNRequestMethodPOST
                          headers:headers
                       parameters:param
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
                      NSLog(@"complete: %@\n\nerror: %@\n\n", c, c.error);
                      NSLog(@"%@",c.parseResult);
                      
                      if ([c.parseResult isKindOfClass:[NSMutableDictionary class]]) {
                          NSMutableDictionary *result = (NSMutableDictionary*)c.parseResult;

                          if ([alias isEqualToString:@"updateUser"]) {
                              [self.navigationController popViewControllerAnimated:YES];
                          }else if ([alias isEqualToString:@"deleteUser"]){
                              [self logoutProcess];
                          }
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}


#pragma mark - UITextField delegate methods
-(void)textFieldDidBeginEditing:(UITextField *)textField{
}

-(void)textFieldDidEndEditing:(UITextField *)textField{

    if (textField == tfName) {
        [changeInfoDict setObject:textField.text forKey:@"full_name"];
    }
    else if (textField == tfBio) {
        [changeInfoDict setObject:textField.text forKey:@"bio"];
    }
    else if (textField == tfBio) {
        [changeInfoDict setObject:textField.text forKey:@"email"];
    }
    else if (textField == tfBio) {
        [changeInfoDict setObject:textField.text forKey:@"phone_number"];
    }

    NSLog(@"%@", changeInfoDict);

    [textField resignFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    return YES;
}


@end
