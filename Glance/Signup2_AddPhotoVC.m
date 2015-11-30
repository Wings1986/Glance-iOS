//
//  Signup2-AddPhotoViewController.m
//  Glance
//
//  Created by Avramov on 3/17/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import "Signup2_AddPhotoVC.h"

#import "CustomPlaceHolderTextColorTextField.h"
#import "AppDelegate.h"



@interface Signup2_AddPhotoVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    UIImage *profilePhoto;
    
    IBOutlet UIImageView *imgView;
    IBOutlet CustomPlaceHolderTextColorTextField *nameTxtField, *bioTxtField;
    
    BOOL m_bSkip;
}
@end

@implementation Signup2_AddPhotoVC

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    imgView.layer.cornerRadius = imgView.frame.size.width / 2;
    imgView.layer.borderColor = [UIColor whiteColor].CGColor;
    imgView.layer.borderWidth = 2;
    imgView.layer.masksToBounds = YES;

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
- (IBAction)Next:(id)sender{

    m_bSkip = NO;
    
    NSString * userName = nameTxtField.text;
    NSString * bio = bioTxtField.text;
    NSString * firstName = @"";
    NSString * lastName = @"";
    
    
    if (profilePhoto == nil) {
        [[AppDelegate sharedInstance] showAlertMessage:@"NOTE" message:@"Please choose profile image"];
        return;
    }
    if (userName.length < 1) {
        [[AppDelegate sharedInstance] showAlertMessage:@"NOTE" message:@"Please input user name"];
        return;
    }
    if (bio.length < 1) {
        [[AppDelegate sharedInstance] showAlertMessage:@"NOTE" message:@"Please input bio"];
        return;
    }
    
    NSArray * arryName = [userName componentsSeparatedByString:@" "];
    for (NSInteger i = 0 ; i < arryName.count ; i ++) {
        NSString * str = arryName[i];
        
        if (i == 0) {
            firstName = str;
        }
        else {
            if (i != 1) {
                lastName = [lastName stringByAppendingString:@" "];
            }
            lastName = [lastName stringByAppendingString:str];
        }
    }
    
    
    [[AppDelegate sharedInstance].signupParam setObject:firstName forKey:@"first_name"];
    [[AppDelegate sharedInstance].signupParam setObject:lastName forKey:@"last_name"];
    [[AppDelegate sharedInstance].signupParam setObject:bio forKey:@"bio"];
    
    
    [self requestService];
    
}

- (IBAction)Skip:(id)sender{

    m_bSkip = YES;
    
    [self requestService];
}

- (void) requestService
{
    [self performSegueWithIdentifier:@"gotoInvite" sender:self];
    return;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString * urlString = [[NSString stringWithFormat:@"%@/user/", BASICURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [manager POST:urlString
       parameters:[AppDelegate sharedInstance].signupParam constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
           
           if (!m_bSkip) {
               NSData *imageData = UIImagePNGRepresentation(profilePhoto);
               [formData appendPartWithFormData:imageData name:@"avatar"];
           }
           
         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
              
              NSDictionary * result = (NSDictionary*)responseObject;
              NSLog(@"result = %@", result);
             
             
             NSString *authStr = [NSString stringWithFormat:@"%@:%@",
                                  [AppDelegate sharedInstance].signupParam[@"username"],
                                  [AppDelegate sharedInstance].signupParam[@"password"]];
             NSString *encodedLoginData = [Base64 encode:[authStr dataUsingEncoding:NSUTF8StringEncoding]];
             [AppDelegate sharedInstance].authData = [NSString stringWithFormat:@"Basic %@", encodedLoginData];
             
              [AppDelegate sharedInstance].bLoginToken = YES;
              [AppDelegate sharedInstance].userInfo = result[@"objects"];
              
             
             //set value into NSUserDefaults
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             [defaults setObject:[AppDelegate sharedInstance].userInfo forKey:@"user"];
             [defaults setBool:[AppDelegate sharedInstance].bLoginToken forKey:@"token"];
             [defaults setObject:[AppDelegate sharedInstance].authData forKey:@"auth"];
             [defaults synchronize];
             
             [self performSegueWithIdentifier:@"gotoInvite" sender:self];

             
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
              
              NSLog(@"error = %@", error.description);
              
              [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"Signup error"];
              
          }];
    

}



-(IBAction)AddProfilePhoto:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Camera" otherButtonTitles:@"Photo Album", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController *imgPickerCtrl = [[UIImagePickerController alloc] init];
    imgPickerCtrl.delegate = self;
    
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera]) {
            imgPickerCtrl.allowsEditing = NO;
            imgPickerCtrl.sourceType = UIImagePickerControllerSourceTypeCamera ;
            imgPickerCtrl.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
            imgPickerCtrl.showsCameraControls = YES;
        }
        [self presentViewController:imgPickerCtrl animated:YES completion:Nil];
    }else if(buttonIndex == 1){
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            imgPickerCtrl.allowsEditing = NO;
            imgPickerCtrl.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
        [self presentViewController:imgPickerCtrl animated:YES completion:Nil];
    }else{
        
    }
    
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - UIImagePickerController Delegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    profilePhoto = image;
    
    imgView.image = image;
    
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    // Unable to save the image
    if (error)
        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Unable to save image to Photo Album."];
    else // All is well
        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Image saved to Photo Album."];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:Nil];
}


#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self keyboardWillShow];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self keyboardWillHide];
    [textField resignFirstResponder];
}

#define MAX_LENGTH 20

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    if (textField.text.length >= MAX_LENGTH && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else
    {
        return YES;
    }
    
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
