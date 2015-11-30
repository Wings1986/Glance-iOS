//
//  ChooseCategoryDlg.h
//

#import <UIKit/UIKit.h>


typedef enum
{
    MODE_SELECT_ONE,
    MODE_SELECT_MULTI,
}SELECTMODE;

#define NEWS    @"News"
#define EVENTS  @"Events"
#define TRAVEL  @"Travel"
#define SPORTS  @"Sports"
#define MUSIC   @"Music"
#define ARTS    @"Arts"
#define NIGHTLIFE   @"Nightlife"
#define ENTERTAINMENT     @"Entertainment"
#define FASHION     @"Fashion"



@protocol ChooseCategoryDlgDelegate;

@interface ChooseCategoryDlg : UIViewController

@property (assign, nonatomic) id <ChooseCategoryDlgDelegate>delegate;

@property (assign, nonatomic) SELECTMODE mode;
@property (strong, nonatomic) UIImage * backImage;

@end



@protocol ChooseCategoryDlgDelegate<NSObject>
@optional
- (void) chooseCategory:(NSMutableArray*) arrCategory;
@end
