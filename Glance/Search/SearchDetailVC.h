//
//  SearchDetailVC.h
//  Glance
//

#import <UIKit/UIKit.h>

#import "BaseFeedViewController.h"

typedef enum{
    CITY = 0,
    TAG,
} FEEDTYPE;

@interface SearchDetailVC : BaseFeedViewController {
    
    NSMutableArray *videoFeedList;
}

@property (nonatomic, strong) NSString * m_title;
@property (nonatomic, strong) NSString* m_id;
@property (nonatomic, assign) FEEDTYPE  feedType;

@end
