//
//  BasicSignupViewController.h
//  Glance
//
//  Created by Avramov on 3/17/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface BasicSignupVC : UIViewController<UITextFieldDelegate>

@property (nonatomic, strong) FSNConnection *signUpConnection;

- (FSNConnection*)signUpConnection:(NSDictionary*)params;

@end
