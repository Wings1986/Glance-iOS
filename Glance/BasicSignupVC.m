//
//  BasicSignupViewController.m
//  Glance
//
//  Created by Avramov on 3/17/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import "BasicSignupVC.h"
#import "HomeVC.h"

@interface BasicSignupVC ()

@end

@implementation BasicSignupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.signUpParam = [[NSMutableDictionary alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (FSNConnection*)signUpConnection:(NSDictionary*)params{
    NSURL *url = [NSURL URLWithString:SIGNUP];
    
    // to make a successful foursquare api request, add your own api credentials here.
    // for more information see: https://developer.foursquare.com/overview/auth
    // NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:APIKEY, @"Authorization", nil];
    
    NSLog(@"%@", params);
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST
                          headers:nil
                       parameters:params
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSDictionary *d = [c.responseData dictionaryFromJSONWithError:error];
                           if (!d) return nil;
                           
                           // example error handling.
                           // since the demo ships with invalid credentials,
                           // running it will demonstrate proper error handling.
                           // in the case of the 4sq api, the meta json in the response holds error strings,
                           // so we create the error based on that dictionary.
                           /*
                            Missing parameter 	10
                            Invalid value		20
                            Object not found	30
                            Unauthorized		40
                            Already exists		50
                            
                            Internal error		60
                            */
                           if (c.response.statusCode != 200) {
                               *error = [NSError errorWithDomain:@"FSAPIErrorDomain"
                                                            code:1
                                                        userInfo:[d objectForKey:@"meta"]];
                           }
                           return d;
                       }
                  completionBlock:^(FSNConnection *c) {
                      //show message
                      NSLog(@"success result = %@",c.parseResult);
                      NSMutableDictionary *tempDict = (NSMutableDictionary*)c.parseResult;
                      [[AppDelegate sharedInstance] showAlertMessage:@"" message:[tempDict objectForKey:@"msg"]];
                      
                      //save user information and login token
                      [AppDelegate sharedInstance].bLoginToken = YES;
                      [AppDelegate sharedInstance].userInfo = (NSMutableDictionary*)c.parseResult[@"objects"];
                      
                      //set value into NSUserDefaults
                      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                      [defaults setObject:[AppDelegate sharedInstance].userInfo forKey:@"user"];
                      [defaults setBool:[AppDelegate sharedInstance].bLoginToken forKey:@"token"];
                      [defaults synchronize];
                      
                      [self performSegueWithIdentifier:@"gotoInvite" sender:self];
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

@end
