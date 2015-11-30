//
//  Signup3_InviteFriendsVC.m
//  Glance
//
//  Created by Avramov on 3/17/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import "Signup3_InviteFriendsVC.h"
#import "FriendCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <AddressBook/AddressBook.h>

#import "AppDelegate.h"

@interface Signup3_InviteFriendsVC ()<FBLoginViewDelegate>{
    FBSession *session;
}

@end

@implementation Signup3_InviteFriendsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    friendsView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

//    [self loadFacebookFriends];
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

- (void)filterFriends:(NSMutableArray*)list{
    
}

#pragma mark - IBAction methods
- (IBAction)Back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)Next:(id)sender{
//    [self dismissViewControllerAnimated:NO completion:nil];
    
    UITabBarController *rootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"tabMain"];
    
    [AppDelegate sharedInstance].window.rootViewController = rootVC;
    
}

- (IBAction)SelectOption:(id)sender{

//    UISegmentedControl *segmentCtrl = (UISegmentedControl*)sender;
//    if (segmentCtrl.selectedSegmentIndex == 0) {
//        [self loadFacebookFriends];
//    }else if (segmentCtrl.selectedSegmentIndex == 1) {
//        [self loadTwitterFriends];
//    }else if (segmentCtrl.selectedSegmentIndex == 2) {
//        [self loadFriendsFromContacts];
//    }
}

- (IBAction)Invite:(id)sender{
    
}

#pragma mark - Phone Contacts
- (void)loadFriendsFromContacts{
    friendList = [[NSMutableArray alloc] initWithArray:[self getAllContacts]];
    [friendsView reloadData];
}

- (NSArray *)getAllContacts{
    CFErrorRef *error = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
#ifdef DEBUG
        NSLog(@"Fetching contact info ----> ");
#endif
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        //        CFIndex nPeople = CFArrayGetCount(addressBook);
        
        NSArray *allPeople = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        CFIndex nPeople = allPeople.count;
        NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];
        
        for (int i = 0; i < nPeople; i++)
        {
            NSMutableDictionary *contacts = [[NSMutableDictionary alloc] init];
            ABRecordRef person = (__bridge ABRecordRef)([allPeople objectAtIndex:i]);
            
            //get First Name and Last Name
            
            if (!(__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty))
                [contacts setObject:@"" forKey:@"firstNames"];
            else
                [contacts setObject: (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty) forKey:@"firstNames"];
            
            if (!(__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty))
                [contacts setObject:@"" forKey:@"lastNames"];
            else
                [contacts setObject: (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty) forKey:@"lastNames"];
            
            [contacts setObject:[NSString stringWithFormat:@"%@ %@", [contacts objectForKey:@"firstNames"], [contacts objectForKey:@"lastNames"]] forKey:@"name"];
            
            // get contacts picture, if pic doesn't exists, show standart one
            NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
            if (!imgData) {
                [contacts setObject:[UIImage imageNamed:@"my_avatar_icon.png"] forKey:@"image"];
            }else{
                [contacts setObject:[UIImage imageWithData:imgData] forKey:@"image"];
            }
            
            //get Phone Numbers
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                [phoneNumbers addObject:phoneNumber];
                //NSLog(@"All numbers %@", phoneNumbers);
            }
            
            [contacts setObject:phoneNumbers forKey:@"phoneNumbers"];
            
            //get Contact email
            NSMutableArray *contactEmails = [NSMutableArray new];
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                NSString *contactEmail = (__bridge NSString *)contactEmailRef;
                
                [contactEmails addObject:contactEmail];
                // NSLog(@"All emails are:%@", contactEmails);
            }
            
            [contacts setObject:contactEmails forKey:@"emails"];
            [items addObject:contacts];
            
#ifdef DEBUG
            //NSLog(@"Person is: %@", contacts.firstNames);
            //NSLog(@"Phones are: %@", contacts.numbers);
            //NSLog(@"Email is:%@", contacts.emails);
#endif
        }
        return items;
    } else {
#ifdef DEBUG
        NSLog(@"Cannot fetch Contacts :( ");
#endif
        return NO;
    }
}

#pragma mark - Twitter Friends
- (void)loadTwitterFriends{
    [self openTwitterSession];
}

- (void)openTwitterSession{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType
                                          options:nil
                                       completion:^(BOOL granted,
                                                    NSError *error)
     {
         if (granted)
         {
             NSArray *accounts = [accountStore accountsWithAccountType:accountType];
             
             // Check if the users has setup at least one Twitter account.
             if (accounts.count > 0)
             {
                 ACAccount *twitterAccount = [accounts objectAtIndex:0];
                 
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/list.json"];
                 NSDictionary *parameters = @{@"screen_name" : twitterAccount.username};
                 
                 // Creating a request.
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                         requestMethod:SLRequestMethodGET
                                                                   URL:url
                                                            parameters:parameters];
                 [request setAccount:twitterAccount];
                 
                 // Perform the request.
                 [request performRequestWithHandler:^(NSData *responseData,
                                                      NSHTTPURLResponse *urlResponse,
                                                      NSError *error)
                  {
                      dispatch_async(dispatch_get_main_queue(), ^
                                     {
                                         // Check if we reached the rate limit.
                                         if ([urlResponse statusCode] == 429)
                                         {
                                             NSLog(@"Rate limit reached");
                                             return;
                                         }
                                         
                                         // Check if there was an error
                                         if (error)
                                         {
                                             NSLog(@"Error: %@", error.localizedDescription);
                                             return;
                                         }
                                         
                                         // Check if there is some response data.
                                         if (responseData)
                                         {
                                             NSError *error = nil;
                                             NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                                        options:NSJSONReadingMutableLeaves
                                                                                                          error:&error];
                                             
                                             NSArray *users = dictionary[@"users"];
                                             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                             friendList = [NSMutableArray arrayWithArray:users];
                                             

                                             NSLog(@"Users: %@", users);
                                             friendList = [NSMutableArray arrayWithArray:users];
                                             NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                                             friendList = [NSMutableArray arrayWithArray:[friendList sortedArrayUsingDescriptors:@[sortDescriptor]]];
                                             
                                             [friendsView reloadData];
                                         }
                                     });
                  }];
             }
             else
             {
                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                 NSLog(@"No accounts");
             }
         } else {
             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
             NSLog(@"No access granted");
         }
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
     }];
}

#pragma mark - Facebook Friends
- (void)loadFacebookFriends{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"fbFriends"] || [[defaults objectForKey:@"fbFriends"] count] == 0) {
        [self openFacebookSession];
    }else{
        friendList = [defaults objectForKey:@"fbFriends"];
        [friendsView reloadData];
    }
}

- (void)openFacebookSession{
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession setActiveSession: [[FBSession alloc] initWithPermissions:@[@"public_profile", @"email", @"user_friends"]] ];
    
    [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *fbsession, FBSessionState status, NSError *error) {
        switch (status) {
            case FBSessionStateOpen:
                // call the legacy session delegate
                //Now the session is open do corresponding UI changes
                session = fbsession;
                [self updateForSessionChangeForSlot:1];
                break;
            case FBSessionStateClosedLoginFailed:
            { // prefer to keep decls near to their use
                
            }
                break;
                // presently extension, log-out and invalidation are being implemented in the Facebook class
            default:
                break; // so we do nothing in response to those state transitions
        }
    }];
}

- (void)updateForSessionChangeForSlot:(int)slot {
    if (session.isOpen) {
        // fetch profile info such as name, id, etc. for the open session
        // Fetch user data
        FBRequest *me = [[FBRequest alloc] initWithSession:session
                                                 graphPath:@"me/friends"];
        
        [me startWithCompletionHandler:^(FBRequestConnection *connection,
                                         NSDictionary<FBGraphUser> *user,
                                         NSError *error) {
            
            // we interpret an error in the initial fetch as a reason to
            // fail the user switch, and leave the application without an
            // active user (similar to initial state)
            if (error) {
                NSLog(@"error=%@",error);
                NSLog(@"Couldn't switch user: %@", error.localizedDescription);
                [self switchToNoActiveUser];
                return;
            }else{
                NSLog(@"user=%@",user);
                friendList = [NSMutableArray arrayWithArray:user[@"data"]];
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                friendList = [NSMutableArray arrayWithArray:[friendList sortedArrayUsingDescriptors:@[sortDescriptor]]];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:friendList forKey:@"fbFriends"];
                [defaults synchronize];
                
                [friendsView reloadData];
            }
        }];
        
    } else {
        // in the closed case, we check to see if we picked up a cached token that we
        // expect to be valid and ready for use; if so then we open the session on the spot
        if (session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [session openWithCompletionHandler:^(FBSession *session,
                                                 FBSessionState status,
                                                 NSError *error) {
                [self updateForSessionChangeForSlot:slot];
            }];
        }
    }
}

- (void)switchToNoActiveUser {
    session = nil;
    session=[[FBSession alloc]initWithPermissions:@[@"public_profile", @"email", @"user_friends"]];
}

#pragma mark - UITableview delegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return friendList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FriendCell *myCell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    
    if (!myCell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:nil options:nil];
        for (id object in objects){
            if ([object isKindOfClass:[FriendCell class]]) {
                myCell = object;
            }
        }
    }

    myCell.selectionStyle = UITableViewCellSelectionStyleNone;

    CALayer *roundRect = [myCell.imgView layer];
    [roundRect setCornerRadius:myCell.imgView.frame.size.width / 2];
    [roundRect setMasksToBounds:YES];
    
    if (socialPicker.selectedSegmentIndex == 0) {
        FBGraphObject *dict = [friendList objectAtIndex:indexPath.row];
        NSString *imgUrlString = dict[@"picture"][@"data"][@"url"];
        
        [myCell.imgView sd_setImageWithURL:[NSURL URLWithString:[imgUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                 placeholderImage:[UIImage imageNamed:@"my_avatar_icon.png"]];
        myCell.nameLabel.text = dict[@"name"];
        
        NSLog(@"%@", dict);

    }else if (socialPicker.selectedSegmentIndex == 1){
        NSDictionary *dict = [friendList objectAtIndex:indexPath.row];
        NSString *imgUrlString = dict[@"profile_image_url"];
        [myCell.imgView sd_setImageWithURL:[NSURL URLWithString:[imgUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
    placeholderImage:[UIImage imageNamed:@"my_avatar_icon.png"]];
        myCell.nameLabel.text = dict[@"name"];
        
        NSLog(@"%@", dict);
        
    }else if (socialPicker.selectedSegmentIndex == 2){
        NSDictionary *dict = [friendList objectAtIndex:indexPath.row];
        myCell.imgView.image = dict[@"image"];
        myCell.nameLabel.text = dict[@"name"];
        
        NSLog(@"%@", dict);
        
    }
    

    return myCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
