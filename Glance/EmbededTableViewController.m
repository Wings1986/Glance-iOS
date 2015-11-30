//
//  EmbededTableViewController.m
//  Glance
//

#import "EmbededTableViewController.h"

#import "ProfileCell.h"
#import "FeedCell.h"

#import "CommentsVC.h"
#import "FollowerVC.h"
#import "ProfileVC.h"
#import <MediaPlayer/MediaPlayer.h>


#import "URBAlertView.h"
#import "NSDate+TimeAgo.h"

#import "VideoPlayerVC.h"


#import "UIImage+Blur.h"


@interface EmbededTableViewController()
{
    NSMutableDictionary * userInfo;
    NSMutableArray *videoFeedList, *moreInfoList;

    BOOL m_bAnimating;
}
@end

@implementation EmbededTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak EmbededTableViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.mTableView addPullToRefreshWithActionHandler:^{
        if (!weakSelf._loading) {
            weakSelf._loading = YES;
            [weakSelf startRefresh];
        }
        
    }];
    
    if (!self.m_bMoreLoad) {
        // setup infinite scrolling
        [self.mTableView addInfiniteScrollingWithActionHandler:^{
            if (!weakSelf._loading) {
                weakSelf._loading = YES;
                [weakSelf startMoreLoad];
            }
        }];
    }
    
}

- (void)startRefresh {
    
    [self.parentController startRefresh];
}

- (void)startMoreLoad {

    [self.parentController startMoreLoad];
}

- (void) disableMoreLoad {
    __weak EmbededTableViewController *weakSelf = self;
    
    [weakSelf.mTableView.infiniteScrollingView stopAnimating];
    weakSelf._loading = NO;
}
- (void) doneLoadingTableViewData:(NSArray*) arryData
{
    videoFeedList = [arryData mutableCopy];
    
    moreInfoList = [[NSMutableArray alloc] init];
    for (int i=0; i<videoFeedList.count; i++) {
        NSMutableDictionary *heightInfo = [[NSMutableDictionary alloc] init];
        [heightInfo setObject:[NSNumber numberWithInt:i] forKey:@"index"];
        [heightInfo setObject:[NSNumber numberWithBool:NO] forKey:@"enable_more"];
        [moreInfoList addObject:heightInfo];
    }
    
    
    __weak EmbededTableViewController *weakSelf = self;
    
    //    [weakSelf.mTableView beginUpdates];
    //
    //    [weakSelf.mTableView endUpdates];
    [weakSelf.mTableView reloadData];
    
    [weakSelf.mTableView.pullToRefreshView stopAnimating];
    [weakSelf.mTableView.infiniteScrollingView stopAnimating];
    
    weakSelf._loading = NO;
}

- (void) setUserInfo:(NSDictionary*) info
{
    userInfo = [info mutableCopy];
    
    // refresh locally
    [self.mTableView reloadData];
}
- (void) setNumberOfFollower:(NSNumber*) followers
{
    userInfo[@"followers"] = followers;

    // refresh locally
    [self.mTableView reloadData];
}
- (void) setNumberOfFollowing:(NSNumber*) following
{
    userInfo[@"following"] = following;
    
    // refresh locally
    [self.mTableView reloadData];
}

#pragma mark - more action for feed video
- (void)more:(UIGestureRecognizer*) gesture{
    
    if ((gesture.state != UIGestureRecognizerStateBegan && [gesture isKindOfClass:[UILongPressGestureRecognizer class]])
        || (gesture.state != UIGestureRecognizerStateEnded && [gesture isKindOfClass:[UITapGestureRecognizer class]])) {
        return;
    }
    
    NSInteger index = [gesture.view tag];
    NSMutableDictionary *heightDict = [moreInfoList objectAtIndex:index];
    
    BOOL oldEnable = [heightDict[@"enable_more"] boolValue];
    
    if ([heightDict[@"enable_more"] boolValue] == NO) {
        [heightDict setObject:[NSNumber numberWithBool:YES] forKey:@"enable_more"];
        [moreInfoList replaceObjectAtIndex:index withObject:heightDict];
        
    }else{
        [heightDict setObject:[NSNumber numberWithBool:NO] forKey:@"enable_more"];
        [moreInfoList replaceObjectAtIndex:index withObject:heightDict];
    }
    
    
    FeedCell* cell = (FeedCell*)[self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
    
    if (oldEnable == NO) {
        [self setBlueImage:cell image:cell.imgView.image];
    }
    
    cell.moreView.hidden = !oldEnable;
    cell.moreView.alpha = oldEnable ? 1.0f : 0.0f;
    
    [UIView animateWithDuration:0.5 animations:^{
        cell.moreView.alpha = oldEnable ? 0.0f : 1.0f;
    } completion:^(BOOL finished) {
        cell.moreView.hidden = oldEnable;
    }];
    
}


- (void)shareVideo:(id)sender{
    NSMutableDictionary *feedItem = [videoFeedList objectAtIndex:[sender tag]];
    
    //    NSURL *myWebsite = [NSURL URLWithString:feedItem[@"video"]];
    NSArray *objectsToShare = @[[NSString stringWithFormat:@"%@\n%@", feedItem[@"headline"], feedItem[@"video"]]];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)commentVideo:(id)sender{
    
    NSDictionary *videoObj = videoFeedList[[sender tag]];
    
    CommentsVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentsVC"];
    dest.backImage = [[AppDelegate sharedInstance] getScreencapture];
    dest.vidID = videoObj[@"id"];
    [self presentViewController:dest animated:NO completion:nil];
}


- (void)likeList:(UIGestureRecognizer*)gesture{
    
    NSDictionary *videoObj = videoFeedList[[gesture.view tag]];
    
    FollowerVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowerVC"];
    dest.userID = videoObj[@"user"][@"id"];
    dest.mode = USER_LIKES;
    dest.backImage = [[AppDelegate sharedInstance] getScreencapture];
    [self presentViewController:dest animated:NO completion:nil];
}
- (void)followerList:(UIButton*)gesture{
    
    // profile user's follower list
    FollowerVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowerVC"];
    dest.userID = userInfo[@"id"];
    dest.mode = USER_FOLLOWER;
    dest.backImage = [[AppDelegate sharedInstance] getScreencapture];
    [self presentViewController:dest animated:NO completion:nil];
}
- (void)followingList:(UIButton*)gesture{
    
    // profile user's following list
    FollowerVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowerVC"];
    dest.userID = userInfo[@"id"];
    dest.mode = USER_FOLLOWING;
    dest.backImage = [[AppDelegate sharedInstance] getScreencapture];
    [self presentViewController:dest animated:NO completion:nil];
}


- (void)likeVideo:(id)sender{
    NSInteger index = [sender tag];
    NSMutableDictionary *feedItem = [videoFeedList[index] mutableCopy];
    
    NSString *urlString = [[NSString stringWithFormat:@"%@/video/%@/like/", BASICURL, feedItem[@"id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"url = %@", urlString);
    NSLog(@"authdata = %@", [AppDelegate sharedInstance].authData);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].authData forHTTPHeaderField:@"Authorization"];
    
    if (feedItem[@"didlike"] != nil && [feedItem[@"didlike"] boolValue]) { // delete
        
        [manager DELETE:urlString parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  NSDictionary * result = (NSDictionary*)responseObject;
                  NSLog(@"result = %@", result);
                  
                  
                  if (result != NULL) {
                      NSLog(@"successfully done");
                      
                      feedItem[@"didlike"] = [NSNumber numberWithBool:NO];
                      feedItem[@"likes"] = [NSNumber numberWithInt: [feedItem[@"likes"] intValue] - 1];
                      
                      [videoFeedList replaceObjectAtIndex:index withObject:feedItem];
                      
                      [self.mTableView reloadData];
                      
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
                      
                      feedItem[@"didlike"] = [NSNumber numberWithBool:YES];
                      feedItem[@"likes"] = [NSNumber numberWithInt: [feedItem[@"likes"] intValue] + 1];
                      
                      [videoFeedList replaceObjectAtIndex:index withObject:feedItem];
                      
                      [self.mTableView reloadData];
                      
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  
                  NSLog(@"error = %@", error.description);

                  feedItem[@"didlike"] = [NSNumber numberWithBool:YES];
                  feedItem[@"likes"] = [NSNumber numberWithInt: [feedItem[@"likes"] intValue] + 1];
                  
                  [videoFeedList replaceObjectAtIndex:index withObject:feedItem];
                  
                  [self.mTableView reloadData];

              }];
        
    }

    
    
    
//    [[AppDelegate sharedInstance] postResource:@"like" andMethod:method andWithParams:nil andLink:urlString
//                                   AndCallback:^(id result, NSError *error) {
//                                       
//                                       NSLog(@"%@", result);
//                                       
//                                       if (result != NULL) {
//                                           NSLog(@"successfully done");
//
//                                           if ([method isEqualToString:@"POST"]) {
//                                               feedItem[@"didlike"] = [NSNumber numberWithBool:YES];
//                                               feedItem[@"likes"] = [NSNumber numberWithInt: [feedItem[@"likes"] intValue] + 1];
//                                           }
//                                           else {
//                                               feedItem[@"didlike"] = [NSNumber numberWithBool:NO];
//                                               feedItem[@"likes"] = [NSNumber numberWithInt: [feedItem[@"likes"] intValue] - 1];
//                                           }
//                                           
//                                           [videoFeedList replaceObjectAtIndex:index withObject:feedItem];
//                                           
//                                           [self.mTableView reloadData];
//                                           
//                                       }
//                                   }];
    
    
}


- (void)playVideo:(UIGestureRecognizer*) gesture{
    NSMutableDictionary *feedItem = [videoFeedList objectAtIndex:[gesture.view tag]];

    VideoPlayerVC * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayerVC"];
    vc.feedItem = [feedItem mutableCopy];
    
//    [self presentViewController:vc animated:YES completion:^{
//        
//    }];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    
//    PBJVideoPlayerController *videoController = [[PBJVideoPlayerController alloc] init];
//    videoController.delegate = self;
//    videoController.videoPath = feedItem[@"video"];
////    videoController.videoView.transform = CGAffineTransformConcat(videoController.videoView.transform, CGAffineTransformMakeRotation(M_PI_2));
////    [videoController.videoView setFrame: self.view.bounds];
//    
//    videoController.videoFillMode = AVLayerVideoGravityResizeAspect; //AVLayerVideoGravityResize;
//    [MBProgressHUD showHUDAddedTo:videoController.view animated:YES];
//    [self presentViewController:videoController animated:NO completion:nil];
//    [videoController playFromBeginning];
}

- (void)reportVideo:(id)sender{
    NSMutableDictionary *videoObj = [videoFeedList objectAtIndex:[sender tag]];
    
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
                        
                        NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@/video/%@/report/", BASICURL, videoObj[@"id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        
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

- (void)userProfile:(UIGestureRecognizer*) gesture{
    NSMutableDictionary *feedItem = [videoFeedList objectAtIndex:[gesture.view tag]];
    ProfileVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileVC"];
    dest.bOtherProfile = YES;
    dest.userInfo = feedItem[@"user"];
    
    [self.navigationController pushViewController:dest animated:YES];
}


#pragma mark WEB SERVICE
- (FSNConnection*)sendWebService:(NSURL*)link serviceName:(NSString*)alias parameter:(NSDictionary*)param method:(FSNRequestMethod)Type extra:(id)info{
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

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
                      
//                      [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                      
                      if ([alias isEqualToString:@"report"]) {
                          [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Reported Successfully"];
                      }
                  }

                    progressBlock:^(FSNConnection *c) {
                    }];
}



#pragma mark - UITableView delegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (section == 0) {
        if (userInfo == nil) {
            return 0;
        }
        return 1;
    }
    else {
        if (videoFeedList == nil) {
            return 0;
        }
        return videoFeedList.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        if (userInfo == nil) {
            return 0;
        }
        else {
            return 182.0f;
        }
    }
    else {
        return 320;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        ProfileCell *myCell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
        myCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        myCell.profImgView.layer.borderColor = [UIColor whiteColor].CGColor;
        myCell.profImgView.layer.borderWidth = 5;
        myCell.profImgView.layer.cornerRadius = myCell.profImgView.frame.size.height/2.0f;
        myCell.profImgView.clipsToBounds = YES;
        
        
        [myCell.profImgView sd_setImageWithURL:[NSURL URLWithString:[userInfo[@"avatar"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                       placeholderImage:[UIImage imageNamed:@"my_avatar_icon.png"]];
        
        
        myCell.nameLabel.text = [NSString stringWithFormat:@"%@ %@",
                          userInfo[@"first_name"],
                          userInfo[@"last_name"]];
        
        myCell.bioLabel.text = userInfo[@"bio"];
        
        if ([userInfo[@"city"] isKindOfClass:[NSDictionary class]]) {
            myCell.cityLabel.text = [NSString stringWithFormat:@"%@, %@",
                              userInfo[@"city"][@"name"],
                              userInfo[@"city"][@"country_code"]];
        } else {
            myCell.cityLabel.text = @"";
        }
        
        
        if (![userInfo[@"followers"] isKindOfClass:[NSNull class]]) {
            myCell.followersLabel.text = [NSString stringWithFormat:@"%d", [userInfo[@"followers"] intValue]] ;
        } else {
            myCell.followersLabel.text = @"0";
        }

        if (![userInfo[@"following"] isKindOfClass:[NSNull class]]) {
            myCell.numFollowLabel.text = [NSString stringWithFormat:@"%d", [userInfo[@"following"] intValue]] ;
        } else {
            myCell.numFollowLabel.text = @"0";
        }

        [myCell.btnFollewerList addTarget:self action:@selector(followerList:) forControlEvents:UIControlEventTouchUpInside];
        myCell.btnFollewerList.tag = indexPath.row;

        [myCell.btnFollowingList addTarget:self action:@selector(followingList:) forControlEvents:UIControlEventTouchUpInside];
        myCell.btnFollowingList.tag = indexPath.row;
        
        
        
        return myCell;
    }
    else {
        FeedCell *myCell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];
        myCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        NSMutableDictionary *feedItem = [videoFeedList objectAtIndex:indexPath.row];
        
        
        //profile thumbnail photo
        myCell.thumbPhotoView.layer.borderColor = [UIColor whiteColor].CGColor;
        myCell.thumbPhotoView.layer.borderWidth = 3;
        myCell.thumbPhotoView.layer.cornerRadius = myCell.thumbPhotoView.frame.size.height/2.0f;
        myCell.thumbPhotoView.clipsToBounds = YES;
        
        [myCell.thumbPhotoView sd_setImageWithURL:[NSURL URLWithString:[feedItem[@"user"][@"avatar"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                 placeholderImage:[UIImage imageNamed:@"my_avatar_icon.png"]];
        
        
        myCell.nameLabel.text = feedItem[@"user"][@"username"];
        
        
        // days ago
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS"]; //2015-04-07T06:24:30.225935
        NSDate *dateFromString = [dateFormatter dateFromString:feedItem[@"created_datetime"]];
        myCell.timeLabel.text = [dateFromString dateTimeAgo];
        
        myCell.locLabel.text = [NSString stringWithFormat:@"%@, %@", feedItem[@"city"][@"pretty_name"], feedItem[@"city"][@"country_code"]];
        
        //main photo
        myCell.loading.hidden = NO;
        [myCell.loading startAnimating];
        [myCell.imgView sd_setImageWithURL:[NSURL URLWithString:[feedItem[@"thumbnail"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                          placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     myCell.loading.hidden = YES;
                                     [myCell.loading stopAnimating];
                                     
                                     
                                     if ([moreInfoList[indexPath.row][@"enable_more"] boolValue]) {
                                         [self setBlueImage:myCell image:image];
                                     }
                                     
                                 }
         ];
        
        NSString * category = feedItem[@"category"];
        if ([category isEqualToString:@"News"]) {
            myCell.ivCategory.image = [UIImage imageNamed:@"icon_category_news.png"];
        } else if ([category isEqualToString:@"Events"]) {
            myCell.ivCategory.image = [UIImage imageNamed:@"icon_category_events.png"];
        } else if ([category isEqualToString:@"Travel"]) {
            myCell.ivCategory.image = [UIImage imageNamed:@"icon_category_travel.png"];
        } else if ([category isEqualToString:@"Sports"]) {
            myCell.ivCategory.image = [UIImage imageNamed:@"icon_category_sports.png"];
        } else if ([category isEqualToString:@"Music"]) {
            myCell.ivCategory.image = [UIImage imageNamed:@"icon_category_music.png"];
        } else if ([category isEqualToString:@"Arts"]) {
            myCell.ivCategory.image = [UIImage imageNamed:@"icon_category_arts.png"];
        } else if ([category isEqualToString:@"Nightlife"]) {
            myCell.ivCategory.image = [UIImage imageNamed:@"icon_category_nightlife.png"];
        } else if ([category isEqualToString:@"Outings"] || [category isEqualToString:@"Entertainment"]) {
            myCell.ivCategory.image = [UIImage imageNamed:@"icon_category_outings.png"];
        } else if ([category isEqualToString:@"Fashion"]) {
            myCell.ivCategory.image = [UIImage imageNamed:@"icon_category_fashion.png"];
        }
        
        myCell.descLabel.text = [feedItem objectForKey:@"headline"];
        
        myCell.commentsLabel.text = [[feedItem objectForKey:@"comments"] stringValue];
        myCell.likeLabel.text = [[feedItem objectForKey:@"likes"] stringValue];
        
        
        // hide more view according to the status
        if ([moreInfoList[indexPath.row][@"enable_more"] boolValue] == NO) {
            [myCell.moreView setHidden:YES];
        }else{
            [myCell.moreView setHidden:NO];
        }
        
        
        [myCell.likeButton setImage:[UIImage imageNamed:@"like-button.png"] forState:UIControlStateNormal];
        if (feedItem[@"didlike"] != nil && ![feedItem[@"didlike"] isKindOfClass:[NSNull class]]) {
            if ([feedItem[@"didlike"] boolValue]) {
                [myCell.likeButton setImage:[UIImage imageNamed:@"like-button-tapped.png"] forState:UIControlStateNormal];
            }
        }
        
        
        //link action to buttons with index
        [myCell.thumbPhotoView setUserInteractionEnabled:YES];
        [myCell.thumbPhotoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfile:)]];
        
        myCell.nameLabel.userInteractionEnabled = YES;
        [myCell.nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfile:)]];
        
        [myCell.imgView setUserInteractionEnabled:YES];
        [myCell.imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo:)]];
        
        [myCell.imgView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(more:)]];
        
        [myCell.commentButton addTarget:self action:@selector(commentVideo:) forControlEvents:UIControlEventTouchUpInside];
        [myCell.likeButton addTarget:self action:@selector(likeVideo:) forControlEvents:UIControlEventTouchUpInside];
        [myCell.likeButton addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(likeList:)]];
        
        [myCell.shareButton addTarget:self action:@selector(shareVideo:) forControlEvents:UIControlEventTouchUpInside];
        [myCell.reportButton addTarget:self action:@selector(reportVideo:) forControlEvents:UIControlEventTouchUpInside];
        
        myCell.imgBlurMoreView.userInteractionEnabled = YES;
        [myCell.imgBlurMoreView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(more:)]];
        
        myCell.thumbPhotoView.tag = indexPath.row;
        myCell.nameLabel.tag = indexPath.row;
        myCell.imgView.tag = indexPath.row;
        myCell.commentButton.tag = indexPath.row;
        myCell.likeButton.tag = indexPath.row;
        myCell.shareButton.tag = indexPath.row;
        myCell.reportButton.tag = indexPath.row;
        myCell.imgBlurMoreView.tag = indexPath.row;
        
        
        // initial hide
        [self showCellDetail:NO cell:myCell];
        
        return myCell;
    }
}


- (void) setBlueImage:(FeedCell*) myCell image:(UIImage*) image
{
    // jpeg quality image data
    float quality = .00001f;
    
    // intensity of blurred
    float blurred = .8f;
    
    NSData *imageData = UIImageJPEGRepresentation(image, quality);
    UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:blurred];
    myCell.imgBlurMoreView.image = blurredImage;
}

- (void) showCellDetail:(BOOL) show cell:(FeedCell*) myCell
{
    if (show) {
        myCell.userlocationView.hidden = NO;
        myCell.thumbPhotoView.hidden = NO;
        myCell.nameLabel.hidden = NO;
        myCell.timeLabel.hidden = NO;
        myCell.ivCategory.hidden = NO;
        myCell.commentButton.hidden = NO;
        myCell.commentsLabel.hidden = NO;
    }
    else {
        myCell.userlocationView.hidden = YES;
        myCell.thumbPhotoView.hidden = YES;
        myCell.nameLabel.hidden = YES;
        myCell.timeLabel.hidden = YES;
        myCell.ivCategory.hidden = YES;
        myCell.commentButton.hidden = YES;
        myCell.commentsLabel.hidden = YES;
    }
}

- (void) checkFullCell:(FeedCell*) cell
{

    CGRect rtShowed = CGRectMake(self.mTableView.contentOffset.x, self.mTableView.contentOffset.y, self.mTableView.frame.size.width, self.mTableView.frame.size.height);
    
//    if (CGRectContainsRect(rtShowed, cell.frame))
    
    if ([self isCrossRectGood:rtShowed inRect:cell.frame]) {
        [self showCellDetail:YES cell:cell];
    }
    else {
        [self showCellDetail:NO cell:cell];
    }
}

-(BOOL) isCrossRectGood:(CGRect) rtOut inRect:(CGRect) rtIn
{
    if (CGRectGetHeight(rtOut) + CGRectGetHeight(rtIn) - (MAX(CGRectGetMaxY(rtIn), CGRectGetMaxY(rtOut)) - MIN(CGRectGetMinY(rtOut), CGRectGetMinY(rtIn))) > CGRectGetHeight(rtOut) * 0.5f) {
        return YES;
    }
    return NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSArray *paths = [self.mTableView indexPathsForVisibleRows];
    
    for (NSIndexPath *path in paths) {
        UITableViewCell * myCell = [self.mTableView cellForRowAtIndexPath:path];
        if ([myCell isKindOfClass:[FeedCell class]]) {
            [self showCellDetail:NO cell:(FeedCell*)myCell];
        }
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (m_bAnimating) {
        return;
    }
    
    NSArray *paths = [self.mTableView indexPathsForVisibleRows];
    
    for (NSIndexPath *path in paths) {
        UITableViewCell * myCell = [self.mTableView cellForRowAtIndexPath:path];
        if ([myCell isKindOfClass:[FeedCell class]]) {
            [self checkFullCell:(FeedCell*)myCell];
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    m_bAnimating = YES;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    m_bAnimating = NO;
    
    NSArray *paths = [self.mTableView indexPathsForVisibleRows];
    
    for (NSIndexPath *path in paths) {
        UITableViewCell * myCell = [self.mTableView cellForRowAtIndexPath:path];
        if ([myCell isKindOfClass:[FeedCell class]]) {
            [self checkFullCell:(FeedCell*)myCell];
        }
    }
    
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//}



@end

