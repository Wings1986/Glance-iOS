//
//  CommentsVC.m
//  Glance
//
//  Created by Avramov on 3/27/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import "CommentsVC.h"

#import "CommentsCell.h"
#import "NSDate+TimeAgo.h"


@interface CommentsVC ()<UIGestureRecognizerDelegate>
{
    IBOutlet UIImageView *thumbPhotoView;
    IBOutlet UILabel *nameLabel, *timeLabel, *locLabel;
    
    IBOutlet UIView *inputView;
    IBOutlet UITextField *commentTxtField;
    IBOutlet UIImageView *ivBackground;

}

@end

@implementation CommentsVC

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ivBackground.image = self.backImage;
    
    [self startRefresh];
    
    
    // user info
    [self getUserInfo:[AppDelegate sharedInstance].userInfo];
    
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startRefresh
{
    [super startRefresh];
    
    m_offset = 0;
    [self reloadContents];
}
- (void)startMoreLoad
{
    m_offset += m_limit;
    if (m_offset < m_total_count) {
        [self reloadContents];
        
        [super startMoreLoad];
    }
    else {
        [super disableMoreLoad];
    }
    
}
- (void) doneLoadingTableViewData {
    
    [super doneLoadingTableViewData];
}

- (void)reloadContents{
    NSString *urlString = [NSString stringWithFormat:@"video/%@/comment/", _vidID];

//    [[AppDelegate sharedInstance] postResource:@"" andMethod:@"GET" andWithParams:nil andLink:urlString
//                                   AndCallback:^(id result, NSError *error) {
//                   [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                   NSLog(@"%@", result);
//                   
//                   if (result != NULL) {
//                       if ([result[@"objects"] isKindOfClass:[NSArray class]]
//                           || [result[@"objects"] count] > 0) {
//                           self.commentsList = result[@"objects"];
//                           [tblView reloadData];
//                       }
//                   }else{
//                       [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Try again."];
//                   }
//               }];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASICURL,[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSDictionary* param = @{@"limit":[NSNumber numberWithInt:m_limit],
                            @"offset":[NSNumber numberWithInt:m_offset]};
    
    FSNConnection *connection = [self sendWebService:url serviceName:@"" parameter:param method:FSNRequestMethodGET];
    [connection start];
}

#pragma mark - Communication Methods
- (FSNConnection*)sendWebService:(NSURL*)link serviceName:(NSString*)alias parameter:(NSDictionary*)param method:(FSNRequestMethod)Type{
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSLog(@"authData = %@", [AppDelegate sharedInstance].authData);
    
    return [FSNConnection withUrl:link
                           method:Type
                          headers:@{@"Authorization":[AppDelegate sharedInstance].authData}
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
                          
                          if ([alias isEqualToString:@""]) {
                              NSMutableDictionary *result = (NSMutableDictionary*)c.parseResult;
                              
                              if ([result[@"meta"] isKindOfClass:[NSDictionary class]]) {
                                  m_offset = [result[@"meta"][@"offset"] intValue];
                                  m_total_count = [result[@"meta"][@"total_count"] intValue];
                              }
                              
                              if ([result[@"objects"] isKindOfClass:[NSArray class]] && [result[@"objects"] count] > 0){
                                  
                                  if (m_offset == 0) {
                                      self.commentsList = [[NSMutableArray alloc] initWithArray:result[@"objects"]];
                                  } else {
                                      [self.commentsList addObjectsFromArray:result[@"objects"]];
                                  }
                                  
                              }else{
                                  [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"no results"];
                              }
   
                          }
                          
                          if ([alias isEqualToString:@"send"]) {
                              
                              commentTxtField.text = @"";
                              
                              [self startRefresh];
                              
                          }
                          
                      }
                     
                      
                      [self doneLoadingTableViewData];
                      
                  }
                    progressBlock:^(FSNConnection *c) {
                    }];
}



#pragma mark - IBAction methods
- (IBAction)Back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)MakeComment:(id)sender{

    if (commentTxtField.text.length < 1) {
        return;
    }
    
    [commentTxtField resignFirstResponder];
    
    NSString *urlString = [NSString stringWithFormat:@"video/%@/comment/", _vidID];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASICURL,[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSDictionary *param = @{@"text":commentTxtField.text};
    
    FSNConnection *connection = [self sendWebService:url serviceName:@"send" parameter:param method:FSNRequestMethodPOST];
    [connection start];
    
    
//    [[AppDelegate sharedInstance] postResource:@"" andMethod:@"POST" andWithParams:param andLink:urlString
//                                   AndCallback:^(id result, NSError *error) {
//                                       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                                       NSLog(@"%@", result);
//                                       
//                                       if (result != NULL) {
//                                           NSLog(@"successfully done");
//                                           [self startRefresh];
//                                       }else{
//                                           [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Try again."];
//                                       }
//                                   }];


}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Delegate & Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_commentsList == nil) {
        return 0;
    }
    return _commentsList.count;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 64.0f;
//}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentsCell *myCell = [tableView dequeueReusableCellWithIdentifier:@"CommentsCell"];
    
    myCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    NSMutableDictionary *feedItem = [_commentsList objectAtIndex:indexPath.row];

    
    myCell.imgView.layer.borderColor = [UIColor whiteColor].CGColor;
    myCell.imgView.layer.borderWidth = 3;
    myCell.imgView.layer.cornerRadius = myCell.imgView.frame.size.height/2.0f;
    myCell.imgView.clipsToBounds = YES;
    
    [myCell.imgView sd_setImageWithURL:[NSURL URLWithString:[feedItem[@"user"][@"avatar"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                             placeholderImage:[UIImage imageNamed:@"my_avatar_icon.png"]];

    
    UIFont *nameFont = myCell.commentLabel.font;
    UIFont *textFont = myCell.commentLabel.font;
    
    NSString* userName = [NSString stringWithFormat:@"%@ ", feedItem[@"user"][@"username"]];
    NSMutableAttributedString *AattrString = [[NSMutableAttributedString alloc] initWithString:userName attributes: @{NSFontAttributeName:nameFont}];
    [AattrString addAttribute:NSForegroundColorAttributeName value:THEME_COLOR
                        range:(NSMakeRange(0, userName.length))];
    
    NSString * text = feedItem[@"text"];
    NSMutableAttributedString *VattrString = [[NSMutableAttributedString alloc] initWithString: text attributes:@{NSFontAttributeName:textFont}];
    [VattrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1.0f]
                        range:(NSMakeRange(0, text.length))];
    
    [AattrString appendAttributedString:VattrString];
    
    myCell.commentLabel.attributedText = AattrString;

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS"]; //2015-04-07T06:24:30.225935
    NSDate *dateFromString = [dateFormatter dateFromString:feedItem[@"modified_datetime"]];
    myCell.timeLabel.text = [dateFromString dateTimeAgo];
    myCell.timeLabel.textColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
    
    return myCell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}



#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self keyboardWillShow];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self keyboardWillHide];
    [textField resignFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)keyboardWillShow {
    NSLog(@"%f, %f", inputView.frame.origin.y, self.view.frame.size.height - 91);
    // Animate the current view out of the way
    if (inputView.frame.origin.y >= self.view.frame.size.height - 91){
        [self setViewMovedUp:YES];
    }
    else if (inputView.frame.origin.y < self.view.frame.size.height - 91){
        //        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (inputView.frame.origin.y >= self.view.frame.size.height - 91){
        //        [self setViewMovedUp:YES];
    }
    else if (inputView.frame.origin.y < self.view.frame.size.height - 91){
        [self setViewMovedUp:NO];
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = inputView.frame;
    if (movedUp){
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= 250;
    }
    else{
        // revert back to the normal state.
        rect.origin.y += 250;
        //        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    inputView.frame = rect;
    
    [UIView commitAnimations];
}

@end
