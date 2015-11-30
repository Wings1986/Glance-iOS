//
//  ProfileCell.h
//  Glance
//
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *cityLabel;
@property (nonatomic, strong) IBOutlet UILabel *bioLabel;
@property (nonatomic, strong) IBOutlet UILabel *followersLabel;
@property (nonatomic, strong) IBOutlet UILabel *numFollowLabel;

@property (nonatomic, strong) IBOutlet UIImageView *profImgView;

@property (nonatomic, strong) IBOutlet UIButton * btnFollewerList;
@property (nonatomic, strong) IBOutlet UIButton * btnFollowingList;

@end
