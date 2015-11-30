//
//  HomeVC.m
//  Glance
//
//  Created by Vanguard on 12/13/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//



#import "HomeVC.h"
#import "SearchVC.h"
#import "ExploreVC.h"

#import "UIViewController+MJPopupViewController.h"
#import "ChooseCategoryDlg.h"


#import "EmbededTableViewController.h"


typedef enum {
    NEARBY = 0,
    POPULAR,
    FOLLOWING,
    CATEGORY,
    CITY,
    TAG,
} FEEDTYPE;


@interface HomeVC ()<ChooseCategoryDlgDelegate>
{
    IBOutlet UISegmentedControl *feedTypeControl;
    
    ChooseCategoryDlg * categoryDlg;
    
    NSString * m_chooseCategory;
    
    EmbededTableViewController * containController;
    
    FEEDTYPE m_feedType;
    
    NSMutableArray * nearbyList;
    NSMutableArray * worldList;
    NSMutableArray * followingList;
    
}


@end

@implementation HomeVC

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    UINavigationController * nav = (UINavigationController*) self.tabBarController.childViewControllers[1];
    nav.tabBarItem.image = [[UIImage imageNamed:@"tab_record-button.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    nearbyList = [userDefault objectForKey:@"nearby_data"];
    worldList = [userDefault objectForKey:@"world_data"];
    followingList = [userDefault objectForKey:@"following_data"];
    
    m_feedType = NEARBY;
    feedTypeControl.selectedSegmentIndex = NEARBY;

//    [self startRefresh];
    [self getFeedDatas:NEARBY];
    [self getFeedDatas:POPULAR];
    [self getFeedDatas:FOLLOWING];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    //tab bar controller setting
    
//    UIImage* tabBarBackground = [UIImage imageNamed:@"bottom-tab-bar1.png"];
//    [self.tabBarController.tabBar setBackgroundImage:tabBarBackground];
//    [self.tabBarController.tabBar setSelectedImageTintColor:[UIColor colorWithRed:77/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]];
//    [self.tabBarController.tabBarItem setSelectedImage:[UIImage imageNamed:@"home-button-selected.png"]];
    [self.tabBarController.tabBar setHidden:NO];

    
//    [self.tabBarController.tabBarItem setImage:[[UIImage imageNamed:@"tab_record-button.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [AppDelegate sharedInstance].bLoginToken = [defaults boolForKey:@"token"];
    [AppDelegate sharedInstance].userInfo = [defaults objectForKey:@"user"];
    [AppDelegate sharedInstance].authData = [defaults objectForKey:@"auth"];


    NSLog(@"userinfo = %@", [AppDelegate sharedInstance].userInfo);
    
//    feedView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    if (nearbyList != nil) {
        [userDefault setObject:nearbyList forKey:@"nearby_data"];
    }
    if (worldList != nil) {
        [userDefault setObject:worldList forKey:@"world_data"];
    }
    if (followingList != nil) {
        [userDefault setObject:followingList forKey:@"following_data"];
    }
    [userDefault synchronize];
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
    
}


- (void)startRefresh
{
//    [containController startRefresh];
    
    m_offset = 0;
    [self getFeedDatas:m_feedType];
}
- (void)startMoreLoad
{
    m_offset += m_limit;
    if (m_offset < m_total_count) {
        [self getFeedDatas:m_feedType];
//        [containController startMoreLoad];
    }
    else {
        [containController disableMoreLoad];
    }
    
}
- (void) doneLoadingTableViewData {
    
    if (m_feedType == NEARBY) {
        [containController doneLoadingTableViewData:(NSArray*)nearbyList];
    }
    else if (m_feedType == POPULAR) {
        [containController doneLoadingTableViewData:(NSArray*)worldList];
    }
    else if (m_feedType == FOLLOWING) {
        [containController doneLoadingTableViewData:(NSArray*)followingList];
    }
}

- (void) getFeedDatas:(FEEDTYPE) type {
    NSString *urlString;
    
    if (type == NEARBY) {
        // insert coordinate parameter for only
//        urlString = [NSString stringWithFormat:@"video/near/?lat=%.7f&lng=%.7f",
//                         [AppDelegate sharedInstance].startLocation.coordinate.latitude,
//                         [AppDelegate sharedInstance].startLocation.coordinate.longitude];
        urlString = @"video/near/";
    }
    else if (type == POPULAR) {
        urlString = @"video/";
    }
    else if (type == FOLLOWING) {
        urlString = @"video/feed/";
    }
    else if (type == CATEGORY) {
        urlString = [NSString stringWithFormat:@"video/?category__in=%@", m_chooseCategory];
    }
    else {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASICURL,[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSDictionary* param;
    
    if (type == NEARBY) {
        param = @{@"lat":[NSNumber numberWithFloat:[AppDelegate sharedInstance].startLocation.coordinate.latitude],
                  @"lng":[NSNumber numberWithFloat:[AppDelegate sharedInstance].startLocation.coordinate.longitude],
                  @"limit":[NSNumber numberWithInt:m_limit],
                  @"offset":[NSNumber numberWithInt:m_offset]};
        
    } else {
        param = @{@"limit":[NSNumber numberWithInt:m_limit],
                  @"offset":[NSNumber numberWithInt:m_offset]};

    }
    
    FSNConnection *connection = [self sendWebService:url serviceName:[NSString stringWithFormat:@"%d", type] parameter:param method:FSNRequestMethodGET extra:nil];
    [connection start];

}



- (FSNConnection*)sendWebService:(NSURL*)link serviceName:(NSString*)alias parameter:(NSDictionary*)param method:(FSNRequestMethod)Type extra:(NSString*)info{
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSLog(@"url = %@", [link absoluteString]);
    
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
                      
                      if ([c.parseResult isKindOfClass:[NSMutableDictionary class]]) {
                          
                          NSMutableDictionary *result = (NSMutableDictionary*)c.parseResult;
                          
                          if ([result[@"meta"] isKindOfClass:[NSDictionary class]]) {
                              m_offset = [result[@"meta"][@"offset"] intValue];
                              m_total_count = [result[@"meta"][@"total_count"] intValue];
                          }
                          
                          if ([result[@"objects"] isKindOfClass:[NSArray class]] && [result[@"objects"] count] > 0){

                              NSMutableArray * objs = [result[@"objects"] mutableCopy];
                              
                              if (m_offset == 0) {
                                  if ([alias isEqualToString:@"0"]) {
                                      nearbyList = [objs mutableCopy];
                                  }
                                  else if ([alias isEqualToString:@"1"]) {
                                      worldList = [objs mutableCopy];
                                  }
                                  else if ([alias isEqualToString:@"2"]) {
                                      followingList = [objs mutableCopy];
                                  }
                              } else {
                                  
                                  if ([alias isEqualToString:@"0"]) {
                                      [nearbyList addObjectsFromArray:objs];
                                  }
                                  else if ([alias isEqualToString:@"1"]) {
                                      [worldList addObjectsFromArray:objs];
                                  }
                                  else if ([alias isEqualToString:@"2"]) {
                                      [followingList addObjectsFromArray:objs];
                                  }

                              }
                              
                          }
                          
                          
                          [self doneLoadingTableViewData];
                          
                      }
                      
                  }
                    progressBlock:^(FSNConnection *c) {
//                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}


#pragma mark - Category methods
- (IBAction)ShowCategory:(id)sender{
//    [categoryView setHidden:NO];
    
//    categoryDlg = [[ChooseCategoryDlg alloc] initWithNibName:@"ChooseCategoryDlg" bundle:nil];
//    categoryDlg.delegate = self;
//    categoryDlg.mode = MODE_SELECT_MULTI;
//    [self presentPopupViewController:categoryDlg animationType:MJPopupViewAnimationFade];

    categoryDlg = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseCategoryDlg"];
    categoryDlg.delegate = self;
    categoryDlg.mode = MODE_SELECT_MULTI;
    categoryDlg.backImage = [[AppDelegate sharedInstance] getScreencapture];
    [self presentViewController:categoryDlg animated:NO completion:^{
        
    }];
    
}
- (void) chooseCategory:(NSMutableArray*) arrCategory;
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    categoryDlg = nil;
    
//    m_chooseCategory = category;
//
//    m_feedType = CATEGORY;
//    
//    [self startRefresh];
}


#pragma mark - IBAction Methods
- (IBAction)FeedTypeSelect:(UISegmentedControl*)sender{
    if (sender.selectedSegmentIndex == 0) {
        m_feedType = NEARBY;
    }else if (sender.selectedSegmentIndex == 1) {
        m_feedType = POPULAR;
    }else if (sender.selectedSegmentIndex == 2) {
        m_feedType = FOLLOWING;
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

- (IBAction)Search:(id)sender{
    SearchVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchVC"];
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)Explore:(id)sender{
    ExploreVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ExploreVC"];
    [self.navigationController pushViewController:dest animated:YES];
}

@end
