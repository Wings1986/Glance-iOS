//
//  ShareVC.h
//  Glance
//
//  Created by Avramov on 3/25/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFHTTPClient.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "AppDelegate.h"

@interface ShareVC : UIViewController<UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
    NSString *category;
    NSDictionary *addressDictionary;

    IBOutlet UIView *headlineView, *descView, *locView, *categoryView, *shareView;
    IBOutlet UITextField *headlineTxtField;
    IBOutlet UITextView *descTxtView;
    IBOutlet UIImageView *thumbImgView;
    IBOutlet UILabel *locInfoView, *categoryLabel;
    IBOutlet UIButton *twitterButton, *facebookButton;
    IBOutlet UIPickerView *categoryPickerView;
}

@property (nonatomic, retain) NSString *videoPath;
@property (nonatomic, retain) UIImage *thumbImage;

- (IBAction)Facebook:(id)sender;
- (IBAction)Twitter:(id)sender;
- (IBAction)SetCategory:(id)sender;

@end
