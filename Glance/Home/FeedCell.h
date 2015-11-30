//
//  FeedCell.h
//  Glance
//
//  Created by Vanguard on 12/25/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJVideoPlayerController.h"


@interface FeedCell : UITableViewCell

@property (nonatomic, retain) PBJVideoPlayerController *_videoPlayerController;
@property (nonatomic, retain) UIImageView *_playButton;

@property (weak, nonatomic) IBOutlet UIImageView *userlocationView;

@property (nonatomic, retain) IBOutlet UIImageView *imgView;
@property (nonatomic, retain) IBOutlet UIImageView *thumbPhotoView;
@property (nonatomic, retain) IBOutlet UIView *locationView, *moreView;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel, *timeLabel, *likeLabel, *commentsLabel, *descLabel, *locLabel;
@property (nonatomic, retain) IBOutlet UIButton *shareButton, *reportButton;
@property (nonatomic, retain) IBOutlet UIButton *likeButton, *commentButton;
@property (weak, nonatomic) IBOutlet UIImageView *imgBlurMoreView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;

@property (weak, nonatomic) IBOutlet UIImageView *ivCategory;

@end
