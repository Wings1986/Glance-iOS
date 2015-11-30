//
//  SearchDetailVC.m
//  Glance
//



#import "SearchDetailVC.h"


#import "AppDelegate.h"

#import "UIViewController+MJPopupViewController.h"
#import "ChooseCategoryDlg.h"

#import "EmbededTableViewController.h"



@interface SearchDetailVC ()<ChooseCategoryDlgDelegate>
{
    IBOutlet UILabel *lbTitle;
    
    ChooseCategoryDlg * categoryDlg;
    NSString * m_chooseCategory;
    
    EmbededTableViewController * containController;

}

@end

@implementation SearchDetailVC

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    lbTitle.text = self.m_title;
    
    [self startRefresh];
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
    
    if ([segue.identifier isEqualToString:@"embed_feed"]) {
        containController = segue.destinationViewController;
        containController.parentController = self;
    }
    
}


- (void)startRefresh
{
    m_offset = 0;
    [self getFeedDatas];
}
- (void)startMoreLoad
{
    m_offset += m_limit;
    if (m_offset < m_total_count) {
        [self getFeedDatas];
    }
    else {
        [containController disableMoreLoad];
    }
    
}
- (void) doneLoadingTableViewData {
    
    [containController doneLoadingTableViewData:(NSArray*)videoFeedList];
}

- (void) getFeedDatas {
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    param[@"limit"] = [NSNumber numberWithInt:m_limit];
    param[@"offset"] = [NSNumber numberWithInt:m_offset];
    
    
    NSString *urlString;
    
    if (self.feedType == CITY) {
        urlString = @"video/city/";

        param[@"city"] = self.m_id;
    }
    else { // tag
        urlString = @"video/tag/";
        
        param[@"name__icontains"] = self.m_id;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASICURL,[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    FSNConnection *connection = [self sendWebService:url serviceName:@"" parameter:param method:FSNRequestMethodGET extra:nil];
    [connection start];

}



- (FSNConnection*)sendWebService:(NSURL*)link serviceName:(NSString*)alias parameter:(NSDictionary*)param method:(FSNRequestMethod)Type extra:(NSString*)info{
    
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
                      
                      if ([alias isEqualToString:@""]) {
                          if ([c.parseResult isKindOfClass:[NSMutableDictionary class]]) {
                              
                              NSMutableDictionary *result = (NSMutableDictionary*)c.parseResult;
                              
                              if ([result[@"meta"] isKindOfClass:[NSDictionary class]]) {
                                  m_offset = [result[@"meta"][@"offset"] intValue];
                                  m_total_count = [result[@"meta"][@"total_count"] intValue];
                              }
                              
                              if ([result[@"objects"] isKindOfClass:[NSArray class]] && [result[@"objects"] count] > 0){
                                  
                                  if (m_offset == 0) {
                                      videoFeedList = [[NSMutableArray alloc] initWithArray:result[@"objects"]];
                                  } else {
                                      [videoFeedList addObjectsFromArray:result[@"objects"]];
                                  }
                                  
                              }else{
                                  [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"no results"];
                              }
                              
                          }
                          else {
                              if (videoFeedList != nil) {
                                  [videoFeedList removeAllObjects];
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
    
    categoryDlg = [[ChooseCategoryDlg alloc] initWithNibName:@"ChooseCategoryDlg" bundle:nil];
    categoryDlg.delegate = self;
    [self presentPopupViewController:categoryDlg animationType:MJPopupViewAnimationFade];
}
- (void) chooseCategory:(NSString *)category
{
    m_chooseCategory = category;

    [self startRefresh];
}

@end
