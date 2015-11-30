//
//  ChangePassVC.m
//  Glance
//
//  Created by Vanguard on 1/3/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import "ChangePassVC.h"

@interface ChangePassVC ()

@property (nonatomic, strong) FSNConnection *connection;

@end

@implementation ChangePassVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

#pragma mark - IBAction methods
- (IBAction)Save:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([_oldPassTxtField.text isEqualToString:[[defaults objectForKey:@"pass"] mutableCopy]]) {
        if ([_passTxtField.text isEqualToString:_confTxtField.text]) {
            [self.delegate changePassword:_passTxtField.text];
        }
    }else{
        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Incorrect Password"];
    }
    

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)Cancel:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField delegate methods
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    return YES;
}


-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        //        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0){
        //        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp){
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_KEYBOARD;
    }
    else{
        // revert back to the normal state.
        rect.origin.y += kOFFSET_KEYBOARD;
        //        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

@end
