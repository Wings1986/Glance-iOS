//
//  ProfileVC.m
//  Glance
//
//  Created by Vanguard on 12/15/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import "ProfileVC.h"

#import "AppDelegate.h"

#import "FavoriteVC.h"
#import "SettingVC.h"
#import "FollowerVC.h"


#import "EmbededTableViewController.h"


typedef enum{
    GLANCE = 0,
    LIKES,
} FEEDTYPE;


@interface ProfileVC ()
{
    
    IBOutlet UILabel *userLabel, *nameLabel, *cityLabel, *bioLabel, *followersLabel, *numFollowLabel;
    IBOutlet UIImageView *profImgView;
    IBOutlet UISegmentedControl *feedTypeControl;
    
    IBOutlet UIButton *btnSetting;
    IBOutlet UIButton *btnFollow;
    
    IBOutlet UIButton *btnNotify;
    
    EmbededTableViewController * containController;
    
    FEEDTYPE feedType;
    
    NSMutableArray * glanceList;
    NSMutableArray * likeList;
}
@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    feedType = GLANCE;
    feedTypeControl.selectedSegmentIndex = GLANCE;
    
    if (!_bOtherProfile) {
        self.userInfo = [AppDelegate sharedInstance].userInfo;
    }
    
    // change UI design
    if (!_bOtherProfile) { // owner
        btnSetting.hidden = NO;
        btnFollow.hidden = YES;
        [btnNotify setImage:[UIImage imageNamed:@"notifications-activity-icon.png"] forState:UIControlStateNormal];
    }
    else { // other user
        btnSetting.hidden = YES;
        btnFollow.hidden = NO;
        [btnNotify setImage:[UIImage imageNamed:@"back button.png"] forState:UIControlStateNormal];
    }
    
    
    [self getUserInfo];
    [self getFollowers];
    [self getFollowing];
    
//    [self startRefresh];
    [self getFeedDatas:GLANCE];
    [self getFeedDatas:LIKES];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [AppDelegate sharedInstance].authData = [defaults objectForKey:@"auth"];
    
    //tab bar controller setting
//    UIImage* tabBarBackground = [UIImage imageNamed:@"bottom-tab-bar3.png"];
//    [self.tabBarController.tabBar setBackgroundImage:tabBarBackground];
//    [self.tabBarController.tabBar setSelectedImageTintColor:[UIColor colorWithRed:77/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]];
    [self.tabBarController.tabBar setHidden:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"embed_feed"]) {
        containController = segue.destinationViewController;
        containController.parentController = self;
    }
    else if ([segue.identifier isEqualToString:@"goto_followers"]) {
        FollowerVC * vc = segue.destinationViewController;
        vc.userID = self.userInfo[@"id"];
    }
    else if ([segue.identifier isEqualToString:@"gotoSetting"]) {
        SettingVC *vc = segue.destinationViewController;
        vc.backImage = [[AppDelegate sharedInstance] getScreencapture];
    }
}

- (void) getUserInfo
{
    userLabel.text = self.userInfo[@"username"];

    [containController setUserInfo:self.userInfo];
    
    
//    profImgView.layer.borderColor = [UIColor whiteColor].CGColor;
//    profImgView.layer.borderWidth = 5;
//    profImgView.layer.cornerRadius = profImgView.frame.size.height/2.0f;
//    profImgView.clipsToBounds = YES;
//    
//    
//    [profImgView sd_setImageWithURL:[NSURL URLWithString:[self.userInfo[@"avatar"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
//                             placeholderImage:[UIImage imageNamed:@"my_avatar_icon.png"]];
//
//    
//    userLabel.text = self.userInfo[@"username"];
//
//    nameLabel.text = [NSString stringWithFormat:@"%@ %@",
//                      self.userInfo[@"first_name"],
//                      self.userInfo[@"last_name"]];
//
//    bioLabel.text = self.userInfo[@"bio"];
//    
//    if ([self.userInfo[@"city"] isKindOfClass:[NSDictionary class]]) {
//        cityLabel.text = [NSString stringWithFormat:@"%@, %@",
//                           self.userInfo[@"city"][@"name"],
//                           self.userInfo[@"city"][@"country_code"]];
//    } else {
//        cityLabel.text = @"";
//    }
}

- (void)getFollowers{

    NSString *urlString;
    if (_bOtherProfile) {
        urlString = [NSString stringWithFormat:@"user/%@/follower/", self.userInfo[@"id"]];
    } else {
        urlString = @"user/follower/";
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASICURL, urlString]];

    FSNConnection *connection = [self sendWebService:url serviceName:@"followers" parameter:nil method:FSNRequestMethodGET];
    [connection start];
}

- (void)getFollowing{
    
    NSString *urlString;
    if (_bOtherProfile) {
        urlString = [NSString stringWithFormat:@"user/%@/following/", self.userInfo[@"id"]];
    } else {
        urlString = @"user/following/";
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASICURL, urlString]];
    
    FSNConnection *connection = [self sendWebService:url serviceName:@"following" parameter:nil method:FSNRequestMethodGET];
    [connection start];
}

- (void)startRefresh
{
    m_offset = 0;
    [self getFeedDatas:feedType];
}
- (void)startMoreLoad
{
    m_offset += m_limit;
    if (m_offset < m_total_count) {
        [self getFeedDatas:feedType];
    }
    else {
        [containController disableMoreLoad];
    }
    
}
- (void) doneLoadingTableViewData {
    
    if (feedType == GLANCE) {
        [containController doneLoadingTableViewData:(NSArray*)glanceList];
    }
    else {
        [containController doneLoadingTableViewData:(NSArray*)likeList];
    }

}

- (void) getFeedDatas:(FEEDTYPE) type{
    NSString *urlString;

    if (type == GLANCE) {
        urlString = [NSString stringWithFormat:@"user/%@/video/", self.userInfo[@"id"]];
    }
    else {
        if (_bOtherProfile)
            urlString = [NSString stringWithFormat:@"user/%@/likes", self.userInfo[@"id"]];
        else
            urlString = @"user/likes";
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASICURL,[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSDictionary* param = @{@"limit":[NSNumber numberWithInt:m_limit],
                            @"offset":[NSNumber numberWithInt:m_offset]};
    
    FSNConnection *connection = [self sendWebService:url serviceName:[NSString stringWithFormat:@"feed_%d", type] parameter:param method:FSNRequestMethodGET];
    [connection start];
    
}



- (FSNConnection*)sendWebService:(NSURL*)link serviceName:(NSString*)alias parameter:(NSDictionary*)param method:(FSNRequestMethod)Type{
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    return [FSNConnection withUrl:link
                           method:Type
                          headers:@{@"Authorization":[AppDelegate sharedInstance].authData}
                       parameters:param
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           
//                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                           
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
                      
//                      [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                      
                      if ([alias containsString:@"feed"]) {
                          if ([c.parseResult isKindOfClass:[NSMutableDictionary class]]) {
                              
                              NSMutableDictionary *result = (NSMutableDictionary*)c.parseResult;
                              
                              if ([result[@"meta"] isKindOfClass:[NSDictionary class]]) {
                                  m_offset = [result[@"meta"][@"offset"] intValue];
                                  m_total_count = [result[@"meta"][@"total_count"] intValue];
                              }
                              
                              if ([result[@"objects"] isKindOfClass:[NSArray class]] && [result[@"objects"] count] > 0){
                                  
                                  NSMutableArray * objs = [result[@"objects"] mutableCopy];
                                  
                                  if (m_offset == 0) {
                                      if ([alias isEqualToString:@"feed_0"]) {
                                          glanceList = [objs mutableCopy];
                                      }
                                      else if ([alias isEqualToString:@"feed_1"]) {
                                          likeList = [objs mutableCopy];
                                      }
                                  } else {
                                      if ([alias isEqualToString:@"feed_0"]) {
                                          [glanceList addObjectsFromArray:objs];
                                      }
                                      else if ([alias isEqualToString:@"feed_1"]) {
                                          [likeList addObjectsFromArray:objs];
                                      }
                                  }
                                  
                              }
                              
                          }
                          
                          
                          [self doneLoadingTableViewData];
                          
                      }
                      else if ([alias isEqualToString:@"followers"]) {
                          NSMutableDictionary *result = (NSMutableDictionary*)c.parseResult;
                          
                          if ([result[@"meta"] isKindOfClass:[NSDictionary class]]) {
                              [containController setNumberOfFollower:result[@"meta"][@"total_count"]];
//                              followersLabel.text = [NSString stringWithFormat:@"%d", [result[@"meta"][@"total_count"] intValue]] ;
                          }
                      }
                      else if ([alias isEqualToString:@"following"]) {
                          NSMutableDictionary *result = (NSMutableDictionary*)c.parseResult;
                          
                          if ([result[@"meta"] isKindOfClass:[NSDictionary class]]) {
                              [containController setNumberOfFollowing:result[@"meta"][@"total_count"]];
//                              numFollowLabel.text = [NSString stringWithFormat:@"%d", [result[@"meta"][@"total_count"] intValue]] ;
                          }
                      }
                      else if ([alias isEqualToString:@"following_user"]) {
                          if (c.parseResult != nil) {
                              [btnFollow setImage:[UIImage imageNamed:@"unfollow-button.png"] forState:UIControlStateNormal];
                          }
                      }
                      
                  }
                    progressBlock:^(FSNConnection *c) {
                        //                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}



#pragma mark - IBAction Methods
- (IBAction)FeedTypeSelect:(UISegmentedControl*)sender{
    if (sender.selectedSegmentIndex == 0) {
        feedType = GLANCE;
    }else if (sender.selectedSegmentIndex == 1) {
        feedType = LIKES;
    }
    
    [self doneLoadingTableViewData];
    
    @try {
        [containController.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    [self startRefresh];
}


- (IBAction)onClickFollow:(id)sender {

    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@/user/following/", BASICURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSDictionary * param = @{@"user_id":self.userInfo[@"id"]};
    
    FSNConnection *connection = [self sendWebService:url serviceName:@"following_user" parameter:param method:FSNRequestMethodPOST];
    [connection start];
}

- (IBAction)Favorite:(id)sender{
    if (_bOtherProfile) { // other user
//        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


@end
