//
//  ActivityCell.h
//  Glance
//
//  Created by Vanguard on 12/27/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *imgView;
@property (nonatomic, retain) IBOutlet UILabel *commentLabel, *timeLabel;

@end
