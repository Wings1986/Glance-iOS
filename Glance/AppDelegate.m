//
//  AppDelegate.m
//  Glance
//
//  Created by Conqueror on 12/01/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import "AppDelegate.h"

#import "UIImage-Helpers.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

+(AppDelegate*)sharedInstance{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (void)showAlertMessage:(NSString*)title message:(NSString*)content{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:content
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    
//    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:title message:content
//                               cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    
//    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
//        
//        [alertView hideWithCompletionBlock:^{
//        }];
//    }];
//    [alertView showWithAnimation:URBAlertAnimationFade];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTintColor:THEME_COLOR];

//    UITabBarController *tabVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"tabMain"];
//    UITabBarItem * item = tabVC.tabBar.items[0];
//    
//    [item setImage:[[UIImage imageNamed:@"tab_record-button.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    
//    UITabBarController *tabBarController = (UITabBarController *) [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"tabMain"];
//    UINavigationController * nav = (UINavigationController*) tabBarController.childViewControllers[2];
//    nav.tabBarItem.image = [[UIImage imageNamed:@"tab_record-button.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
//    UITabBar *tabBar = tabBarController.tabBar;
//    
//    for (UITabBarItem *item in tabBar.items)
//    {
//        UIImage *image = item.image;
////        UIImage *correctImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        [item setImage:[[UIImage imageNamed:@"tab_record-button.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//        [item setSelectedImage:[[UIImage imageNamed:@"tab_record-button.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//        item.title = @"adfsdf";
//    }
    
    _bLoginToken = NO;
    _userStr = [[NSString alloc] init];
    _passStr = [[NSString alloc] init];
    _emailStr = [[NSString alloc] init];
    _userInfo = [[NSMutableDictionary alloc] init];
    _authData = [[NSString alloc] init];
    _signupParam = [[NSMutableDictionary alloc] init];

    [self setLocationManager];
    
    // Register for Push Notitications, if running on iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }


    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.bLoginToken = [defaults boolForKey:@"token"];
    self.userInfo = [defaults objectForKey:@"user"];
    self.authData = [defaults objectForKey:@"auth"];
    
    //Validing login-token
    if (!self.bLoginToken) {
        UINavigationController *rootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"naviRoot"];
        self.window.rootViewController = rootVC;
    }
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - push notification
-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    // Prepare the Device Token for Registration (remove spaces and < >)
    NSString *devToken = [[[[deviceToken description]
                            stringByReplacingOccurrencesOfString:@"<"withString:@""]
                           stringByReplacingOccurrencesOfString:@">" withString:@""]
                          stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"My token is: %@", devToken);
}
-(void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error

{
    NSLog(@"Failed to get token, error: %@", error);  
}


#pragma mark - Location Manager Delegate methods
- (void)setLocationManager{
    _curLocManager = [[CLLocationManager alloc] init];
    _curLocManager.desiredAccuracy = kCLLocationAccuracyBest;
    _curLocManager.delegate = self;
    
    // Override point for customization after application launch.
    if (IS_OS_8_OR_LATER){
        [_curLocManager requestAlwaysAuthorization];
        //Right, that is the point
    }else{
    }
    
    [_curLocManager startUpdatingLocation];
    _startLocation = nil;
}

-(void)resetDistance:(id)sender{
    _startLocation = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Location: didFailWithError: %@", error);
}
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
//    NSLog(@"Location: didUpdateLocations ====");
    
    _startLocation = [locations lastObject];
}

//- (void)locationManager:(CLLocationManager *)manager :(NSArray *)locations{
//    CLLocation *location_updated = [locations lastObject];
//
//    NSLog(@"updated coordinate are %@",location_updated);
//    _startLocation = location_updated;
//}

- (NSDictionary*)getDataFromPlist{
    NSString *plistFilePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    NSDictionary *tempDict = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    return tempDict;
}

#pragma mark - POST Request delegate methods
- (void) postResource:(NSString *)resource andMethod:(NSString *)method andWithParams:(NSDictionary *)params andLink:(NSString*)link AndCallback: (void (^)(id result, NSError *error))callback
{
    NSLog(@"authData = %@", [AppDelegate sharedInstance].authData);

}

#pragma mark screen capture
- (UIImage*) getScreencapture
{
//    UIGraphicsBeginImageContext(self.window.bounds.size);
//    [self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();

    UIImage *image = [UIImage screenshot];
    
    return [self getBlurImage:image];
    
}
- (UIImage*) getBlurImage:(UIImage*) image
{
    // jpeg quality image data
    float quality = .00001f;
    
    // intensity of blurred
    float blurred = .8f;
    
    NSData *imageData = UIImageJPEGRepresentation(image, quality);
    UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:blurred];
    
    return blurredImage;
}

#pragma mark Valid Email & Charactors
+ (BOOL) isValidEmail:(NSString*) email
{
    NSString *expression = @"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
    
    if (match){
        NSLog(@"yes");
        return YES;
    }else{
        NSLog(@"no");
        return NO;
    }
}
+ (BOOL) isValidCharactorLength:(NSString*) str length:(int) length
{
    return str.length >= length;
}

@end
