//
//  BaseRequestViewController.m
//  Glance
//
//  Created by User on 5/5/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import "BaseRequestViewController.h"

#import "URBAlertView.h"

#import "ProfileVC.h"
#import "CommentsVC.h"
#import "FollowerVC.h"
#import "AppDelegate.h"


@interface BaseRequestViewController ()
{
    BOOL longPressed;
}
@end

@implementation BaseRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    longPressed = NO;
    
    [likeButton addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongClickLike:)]];

    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onClickMore:)]];

    imgBlurMoreView.userInteractionEnabled = YES;
    [imgBlurMoreView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickMore:)]];
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

- (void)onClickMore:(UIGestureRecognizer*) gesture{

    BOOL bShouldShowMore;
    
    if (gesture == nil) {
        bShouldShowMore = NO;
    }
    else {
        
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            
            if (gesture.state == UIGestureRecognizerStateBegan) {
                longPressed = YES;
                bShouldShowMore = YES;
            }
            else if (gesture.state == UIGestureRecognizerStateEnded) {
                longPressed = NO;
                return;
            }
            else {
                longPressed = NO;
                return;
            }
            
        }
        else if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            if (longPressed) {
                return;
            }
            
            if (gesture.state == UIGestureRecognizerStateBegan) {
                return;
            }
            else if (gesture.state == UIGestureRecognizerStateEnded) {
                bShouldShowMore = NO;
            }
            else {
                return;
            }
            
        }
        
    }
    
    
    
    if (bShouldShowMore == YES) {
        imgBlurMoreView.image = [[AppDelegate sharedInstance] getBlurImage:imageView.image];
    }
    
    moreView.hidden = bShouldShowMore;
    moreView.alpha = bShouldShowMore ? 0.0f : 1.0f;
    
    [UIView animateWithDuration:0.5 animations:^{
        moreView.alpha = bShouldShowMore ? 1.0f : 0.0f;
    } completion:^(BOOL finished) {
        moreView.hidden = !bShouldShowMore;
    }];
    
}

- (void)userProfile:(UIGestureRecognizer*) gesture{
    ProfileVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileVC"];
    dest.bOtherProfile = YES;
    dest.userInfo = _feedItem[@"user"];
    
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)onClickComment:(id)sender {
    
    CommentsVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentsVC"];
    dest.vidID = _feedItem[@"id"];
    dest.backImage = [[AppDelegate sharedInstance] getBlurImage:imageView.image];
    
    [self presentViewController:dest animated:NO completion:nil];
    
}

- (IBAction)onClickShare:(id)sender {
    
    NSArray *objectsToShare = @[[NSString stringWithFormat:@"%@\n%@", _feedItem[@"headline"], _feedItem[@"video"]]];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}
- (void) onLongClickLike:(UIGestureRecognizer*) gesture
{
    FollowerVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowerVC"];
    dest.userID = _feedItem[@"user"][@"id"];
    dest.mode = USER_LIKES;
    dest.backImage = [[AppDelegate sharedInstance] getScreencapture];
    [self presentViewController:dest animated:NO completion:nil];
}

- (IBAction)onClickLike:(id)sender {
//    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@/video/%@/like/", BASICURL, _feedItem[@"id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    
//    FSNConnection *connection = [self sendWebService:url serviceName:@"like" parameter:nil method:FSNRequestMethodPOST extra:nil];
//    [connection start];
    
    
    NSString *urlString = [[NSString stringWithFormat:@"%@/video/%@/like/", BASICURL, _feedItem[@"id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].authData forHTTPHeaderField:@"Authorization"];
    
    if (_feedItem[@"didlike"] != nil && [_feedItem[@"didlike"] boolValue]) { // delete
        
        [manager DELETE:urlString parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSDictionary * result = (NSDictionary*)responseObject;
                    NSLog(@"result = %@", result);
                    
                    
                    if (result != NULL) {
                        NSLog(@"successfully done");
                        
                        _feedItem[@"didlike"] = [NSNumber numberWithBool:NO];
                        _feedItem[@"likes"] = [NSNumber numberWithInt: [_feedItem[@"likes"] intValue] - 1];
                        
                        [self setInterface];
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    NSLog(@"error = %@", error.description);
                    
                }];
        
    }
    else { // like
        
        [manager POST:urlString
           parameters:nil constructingBodyWithBlock:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  NSDictionary * result = (NSDictionary*)responseObject;
                  NSLog(@"result = %@", result);
                  
                  
                  if (result != NULL) {
                      NSLog(@"successfully done");
                      
                      _feedItem[@"didlike"] = [NSNumber numberWithBool:YES];
                      _feedItem[@"likes"] = [NSNumber numberWithInt: [_feedItem[@"likes"] intValue] + 1];
                      
                      [self setInterface];
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  
                  NSLog(@"error = %@", error.description);
                  
                  _feedItem[@"didlike"] = [NSNumber numberWithBool:YES];
                  _feedItem[@"likes"] = [NSNumber numberWithInt: [_feedItem[@"likes"] intValue] + 1];
                  
                  [self setInterface];
                  
              }];
        
    }
    
    
}
- (IBAction)onClickReport:(id)sender {
    
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"REPORT" message:@""];
    [alertView addTextFieldWithPlaceholder:@"Please input note for report" secure:NO];
    [alertView addButtonWithTitle:@"Nudity"];
    [alertView addButtonWithTitle:@"Fake"];
    [alertView addButtonWithTitle:@"Other"];
    [alertView addButtonWithTitle:@"Cancel"];
    
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        
        [alertView hideWithCompletionBlock:^{
            
            switch (buttonIndex) {
                case 0:
                case 1:
                case 2:
                {
                    dispatch_async(dispatch_get_main_queue(),^{
                        
                        NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@/video/%@/report/", BASICURL, _feedItem[@"id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        
                        NSString * note = [alertView textForTextFieldAtIndex:0];
                        NSString *reason = @"";
                        if (buttonIndex == 0)
                            reason = @"Nudity";
                        else if (buttonIndex == 1)
                            reason = @"Fake";
                        else
                            reason = @"Other";
                        
                        
                        NSDictionary * param = @{@"report_reason": reason,
                                                 @"note": note};
                        
                        FSNConnection *connection = [self sendWebService:url serviceName:@"report" parameter:param method:FSNRequestMethodPOST extra:nil];
                        [connection start];
                    });
                    
                    
                }
                    break;
                    
                default:
                    break;
            }
            
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationFlipHorizontal];
}

#pragma mark WEB SERVICE
- (FSNConnection*)sendWebService:(NSURL*)link serviceName:(NSString*)alias parameter:(NSDictionary*)param method:(FSNRequestMethod)Type extra:(NSString*)info{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    return [FSNConnection withUrl:link
                           method:Type
                          headers:@{@"Authorization":[AppDelegate sharedInstance].authData}
                       parameters:param
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           
                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                           
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
                      
                      NSLog(@"%@",c.parseResult);
                      
                      [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                      
                      if ([alias isEqualToString:@"like"]) {
                          [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Liked Successfully"];
                      }
                      else if ([alias isEqualToString:@"report"]) {
                          [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Reported Successfully"];
                      }
                  }
            
                    progressBlock:^(FSNConnection *c) {
                    }];
}

@end
