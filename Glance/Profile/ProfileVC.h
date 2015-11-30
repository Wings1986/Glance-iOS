//
//  ProfileVC.h
//  Glance
//
//  Created by Vanguard on 12/15/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseFeedViewController.h"

@interface ProfileVC : BaseFeedViewController{

  
}


@property (nonatomic, readwrite) BOOL bOtherProfile;
@property (nonatomic, strong) NSDictionary * userInfo;

@end
