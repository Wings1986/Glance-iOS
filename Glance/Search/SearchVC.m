//
//  SearchVC.m
//  Glance
//

#import "SearchVC.h"

#import "SearchCell.h"

#import "ProfileVC.h"
#import "SearchDetailVC.h"


typedef enum{
    STATUS_CITY = 0,
    STATUS_TAG,
    STATUS_USER
}SEARCHSTATUS;

BOOL bEmpty;

@interface SearchVC ()
{
    SEARCHSTATUS m_status;
    
    NSMutableArray * cityList;
    NSMutableArray * tagList;
    NSMutableArray * userList;
}
@end

@implementation SearchVC

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    m_status = STATUS_CITY;
    
    [self getFeedDatas:STATUS_CITY];
    [self getFeedDatas:STATUS_TAG];
    [self getFeedDatas:STATUS_USER];
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startRefresh
{
    [super startRefresh];
    
    m_offset = 0;
    [self getFeedDatas:m_status];
}
- (void)startMoreLoad
{
    m_offset += m_limit;
    if (m_offset < m_total_count) {
        [self getFeedDatas:m_status];

        [super startMoreLoad];
    }
    else {
        [super disableMoreLoad];
    }
    
}
- (void) doneLoadingTableViewData {
    
    if (m_status == STATUS_CITY) {
        feedList = [cityList mutableCopy];
    }
    else if (m_status == STATUS_TAG) {
        feedList = [tagList mutableCopy];
    }
    else if (m_status == STATUS_USER) {
        feedList = [userList mutableCopy];
    }
    
    [super doneLoadingTableViewData];
}

- (void) getFeedDatas :(SEARCHSTATUS) status{
    NSString *urlString;
    
    if (status == STATUS_CITY) {
        if (mSearchBar.text.length < 1) {
            urlString = @"city/";
        } else {
            urlString = [NSString stringWithFormat:@"city/?name__icontains=%@&videos=true", mSearchBar.text];
        }
    }
    else if (status == STATUS_TAG) {
        if (mSearchBar.text.length < 1) {
            urlString = @"tag/";
        } else {
            urlString = [NSString stringWithFormat:@"tag/?name__icontains=%@", mSearchBar.text];
        }
    }
    else if (status == STATUS_USER) {
        if (mSearchBar.text.length < 1) {
            urlString = @"user/";
        } else {
            urlString = [NSString stringWithFormat:@"user/?username__icontains=%@", mSearchBar.text];
        }
    }
    else {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASICURL,[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSDictionary* param = @{@"limit":[NSNumber numberWithInt:m_limit],
                            @"offset":[NSNumber numberWithInt:m_offset]};
    
    FSNConnection *connection = [self sendWebService:url serviceName:[NSString stringWithFormat:@"%d", status] parameter:param method:FSNRequestMethodGET];
    [connection start];
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
                              
                              NSMutableArray * objs = [result[@"objects"] mutableCopy];
                              
                              if (m_offset == 0) {
//                                  feedList = [[NSMutableArray alloc] initWithArray:result[@"objects"]];
                                  if ([alias isEqualToString:@"0"]) {
                                      cityList = [objs mutableCopy];
                                  }
                                  else if ([alias isEqualToString:@"1"]) {
                                      tagList = [objs mutableCopy];
                                  }
                                  else if ([alias isEqualToString:@"2"]) {
                                      userList = [objs mutableCopy];
                                  }
                              } else {
//                                  [feedList addObjectsFromArray:result[@"objects"]];
                                  if ([alias isEqualToString:@"0"]) {
                                      [cityList addObjectsFromArray:objs];
                                  }
                                  else if ([alias isEqualToString:@"1"]) {
                                      [tagList addObjectsFromArray:objs];
                                  }
                                  else if ([alias isEqualToString:@"2"]) {
                                      [userList addObjectsFromArray:objs];
                                  }
                              }
                              
                          }else{
                              [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"no results"];
                          }
                          
                      }
                     
                      
                      [self doneLoadingTableViewData];

                  }
                    progressBlock:^(FSNConnection *c) {
//                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"goto_detail"]) {
        SearchDetailVC * vc = segue.destinationViewController;
        
        if (m_status == STATUS_CITY) {
            vc.m_title =  [NSString stringWithFormat:@"%@, %@", sender[@"pretty_name"], sender[@"country_code"]] ;
            vc.m_id = sender[@"id"];
            vc.feedType = CITY;
        }
        else if (m_status == STATUS_TAG) {
            vc.m_title =  sender[@"name"];
            vc.m_id = sender[@"id"];
            vc.feedType = TAG;
        }
    }
    else if ([segue.identifier isEqualToString:@"goto_profile"]) {
        ProfileVC * vc = segue.destinationViewController;
        
        vc.bOtherProfile = YES;
        vc.userInfo = sender;
    }
}


#pragma mark - IBAction methods
- (IBAction)Close:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)SearchTypeSelect:(UISegmentedControl*)sender{
    if (sender.selectedSegmentIndex == 0) {
        m_status = STATUS_CITY;
    }else if (sender.selectedSegmentIndex == 1) {
        m_status = STATUS_TAG;
        
    }else if (sender.selectedSegmentIndex == 2) {
        m_status = STATUS_USER;
    }
    
    mSearchBar.text = @"";
    
    [self doneLoadingTableViewData];

    @try {
        [self.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    [self startRefresh];
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [mSearchBar resignFirstResponder];
}

#pragma mark - search bar delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton: YES animated: YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton: NO animated: YES];
    [searchBar resignFirstResponder];
    
    searchBar.text = @"";
    
    [self startRefresh];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton: NO animated: YES];
    [searchBar resignFirstResponder];
    
    [self startRefresh];
}

#pragma mark - UITableview delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (feedList == nil) {
        return 0;
    }
    
    return feedList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSMutableDictionary *dic = feedList[indexPath.row];
    
    
    if (m_status == STATUS_CITY) {
        NSString *cityName = [NSString stringWithFormat:@"%@, ", dic[@"pretty_name"]] ;
        NSString *countryName = dic[@"country_code"];
        
        UIFont *nameFont = cell.lbTitle.font;
        UIFont *textFont = cell.lbTitle.font;
        
        NSMutableAttributedString *AattrString = [[NSMutableAttributedString alloc] initWithString:cityName attributes: @{NSFontAttributeName:nameFont}];
        [AattrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:178.0f/255.0f green:178.0f/255.0f blue:178.0f/255.0f alpha:1.0f]
                            range:(NSMakeRange(0, cityName.length))];
        
        NSMutableAttributedString *VattrString = [[NSMutableAttributedString alloc] initWithString: countryName attributes:@{NSFontAttributeName:textFont}];
        [VattrString addAttribute:NSForegroundColorAttributeName value:THEME_COLOR
                            range:(NSMakeRange(0, countryName.length))];
        
        [AattrString appendAttributedString:VattrString];
        
        cell.lbTitle.attributedText = AattrString;
        
    }else if (m_status == STATUS_TAG) {
        NSString *tagName = dic[@"name"];
        cell.lbTitle.text = [NSString stringWithFormat:@"%@", tagName];
        
    }else { // m_status == STATUS_USER
//        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        NSString *userName = dic[@"username"];
        cell.lbTitle.text = [NSString stringWithFormat:@"%@", userName];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSMutableDictionary *tempDict = feedList[indexPath.row];
    NSLog(@"%@", tempDict);
    
    if (m_status == STATUS_CITY
        || m_status == STATUS_TAG) {
        
        [self performSegueWithIdentifier:@"goto_detail" sender:tempDict];
        
    }else { // m_status == STATUS_USER
        
        [self performSegueWithIdentifier:@"goto_profile" sender:tempDict];
    }
}

@end
