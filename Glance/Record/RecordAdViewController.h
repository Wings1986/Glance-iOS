//
//  RecordAdViewController.h
//  TheDime
//
//  Created by Kevin McNeish on 6/20/14.
//  Copyright (c) 2014 Anonoymous - ICN. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PBJVision.h"

@interface RecordAdViewController : UIViewController 

@property (strong, nonatomic) NSString *videoPath;

- (void)visionSessionDidStop:(PBJVision *)vision;
- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error;
- (void)resetCapture;
- (void)endCapture;
- (IBAction)close:(id)sender;

@end
