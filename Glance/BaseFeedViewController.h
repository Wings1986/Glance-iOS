//
//  BaseFeedViewController.h
//  Glance
//

#import <UIKit/UIKit.h>

@interface BaseFeedViewController : UIViewController
{
    BOOL    m_bMoreLoad;
    
    int     m_limit;
    int     m_offset;
    int     m_total_count;
}

- (void)startRefresh;
- (void)startMoreLoad;

@end
