//
//  Signup3_InviteFriendsVC.h
//  Glance
//
//  Created by Avramov on 3/17/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicSignupVC.h"

@interface Signup3_InviteFriendsVC : BasicSignupVC<UITableViewDataSource, UITableViewDelegate>{
    IBOutlet UITableView *friendsView;
    IBOutlet UISegmentedControl *socialPicker;
    NSMutableArray *friendList;
}

-(IBAction)SelectOption:(id)sender;
    
@end
