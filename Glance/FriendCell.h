//
//  FriendCell.h
//  Glance
//
//  Created by Avramov on 3/17/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *imgView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIButton *btnFollow;

@end
