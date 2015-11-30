//
//  FollowerVC.m
//  Glance
//

#import "FollowerVC.h"

#import "FollowersCell.h"

#import "AppDelegate.h"

@interface FollowerVC()<UIGestureRecognizerDelegate>
{
    IBOutlet UIImageView *thumbPhotoView;
    IBOutlet UILabel *nameLabel, *timeLabel, *locLabel;

    IBOutlet UIImageView *ivBackground;
    IBOutlet UILabel *lbTitleMode;

    NSMutableArray * userFollowers;
}

@end
@implementation FollowerVC

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

    ivBackground.image = self.backImage;

    if (self.mode == USER_LIKES) {
        lbTitleMode.text = @"LIKES";
    }
    else if (self.mode == USER_FOLLOWER) {
        lbTitleMode.text = @"FOLLOWERS";
    }
    else {
        lbTitleMode.text = @"FOLLOWINGS";
    }
    
    // user info
    [self getUserInfo:[AppDelegate sharedInstance].userInfo];

    
    [self startRefresh];
 
    UISwipeGestureRecognizer *downSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    downSwipeGestureRecognizer.delaysTouchesEnded = YES;
    downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    downSwipeGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:downSwipeGestureRecognizer];

}
- (void)handleSwipes:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionDown
        && gesture.state == UIGestureRecognizerStateEnded) {
        
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
    
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (void) getUserInfo:(NSDictionary*) userInfo
{
    thumbPhotoView.layer.borderColor = [UIColor whiteColor].CGColor;
    thumbPhotoView.layer.borderWidth = 5;
    thumbPhotoView.layer.cornerRadius = thumbPhotoView.frame.size.height/2.0f;
    thumbPhotoView.clipsToBounds = YES;
    
    
    [thumbPhotoView sd_setImageWithURL:[NSURL URLWithString:[userInfo[@"avatar"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                      placeholderImage:[UIImage imageNamed:@"my_avatar_icon.png"]];
    
    
    nameLabel.text = userInfo[@"username"];
    
    
    if ([userInfo[@"city"] isKindOfClass:[NSDictionary class]]) {
        locLabel.text = [NSString stringWithFormat:@"%@, %@",
                         userInfo[@"city"][@"name"],
                         userInfo[@"city"][@"country_code"]];
    } else {
        locLabel.text = @"";
    }
    
}

- (void)startRefresh
{
    [super startRefresh];
    
    m_offset = 0;
    [self getFeedDatas];
}
- (void)startMoreLoad
{
    m_offset += m_limit;
    if (m_offset < m_total_count) {
        [self getFeedDatas];
        
        [super startMoreLoad];
    }
    else {
        [super disableMoreLoad];
    }
    
}
- (void) doneLoadingTableViewData {
    
    [super doneLoadingTableViewData];
}

- (void) getFeedDatas {
    if (self.mode == USER_FOLLOWER) {
        NSString *urlString = [NSString stringWithFormat:@"user/%@/follower", self.userID];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASICURL,[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        NSDictionary* param = @{@"limit":[NSNumber numberWithInt:m_limit],
                                @"offset":[NSNumber numberWithInt:m_offset]};
        
        FSNConnection *connection = [self sendWebService:url serviceName:@"" parameter:param method:FSNRequestMethodGET];
        [connection start];
    }
    else {
        // etc
        [self doneLoadingTableViewData];
    }
}

#pragma mark - Communication Methods
- (FSNConnection*)sendWebService:(NSURL*)link serviceName:(NSString*)alias parameter:(NSDictionary*)param method:(FSNRequestMethod)Type{
    // to make a successful foursquare api request, add your own api credentials here.
    // for more information see: https://developer.foursquare.com/overview/auth
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    return [FSNConnection withUrl:link
                           method:Type
                          headers:@{@"Authorization":APIKEY}
                       parameters:param
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           
//                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                           
                           
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
                      
                      NSLog(@"%@, %@",c.parseResult, c.description);
                      
//                      [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                      
                      if ([c.parseResult isKindOfClass:[NSMutableDictionary class]]) {
                          
                          NSMutableDictionary *result = (NSMutableDictionary*)c.parseResult;
                          
                          if ([result[@"meta"] isKindOfClass:[NSDictionary class]]) {
                              m_offset = [result[@"meta"][@"offset"] intValue];
                              m_total_count = [result[@"meta"][@"total_count"] intValue];
                          }
                          
                          if ([result[@"objects"] isKindOfClass:[NSArray class]] && [result[@"objects"] count] > 0){
                              
                              if (m_offset == 0) {
                                  userFollowers = [[NSMutableArray alloc] initWithArray:result[@"objects"]];
                              } else {
                                  [userFollowers addObjectsFromArray:result[@"objects"]];
                              }
                              
                          }else{
//                              [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"no results"];
                          }
                          
                      }
                      else {
                          if (userFollowers != nil) {
                              [userFollowers removeAllObjects];
                          }
                      }
                      
                      [self doneLoadingTableViewData];
                      
                  }
                    progressBlock:^(FSNConnection *c) {
                        //                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

#pragma mark - UITableview delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (userFollowers == nil) {
        return 0;
    }
    
    return userFollowers.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 54.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FollowersCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowersCell"];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSMutableDictionary *dic = userFollowers[indexPath.row];
    
    cell.ivAvatar.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.ivAvatar.layer.borderWidth = 3;
    cell.ivAvatar.layer.cornerRadius = cell.ivAvatar.frame.size.height/2.0f;
    cell.ivAvatar.clipsToBounds = YES;
    
    [cell.ivAvatar sd_setImageWithURL:[NSURL URLWithString:[dic[@"avatar"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                             placeholderImage:[UIImage imageNamed:@"my_avatar_icon.png"]];
    
    cell.lbName.text = dic[@"name"];
    
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//}


@end
