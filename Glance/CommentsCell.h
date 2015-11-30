//
//  CommentsCell.h
//  Glance
//
//  Created by Avramov on 3/28/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *imgView;
@property (nonatomic, retain) IBOutlet UILabel *commentLabel, *timeLabel;

@end
