//
//  AppDelegate.h
//  Glance
//
//  Created by Conqueror on 12/01/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AFNetworking.h>

#import <MBProgressHUD/MBProgressHUD.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreLocation/CoreLocation.h>

#import "FSNConnection.h"
#import "UIImageView+WebCache.h"
#import "GDataXMLNode.h"
#import "Base64.h"

#define FB_APP_ID @"660138450759711"
#define kOFFSET_KEYBOARD 120
#define kBoarderWidth 3.0

#define CARD_WIDTH 320
#define CARD_HEIGHT 320

#define APIKEY @"Basic bGFsc3RlZjoxMjM="

#define BASICURL @"https://glanceapp.herokuapp.com/api/1.0"

// GET links
#define GETUSER @"https://glanceapp.herokuapp.com/api/1.0/user"

#define GETFAVCITY @"https://glanceapp.herokuapp.com/api/1.0/user/fav/city"
#define LIKE @"https://glanceapp.herokuapp.com/api/1.0/user/follow"
#define NEWPASS @"https://glanceapp.herokuapp.com/api/1.0/user/password"



#define UPLOADVIDEO @"https://glanceapp.herokuapp.com/api/1.0/video/"
#define SHAREVID @"https://glanceapp.herokuapp.com/i/video/share"

#define FASTTHUMBPATH @"https://s3-us-west-2.amazonaws.com/glanceapp/thumbs/"
#define FASTAVATARPATH @"https://s3-us-west-2.amazonaws.com/glanceapp/avatars/"
#define FASTVIDEOPATH @"https://s3-us-west-2.amazonaws.com/glanceapp/videos/"

#define THUMBPATH @"https://glanceapp.herokuapp.com/thumbs/"
#define AVATARPATH @"https://glanceapp.herokuapp.com/avatars/"
#define VIDEOPATH @"https://glanceapp.herokuapp.com/videos/"

//POST links
#define SIGNUP @"https://glanceapp.herokuapp.com/api/1.0/user/"
#define LOGIN @"https://glanceapp.herokuapp.com/api/1.0/user/login/"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)



#define THEME_COLOR [UIColor colorWithRed:11.0f/255.0f green:220.0f/255.0f blue:213.0f/255.0f alpha:1.0f]




@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readwrite) BOOL bLoginToken;
@property (nonatomic, retain) NSString *authData;

@property (nonatomic, retain) NSMutableDictionary *userInfo, *signupParam;

@property (nonatomic, retain) CLLocationManager *curLocManager;
@property (nonatomic, retain) CLLocation *startLocation;

@property (nonatomic, retain) NSString *userStr, *emailStr, *passStr;

- (NSDictionary*)getDataFromPlist;

- (void)showAlertMessage:(NSString*)title message:(NSString*)content;
+ (AppDelegate*)sharedInstance;
- (void)setLocationManager;


- (UIImage*) getScreencapture;
- (UIImage*) getBlurImage:(UIImage*) image;

+ (BOOL) isValidEmail:(NSString*) email;
+ (BOOL) isValidCharactorLength:(NSString*) str length:(int) length;

@end

