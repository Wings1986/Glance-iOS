//
//  LoginViewController.h
//  Glance
//
//  Created by Conqueror on 12/01/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import "AppDelegate.h"
#import "InitViewController.h"
#import "CustomPlaceHolderTextColorTextField.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate, FBLoginViewDelegate>{
    NSString *emailString, *fbIdString;
}

@property (nonatomic, retain) IBOutlet CustomPlaceHolderTextColorTextField *userTxtField, *passTxtField;


@end
