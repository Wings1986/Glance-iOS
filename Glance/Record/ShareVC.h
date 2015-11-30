//
//  ShareVC.h
//  Glance
//
//  Created by Avramov on 3/25/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "AppDelegate.h"

@interface ShareVC : UIViewController<UITextViewDelegate>{

    IBOutlet UIImageView *ivThumbnail;
    IBOutlet UITextView *descTxtView;

    IBOutlet UILabel *locInfoView, *categoryLabel;
    
    IBOutlet UIButton *twitterButton, *facebookButton;

}

@property (nonatomic, retain) NSString *videoPath;
@property (nonatomic, retain) UIImage *thumbImage;
@property (nonatomic, strong) NSString * headline;
@property (nonatomic, strong) NSString * category;

- (IBAction)Facebook:(id)sender;
- (IBAction)Twitter:(id)sender;

@end
