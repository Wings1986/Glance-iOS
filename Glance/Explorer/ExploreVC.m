//
//  ExploreVC.m
//  Glance
//
//  Created by Vanguard on 12/23/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import "ExploreVC.h"
#import "PageViewController.h"

@interface ExploreVC ()

@property (nonatomic, strong) FSNConnection *connection;

@end

@implementation ExploreVC
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"goto_random"]) {
        PageViewController *dest = segue.destinationViewController;
        dest.videoFeedList = sender;
    }
}

//  /video/city/
#pragma mark - IBActioh methods

- (IBAction)Next:(id)sender{
    NSString *urlString = [NSString stringWithFormat:@"video/city/"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASICURL, urlString]];
    
    self.connection = nil;
    self.connection = [self sendWebService:url serviceName:@"random" parameter:nil method:FSNRequestMethodGET];
    [self.connection start];
}

#pragma mark - Communication Methods
- (FSNConnection*)sendWebService:(NSURL*)link serviceName:(NSString*)alias parameter:(NSMutableDictionary*)param method:(FSNRequestMethod)Type{
    // to make a successful foursquare api request, add your own api credentials here.
    // for more information see: https://developer.foursquare.com/overview/auth
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:[AppDelegate sharedInstance].authData, @"Authorization", nil];
    
    return [FSNConnection withUrl:link
                           method:FSNRequestMethodGET
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
                          
                          [self performSegueWithIdentifier:@"goto_random" sender:result[@"objects"]];
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}


@end
