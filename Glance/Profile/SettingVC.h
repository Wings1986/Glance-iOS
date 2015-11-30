//
//  SettingVC.h
//  Glance
//
//  Created by Vanguard on 12/29/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AppDelegate.h"

@protocol PasswordDelegate <NSObject>

- (void)changePassword:(NSString*)newPass;

@end

@interface SettingVC : UIViewController <PasswordDelegate>

@property (nonatomic, strong) UIImage * backImage;


@end
