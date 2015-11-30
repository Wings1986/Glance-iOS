//
//  ShareVC.m
//  Glance
//
//  Created by Avramov on 3/25/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import "ShareVC.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "PBJVideoPlayerController.h"

@interface ShareVC ()<PBJVideoPlayerControllerDelegate>

@end

@implementation ShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [ivThumbnail setImage:self.thumbImage];
    categoryLabel.text = self.category;
    
    
    PBJVideoPlayerController *videoPlayerController = [[PBJVideoPlayerController alloc] init];
    videoPlayerController.delegate = self;
    videoPlayerController.view.frame = self.view.bounds;
    
    [self addChildViewController:videoPlayerController];
    [self.view insertSubview:videoPlayerController.view atIndex:1];
    [videoPlayerController didMoveToParentViewController:self];
    
    videoPlayerController.videoPath = self.videoPath;
    videoPlayerController.videoFillMode = AVLayerVideoGravityResizeAspectFill;
    
    [videoPlayerController playFromBeginning];

    
    [self reverseGeocoding];
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

#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    NSLog(@"Max duration of the video: %f", videoPlayer.maxDuration);
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    if (videoPlayer.playbackState == PBJVideoPlayerPlaybackStatePlaying) {
    }
    else if (videoPlayer.playbackState == PBJVideoPlayerPlaybackStatePaused) {
    }
    
}

- (void)videoPlayerBufferringStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    switch (videoPlayer.bufferingState) {
        case PBJVideoPlayerBufferingStateUnknown:
            NSLog(@"Buffering state unknown!");
            break;
            
        case PBJVideoPlayerBufferingStateReady:
            NSLog(@"Buffering state Ready! Video will start/ready playing now.");
            break;
            
        case PBJVideoPlayerBufferingStateDelayed:
            NSLog(@"Buffering state Delayed! Video will pause/stop playing now.");
            [videoPlayer playFromCurrentTime];
            break;
    }
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    [videoPlayer playFromBeginning];
}


- (void)reverseGeocoding{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *newLocation = [[CLLocation alloc]
                               initWithLatitude:[AppDelegate sharedInstance].startLocation.coordinate.latitude
                               longitude:[AppDelegate sharedInstance].startLocation.coordinate.longitude];
    
    [geocoder reverseGeocodeLocation:newLocation
                   completionHandler:^(NSArray *placemarks,
                                       NSError *error) {
                       
                       if (error) {
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       
                       if (placemarks && placemarks.count > 0)
                       {
                           CLPlacemark *placemark = placemarks[0];
                           
                           locInfoView.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.ISOcountryCode];

                       }
                   }];
}


#pragma markr - IBAction methods
- (IBAction)Facebook:(id)sender{
    SLComposeViewController *fbComposer =
    [SLComposeViewController
     composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=
        ^(SLComposeViewControllerResult result){
            
            [fbComposer dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.....");
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted....");
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sent"
                                                                     message:nil
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Dismiss"
                                                           otherButtonTitles: nil];
                    [alert show];
                }
                    break;
            }};
        
        [fbComposer setInitialText:descTxtView.text];
        [fbComposer addImage:_thumbImage];
        [fbComposer addURL:[NSURL URLWithString:_videoPath]];
        [fbComposer setCompletionHandler:completionHandler];
        [self presentViewController:fbComposer animated:YES completion:nil];
    }
}

- (IBAction)Twitter:(id)sender{
    SLComposeViewController *twComposer =
    [SLComposeViewController
     composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=
        ^(SLComposeViewControllerResult result){
            
            [twComposer dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.....");
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted....");
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sent"
                                                                     message:nil
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Dismiss"
                                                           otherButtonTitles: nil];
                    [alert show];
                }
                    break;
            }};
        
        [twComposer setInitialText:descTxtView.text];
        [twComposer addImage:_thumbImage];
        [twComposer addURL:[NSURL URLWithString:_videoPath]];
        [twComposer setCompletionHandler:completionHandler];
        [self presentViewController:twComposer animated:YES completion:nil];
    }
}


- (IBAction)Done:(id)sender{
    
    NSString *latString = [NSString stringWithFormat:@"%f", [AppDelegate sharedInstance].startLocation.coordinate.latitude];
    NSString *lonString = [NSString stringWithFormat:@"%f", [AppDelegate sharedInstance].startLocation.coordinate.longitude];
    
    [self postResource:@"" andMethod:@"POST" andWithParams:@{@"lat": latString,
                                                             @"lng": lonString,
                                                             @"headline": self.headline,
                                                             @"description": descTxtView.text,
                                                             @"category": self.category
                                                            }
               andLink:UPLOADVIDEO
           AndCallback:^(id result, NSError *error) {
               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
               NSLog(@"%@", result);

               if (result != NULL) {
                   [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Successfully uploaded."];
//                   [self.navigationController popToRootViewControllerAnimated:YES];
                   
                   [self.tabBarController setSelectedIndex:0];
                   
               }else{
                   [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Try again."];
               }
           }];
}

#pragma mark - Facebook Video Posting
-(void)shareOnFB
{
    __block ACAccount * facebookAccount;
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    NSDictionary *emailReadPermisson = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        FB_APP_ID,ACFacebookAppIdKey,
                                        @[@"email"],ACFacebookPermissionsKey,
                                        ACFacebookAudienceFriends,ACFacebookAudienceKey,
                                        nil];
    
    NSDictionary *publishWritePermisson = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           FB_APP_ID,ACFacebookAppIdKey,
                                           @[@"publish_stream"],ACFacebookPermissionsKey,
                                           ACFacebookAudienceFriends,ACFacebookAudienceKey,
                                           nil];
    
    ACAccountType *facebookAccountType = [accountStore
                                          accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    //Request for Read permission
    
    [accountStore requestAccessToAccountsWithType:facebookAccountType options:emailReadPermisson completion:^(BOOL granted, NSError *error) {
        
        if (granted)
        {
            //Request for write permission
            [accountStore requestAccessToAccountsWithType:facebookAccountType options:publishWritePermisson completion:^(BOOL granted, NSError *error) {
                
                if (granted)
                {
                    NSArray *accounts = [accountStore
                                         accountsWithAccountType:facebookAccountType];
                    facebookAccount = [accounts lastObject];
                    NSLog(@"access to facebook account ok %@", facebookAccount.username);
                    [self uploadWithFBAccount:facebookAccount];
                }
                else
                {
                    NSLog(@"access to facebook is not granted");
                    // extra handling here if necesary
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Fail gracefully...
                        NSLog(@"%@",error.description);
                        [self errorMethodFromFB:error];
                    });
                }
            }];
        }
        else
        {
            [self errorMethodFromFB:error];
        }
    }];
}

-(void)errorMethodFromFB:(NSError *)error
{
    
    NSLog(@"access to facebook is not granted");
    // extra handling here if necesary
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Fail gracefully...
        NSLog(@"%@",error.description);
        
        if([error code]== ACErrorAccountNotFound)
            [self throwAlertWithTitle:@"Error" message:@"Account not found. Please setup your account in settings app."];
        if ([error code] == ACErrorAccessInfoInvalid)
            [self throwAlertWithTitle:@"Error" message:@"The client's access info dictionary has incorrect or missing values."];
        if ([error code] ==  ACErrorPermissionDenied)
            [self throwAlertWithTitle:@"Error" message:@"The operation didn't complete because the user denied permission."];
        else
            [self throwAlertWithTitle:@"Error" message:@"Account access denied."];
    });
}

-(void)throwAlertWithTitle:(NSString *)title message:(NSString *)msg
{
    [[[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
}

-(void)uploadWithFBAccount:(ACAccount *)facebookAccount
{
    ACAccountCredential *fbCredential = [facebookAccount credential];
    NSString *accessToken = [fbCredential oauthToken];
    
    NSURL *videourl = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/videos?access_token=%@",accessToken]];
    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString* foofile = [documentsDirectory stringByAppendingPathComponent:@"me.mov"];
//    BOOL fileExists = [fileManager fileExistsAtPath:foofile];
//    if (fileExists)
//    {
//        NSLog(@"file saved");
//    }
//    NSString *filePath = foofile;
//    NSURL *pathURL = [[NSURL alloc]initFileURLWithPath:filePath isDirectory:NO];
//    NSData *videoData = [NSData dataWithContentsOfFile:filePath];
    
    NSURL *pathURL = [NSURL URLWithString:_videoPath];
    NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.videoPath]];
    
    NSDictionary *params = @{
                             @"title": @"Me  silly",
                             @"description": @"Me testing the video upload to Facebook with the new Social Framework."
                             };
    
    SLRequest *uploadRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                  requestMethod:SLRequestMethodPOST
                                                            URL:videourl
                                                     parameters:params];
    [uploadRequest addMultipartData:videoData
                           withName:@"source"
                               type:@"video/quicktime"
                           filename:[pathURL absoluteString]];
    
    uploadRequest.account = facebookAccount;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [uploadRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            
            if(error)
            {
                NSLog(@"Error %@", error.localizedDescription);
            }
            else
            {
                [[[UIAlertView alloc]initWithTitle:@"Congratulations!" message:@"Your video is suucessfully posted to your FB newsfeed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                NSLog(@"%@", responseString);
            }
        }];
    });
}


#pragma mark - UITextField / UITextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView{
    textView.text = @"";
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return YES;
}

#pragma mark - POST Request delegate methods
- (void) postResource:(NSString *)resource andMethod:(NSString *)method andWithParams:(NSDictionary *)params andLink:(NSString*)link AndCallback: (void (^)(id result, NSError *error))callback
{
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:link]];
//    [httpClient setParameterEncoding:AFJSONParameterEncoding];
//    [httpClient setDefaultHeader:@"Authorization" value:[AppDelegate sharedInstance].authData];
//    
//    //send photos from array
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    
//    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:method path:resource parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
//        @autoreleasepool {
//            NSData *data1 = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.videoPath]];            
//            [formData appendPartWithFileData:data1 name:@"video" fileName:@"video.mp4" mimeType:@"video/mp4"];
//        }
//    }];
//    
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
//    [AFHTTPRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         // parse response to JSON
//         NSString *convertedString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
//         NSLog(@"~~~~~~~~%@", convertedString);
//         
//         NSMutableDictionary *parsedData = [[NSMutableDictionary alloc] init];
//         parsedData = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:nil];
//         
//         NSString *sessionId = [operation.response.allHeaderFields valueForKey:@"Set-Cookie"];
//         
//         if ([sessionId length] != 0)
//         {
//             [prefs setObject:sessionId forKey:@"session_id"];
//             [prefs synchronize];
//         }
//         callback(parsedData, nil);
//     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         if (403 == operation.response.statusCode){
//             
//             NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData: [operation.responseString dataUsingEncoding:NSUTF8StringEncoding]
//                                                                         options: NSJSONReadingMutableContainers
//                                                                           error: nil];
//             [dict setObject:@403 forKey:@"error_code"];
//             
//             callback(dict , error);
//         }else
//             if(operation.responseData)
//             {
//                 NSDictionary* deserializedData = [NSJSONSerialization
//                                                   JSONObjectWithData:operation.responseData //1
//                                                   options:kNilOptions
//                                                   error:&error];
//                 
//                 
//                 NSError *valuesError = [NSError errorWithDomain:@"myDomain" code:100 userInfo:deserializedData];
//                 
//                 callback(deserializedData, valuesError);
//             } else {
//                 callback(operation.responseString, error);
//             }
//     }];
//    
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [queue addOperation:operation];
}

@end
