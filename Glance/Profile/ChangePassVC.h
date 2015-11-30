//
//  ChangePassVC.h
//  Glance
//
//  Created by Vanguard on 1/3/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SettingVC.h"

@interface ChangePassVC : UIViewController<UITextFieldDelegate>{
}

@property (nonatomic, retain) IBOutlet UITextField *oldPassTxtField, *passTxtField, *confTxtField;
@property id<PasswordDelegate> delegate;

@end
