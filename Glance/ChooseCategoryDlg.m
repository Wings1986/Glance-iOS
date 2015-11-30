//
//  ChooseCategoryDlg.m
//

#import "ChooseCategoryDlg.h"

@interface ChooseCategoryDlg ()
{
    __weak IBOutlet UIImageView *ivBackground;
    
    __weak IBOutlet UIView *btnClose;
    __weak IBOutlet UIButton *btnNews;
    __weak IBOutlet UIButton *btnEvents;
    __weak IBOutlet UIButton *btnTravel;
    __weak IBOutlet UIButton *btnSports;
    __weak IBOutlet UIButton *btnMusic;
    __weak IBOutlet UIButton *btnArts;
    __weak IBOutlet UIButton *btnNightlife;
    __weak IBOutlet UIButton *btnOutings;
    __weak IBOutlet UIButton *btnFashion;
    
    __weak IBOutlet UIView *subView;
}
@end

@implementation ChooseCategoryDlg

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.mode == MODE_SELECT_ONE) {
        btnClose.hidden = YES;
        subView.frame = CGRectMake(subView.frame.origin.x, 145, subView.frame.size.width, subView.frame.size.height);
    }

    
    ivBackground.image = self.backImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) closeDlg:(NSString*) category
{
    
    NSMutableArray * arryCategory = [[NSMutableArray alloc] init];
    if (category != nil) {
        [arryCategory addObject:category];
    }
    else {
        
        if (btnNews.selected) {
            [arryCategory addObject:NEWS];
        }
        if (btnEvents.selected) {
            [arryCategory addObject:EVENTS];
        }
        if (btnTravel.selected) {
            [arryCategory addObject:TRAVEL];
        }
        if (btnSports.selected) {
            [arryCategory addObject:SPORTS];
        }
        if (btnMusic.selected) {
            [arryCategory addObject:MUSIC];
        }
        if (btnArts.selected) {
            [arryCategory addObject:ARTS];
        }
        if (btnNightlife.selected) {
            [arryCategory addObject:NIGHTLIFE];
        }
        if (btnOutings.selected) {
            [arryCategory addObject:ENTERTAINMENT];
        }
        if (btnFashion.selected) {
            [arryCategory addObject:FASHION];
        }
    }
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate chooseCategory:arryCategory] ;
    }];
    
}


#pragma mark Button event
- (IBAction)onClickSelect:(id)sender {
    
    [self closeDlg:nil];
}

- (IBAction)onClickNews:(id)sender {
    
    if (self.mode == MODE_SELECT_MULTI) {
        ((UIButton*) sender).selected = ! ((UIButton*) sender).selected;
    }
    else {
        [self closeDlg:NEWS];
    }
}
- (IBAction)onClickEvents:(id)sender {
    if (self.mode == MODE_SELECT_MULTI) {
        ((UIButton*) sender).selected = ! ((UIButton*) sender).selected;
    }
    else {
        [self closeDlg:EVENTS];
    }

}
- (IBAction)onClickTravel:(id)sender {
    if (self.mode == MODE_SELECT_MULTI) {
        ((UIButton*) sender).selected = ! ((UIButton*) sender).selected;
    }
    else {
        [self closeDlg:TRAVEL];
    }

}
- (IBAction)onClickSports:(id)sender {
    if (self.mode == MODE_SELECT_MULTI) {
        ((UIButton*) sender).selected = ! ((UIButton*) sender).selected;
    }
    else {
        [self closeDlg:SPORTS];
    }
}
- (IBAction)onClickMusic:(id)sender {
    if (self.mode == MODE_SELECT_MULTI) {
        ((UIButton*) sender).selected = ! ((UIButton*) sender).selected;
    }
    else {
        [self closeDlg:MUSIC];
    }
}
- (IBAction)onClickArts:(id)sender {
    if (self.mode == MODE_SELECT_MULTI) {
        ((UIButton*) sender).selected = ! ((UIButton*) sender).selected;
    }
    else {
        [self closeDlg:ARTS];
    }
}
- (IBAction)onClickNightlife:(id)sender {
    if (self.mode == MODE_SELECT_MULTI) {
        ((UIButton*) sender).selected = ! ((UIButton*) sender).selected;
    }
    else {
        [self closeDlg:NIGHTLIFE];
    }
}
- (IBAction)onClickOutings:(id)sender {
    if (self.mode == MODE_SELECT_MULTI) {
        ((UIButton*) sender).selected = ! ((UIButton*) sender).selected;
    }
    else {
        [self closeDlg:ENTERTAINMENT];
    }
}
- (IBAction)onClickFashion:(id)sender {
    if (self.mode == MODE_SELECT_MULTI) {
        ((UIButton*) sender).selected = ! ((UIButton*) sender).selected;
    }
    else {
        [self closeDlg:FASHION];
    }
}

@end
