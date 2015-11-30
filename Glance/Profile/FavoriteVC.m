//
//  FavoriteVC.m
//  Glance
//
//  Created by Vanguard on 12/29/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import "FavoriteVC.h"

@interface FavoriteVC ()
@property (nonatomic, strong) FSNConnection *connection;

@end

@implementation FavoriteVC
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    favList = [[NSMutableArray alloc] initWithObjects:@"Montreal, Canada", @"Montreal, Canada", @"Montreal, Canada", nil];
    [favTableView setBackgroundColor:[UIColor clearColor]];
    [favTableView setSeparatorColor:[UIColor whiteColor]];
    [favTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}

- (void)viewWillAppear:(BOOL)animated{
    self.connection = nil;
    self.connection =  [self getUserFavCity];
    [self.connection start];
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

#pragma amrk - IBAction methods
- (IBAction)Close:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Delegate & Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return favList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:@"favCell"];
    
    if (!myCell) {
        myCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"favCell"];
    }
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(260, 13, 12, 17)];
    [imgView setImage:[UIImage imageNamed:@"arrow.png"]];
    [myCell addSubview:imgView];
    
    myCell.textLabel.text = @"Montreal, Canada";
    myCell.textLabel.textColor = [UIColor whiteColor];
    myCell.backgroundColor = [UIColor clearColor];
   
    if (favList.count > 0) {
        
    }
    return myCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [favList removeObjectAtIndex:indexPath.row];
        [favTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    return @[deleteAction];
}

// From Master/Detail Xcode template
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [favList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - Commimocation module
- (FSNConnection*)getUserFavCity{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", GETFAVCITY, [[AppDelegate sharedInstance].userInfo objectForKey:@"id"]]];
    
    NSString *token = [[[AppDelegate sharedInstance].userInfo objectForKey:@"auth"] objectForKey:@"token"];
    NSString *user_id = [[AppDelegate sharedInstance].userInfo objectForKey:@"id"];
    NSString *auth = [NSString stringWithFormat:@"%@:%@:%@", APIKEY, user_id, token];
    NSLog(@"auth = %@", auth);
    
    // to make a successful foursquare api request, add your own api credentials here.
    // for more information see: https://developer.foursquare.com/overview/auth
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:auth, @"Authorization", nil];
    
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodGET
                          headers:headers
                       parameters:nil
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
                          NSMutableDictionary *respDict = (NSMutableDictionary*)c.parseResult;
                          if ([respDict objectForKey:@"msg"]) {
                              [[AppDelegate sharedInstance] showAlertMessage:@"" message:[respDict objectForKey:@"msg"]];
                          }
                      }else{
                          
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}


@end
