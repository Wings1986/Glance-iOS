//
//  CommentsVC.h
//  Glance
//
//  Created by Avramov on 3/27/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "BaseTableViewController.h"


@interface CommentsVC : BaseTableViewController<UITextFieldDelegate>{
}

@property (nonatomic, retain) NSMutableArray *commentsList;
@property (nonatomic, retain) NSString *vidID;
@property (nonatomic, strong) UIImage * backImage;

@end
