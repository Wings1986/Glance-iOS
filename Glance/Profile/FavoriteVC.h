//
//  FavoriteVC.h
//  Glance
//
//  Created by Vanguard on 12/29/14.
//  Copyright (c) 2014 Conqueror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface FavoriteVC : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *favList;
    IBOutlet UITableView *favTableView;
}

@end
