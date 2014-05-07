//
//  LTBuryItViewController.m
//  buried.
//
//  Created by Mitch Solomon on 12/24/13.
//  Copyright (c) 2013 Loftier Thoughts. All rights reserved.
//

#import "LTBuryItViewController.h"
#import "LTPhotoDetailViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "UIBarButtonItem+_projectButtons.h"
#import "LTAppDelegate.h"

@interface LTBuryItViewController ()

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) NSString *selectedFBEmailString;

@end

@implementation LTBuryItViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark View Lifecycle

- (void) applyImagePreview {
    
    if (theImage)
    {
// Resize image
UIGraphicsBeginImageContext(CGSizeMake(32, 32));
[theImage drawInRect: CGRectMake(0, 0, 32, 32)];
UIImage *buttonImage = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();

// Tint Camera button after picture taken
self.navigationItem.rightBarButtonItem = [UIBarButtonItem customNavBarButtonWithTarget:self action:@selector(cameraButtonTapped:) withImage:buttonImage];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*Parse.com Object Submit Code
     PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
     testObject[@"foo"] = @"bar";
     [testObject saveInBackground];*/
    
	// Do any additional setup after loading the view, typically from a nib.
    
    errorColor = [UIColor colorWithRed:111/255.0f green:0/255.0f blue:8/255.0f alpha:1.0f];
    successColor = [UIColor colorWithRed:25/255.0f green:96/255.0f blue:36/255.0f alpha:1.0f];
    
    // Add logout navigation bar button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // Add camera navigation bar button
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonTapped:)];
    self.navigationItem.rightBarButtonItem = cameraButton;
    
    if (theImage)
        [self applyImagePreview];
    
    if (theImage)
        [self checkForItemsAndSetClearOrCancel];
    
    // Add the temporary title
    self.title = @"New Capsule";
    [self setMessageToUserForTimeframe];
    
    emailTextField.placeholder = @"for my eyes only";
    
    LTAppDelegate *appDelegate = (LTAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showGrass:NO];
}


- (void)viewDidUnload {
    self.friendPickerController = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)dismissKeyboardAndCheckInput:(id)sender
{
    [self.view endEditing:YES];
    [self checkForItemsAndSetClearOrCancel];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyboardAndCheckInput:NULL];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // dismisses keyboard when the return key is pressed
    
    if([text isEqualToString:@"\n"]) {
        [self dismissKeyboardAndCheckInput:NULL];
        return NO;
    }
    
    return YES;
}

-(void)clearMessageToUser
{
    messagesToUserLabel.text = @"";
}

-(BOOL)textFieldDidBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textViewDidBeginEditing:(UITextView *)textView
{
    return YES;
}

-(void)setMessageToUserForTimeframe {
messagesToUserLabel.textColor = [UIColor lightGrayColor];
    if ([[timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex] isEqualToString:@"soon"])
messagesToUserLabel.text = @"will unearth in the next 24 hours";
    else if ([[timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex] isEqualToString:@"later"])
        messagesToUserLabel.text = @"will unearth in the next 2-7 days";
    else if ([[timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex] isEqualToString:@"someday"])
        messagesToUserLabel.text = @"will unearth in the next 1-4 weeks";
    else if ([[timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex] isEqualToString:@"forgotten"])
        messagesToUserLabel.text = @"will unearth in the next 1-3 months";
    else
    {
        messagesToUserLabel.textColor = errorColor;
        messagesToUserLabel.text = @"every journey needs to end sometime...";
    }
    
}

-(IBAction)timeframeClicked:(id)sender
{
    [self setMessageToUserForTimeframe];
}

-(BOOL)checkForItemsAndSetClearOrCancel
{
    // Test for items in the capsule if so change the button to cancel
    if (theImage || thoughtTextView.text.length > 0 || self.selectedFBEmailString.length > 0 || self.friendPickerController.selection.count > 0)
    {
        if (theImage)
            [self applyImagePreview];
        self.navigationItem.leftBarButtonItem.title = @"Clear";
        return YES;
    } else {
        self.navigationItem.leftBarButtonItem.title = @"Cancel";
        return NO;
    }
}

-(BOOL)validateFields
{
    
    // Get contents of fields
   // NSString *email = emailTextField.text;
    NSString *thought = thoughtTextView.text;
    
    // create email validation regex & predicate
   // NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
   // NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    /*
    if (([emailTest evaluateWithObject:email] == NO && ![email isEqualToString:@""]) || ([[[PFUser currentUser] email] isEqualToString:nil])) {
        // test that email is in correct format
         TODO removed due to change in app structure 2/12/2014
         messagesToUserLabel.textColor = errorColor;
        messagesToUserLabel.text = @"your thought needs someone to find it...";
        return NO;
     
        return YES;
    } else
        */
    // either/or for delivery
    if (thought.length == 0 && !theImage) {
        messagesToUserLabel.textColor = errorColor;
        messagesToUserLabel.text = @"nothing buried, nothing gained...";
        return NO;
    }
    return YES;
}

-(void)resetCamera
{
    // Add camera navigation bar button
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonTapped:)];
    self.navigationItem.rightBarButtonItem = cameraButton;
}

-(void)discardPhoto
{
    theImage = nil;
    messagesToUserLabel.text = @"photo discarded";
    messagesToUserLabel.textColor =  errorColor;
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(setMessageToUserForTimeframe) userInfo:nil repeats:NO];
    [self checkForItemsAndSetClearOrCancel];
}

-(BOOL)clearFields
{
    emailTextField.text = @"";
    thoughtTextView.text = @"";
    [self.friendPickerController clearSelection];
    self.selectedFBEmailString = @"";
    
    [timeframeSegmentedControl setSelectedSegmentIndex:0];
    
    theImage = nil;
    [self resetCamera];
    
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonTapped:)];
    self.navigationItem.rightBarButtonItem = cameraButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    
    return YES;
}

-(id)createUserFor:(id<FBGraphUser>)fbUser with:(PFUser *)pfUser
{
    NSLog(@"fbUser : %@",fbUser);
    NSLog(@"pfUser : %@",pfUser);
    if ([pfUser.username isEqualToString:fbUser.id])
    {
        NSLog(@"user account %@ linked to facebook id %@",pfUser.username,fbUser.id);
        return pfUser;
    }
    
        NSLog(@"looking for username in parse user db");
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"username" equalTo:fbUser.id];
        NSArray *objects = [userQuery findObjects];
        NSLog(@"query executed");
        if (objects.count < 1)
        {
            NSLog(@"matching username not found");
            [pfUser setUsername:fbUser.id];
            [pfUser setPassword:@""];
            [pfUser signUp];
            NSLog(@"username %@ signed up",pfUser.username);
            return [self createUserFor:fbUser with:pfUser];
        }
    NSLog(@"located user in database");
    return [self createUserFor:fbUser with:(PFUser *)[objects firstObject]]; // return nothing if the account already exists}
}

-(NSArray *)createArrayOfUsers:(NSArray *)array
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (id<FBGraphUser> user in array)
    {
        PFUser *pfUser = [self createUserFor:user with:[PFUser user]];
        if (pfUser)
            [mutableArray addObject:pfUser];
        
    }
    NSLog(@"%@",mutableArray);
    return [NSArray arrayWithArray:mutableArray];
}

#pragma mark
-(IBAction)buryIt:(id)sender
{
    PFUser *user = [PFUser currentUser];
    [user fetchIfNeeded];
    NSString *email = @"";
    if (self.selectedFBEmailString.length > 0)
        email = [NSString stringWithFormat:@"%@%@",self.selectedFBEmailString,user.email];
    else
        email = [NSString stringWithFormat:@"%@",user.email];
    NSLog(@"Current recipients: %@",email);
    if ([self validateFields])
    {
        NSLog(@"all fields validated successfully, sending...");
        PFObject *capsule = [PFObject objectWithClassName:@"capsule"];
        NSString *thought = thoughtTextView.text;
        
        NSString *timeframe = [timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex];
        
        capsule[@"from"] = user.email;
        capsule[@"email"] = email;
        capsule[@"thought"] = thought;
        capsule[@"timeframe"] = timeframe;
        capsule[@"fromUser"] = user;
        
        // create mutable arrays for user id testing
        NSMutableArray *mutableToUserIds = [NSMutableArray arrayWithObject:user.objectId];
        NSMutableArray *mutableToFbIds = [NSMutableArray array];
        
        // for everyone in the friendPicker, if they exist store the PFUser
        // if they don't have a buried account, store the facebookId
         for (id<FBGraphUser> fbUser in self.friendPickerController.selection)
         {
             PFQuery *userQuery = [PFUser query];
             [userQuery whereKey:@"facebookId" equalTo:fbUser.id];
             NSArray *objects = [userQuery findObjects];
             NSLog(@"query executed");
             if (objects.count < 1)
             {
                 NSLog(@"matching facebookId not found, storing facebookId");
                 [mutableToFbIds addObject:[fbUser id]];
             }
             else
             {
                 [mutableToUserIds addObject:[[objects firstObject] objectId]];
             }
         }
        
        //convert the mutable arrays to NSArrays for storage;
        capsule[@"toUserIds"] = [NSArray arrayWithArray:mutableToUserIds];
        capsule[@"toFbIds"] = [NSArray arrayWithArray:mutableToFbIds];

        if (theImage) {
            NSData *selectedImageData = UIImageJPEGRepresentation(self->theImage, 0.05f);
        
            PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@_%@.jpg",user.objectId,[NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]] data:selectedImageData];
        
            capsule[@"image"] = imageFile;
        }
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        
        for (UIButton *button in self.view.subviews) {
            button.enabled = NO;
        };
        
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        [self.view addSubview:HUD];
        
        // Set determinate mode
        HUD.mode = MBProgressHUDModeDeterminate;
        HUD.delegate = self;
        HUD.labelText = @"burying";
        [HUD show:YES];
        
        // Save PFFile
        [capsule saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                
                HUD.progress = 1.0f;
                
            //Hide determinate HUD
            [HUD hide:YES];
            
            // Show checkmark
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
                
                HUD.labelText = @"burying";
            
            // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
            // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            
            // Set custom view mode
            HUD.mode = MBProgressHUDModeCustomView;
            
            HUD.delegate = self;
                
                [HUD show:YES];
            
                NSLog(@"a thought was buried for %@ by %@ and will be delivered %@",capsule[@"email"], capsule[@"from"], capsule[@"timeframe"]);
                
                NSLog(@"capsule contents: %@",capsule);
                
                
                [self clearFields];
                LTAppDelegate *appDelegate = (LTAppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate showGrass:YES];
                [self.navigationController popViewControllerAnimated:YES];
                
            } else{
                [HUD hide:YES];
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                
                messagesToUserLabel.textColor = errorColor;
                messagesToUserLabel.text = @":(";
                
                [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(setMessageToUserForTimeframe) userInfo:nil repeats:NO];
                for (UIButton *button in self.view.subviews) {
                    button.enabled = YES;
                };
                
                self.navigationItem.leftBarButtonItem.enabled = YES;
                self.navigationItem.rightBarButtonItem.enabled = YES;
                
            }
        }];
    }
}

#pragma mark - camera methods

- (IBAction)cameraButtonTapped:(id)sender
{
    if (!theImage)
    {
    // Check for camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        // Create image picker controller
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        // Set source to the camera
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        
        // Delegate is self
        imagePicker.delegate = self;
        
        // Show image picker
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else{
        // Device has no camera
        UIImage *image;
        int r = arc4random() % 5;
        switch (r) {
            case 0:
                image = [UIImage imageNamed:@"ParseLogo.jpg"];
                break;
            case 1:
                image = [UIImage imageNamed:@"Crowd.jpg"];
                break;
            case 2:
                image = [UIImage imageNamed:@"Desert.jpg"];
                break;
            case 3:
                image = [UIImage imageNamed:@"Lime.jpg"];
                break;
            case 4:
                image = [UIImage imageNamed:@"Sunflowers.jpg"];
                break;
            default:
                break;
        }
        
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(32, 32));
        [image drawInRect: CGRectMake(0, 0, 32, 32)];
        UIImage *buttonImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Tint Camera button after picture taken
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem customNavBarButtonWithTarget:self action:@selector(cameraButtonTapped:) withImage:buttonImage];
        
        messagesToUserLabel.textColor = successColor;
        messagesToUserLabel.text = @"photo attached";
        
        theImage = image;
        
        [self checkForItemsAndSetClearOrCancel];
        }
    } else {
        LTPhotoDetailViewController *photoDetailViewController = [[LTPhotoDetailViewController alloc] init];
        photoDetailViewController.theImage = theImage;
        photoDetailViewController.callingViewController = self;
        photoDetailViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        [self presentViewController:photoDetailViewController animated:YES completion:nil];
    }
}

#pragma mark Cancel Button methods

- (void)cancelButtonTouchHandler:(id)sender {
    if ([self checkForItemsAndSetClearOrCancel])
    {
        [self clearFields];
        messagesToUserLabel.text = @"capsule cleared";
        messagesToUserLabel.textColor =  errorColor;
        [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(setMessageToUserForTimeframe) userInfo:nil repeats:NO];
        [self checkForItemsAndSetClearOrCancel];
    } else {
        
        LTAppDelegate *appDelegate = (LTAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showGrass:YES];
    [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // Save the image
    theImage = image;
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(32, 32));
    [image drawInRect: CGRectMake(0, 0, 32, 32)];
    UIImage *buttonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Tint Camera button after picture taken
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customNavBarButtonWithTarget:self action:@selector(cameraButtonTapped:) withImage:buttonImage];
    
    [self checkForItemsAndSetClearOrCancel];
    
    
}

#pragma mark - Partner Classes
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [HUD removeFromSuperview];
	HUD = nil;
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

#pragma mark FPFriendPickerDelegate methods

- (IBAction)pickFriendsButtonClick:(id)sender {
    // FBSample logic
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles:nil];
                                              [alertView show];
                                          } else if (session.isOpen) {
                                              [self pickFriendsButtonClick:sender];
                                          }
                                      }];
        return;
    }
    
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    //[self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    self.selectedFBEmailString = nil;
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        FBRequest *request = [FBRequest requestForMyFriends];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error)
            {
            NSDictionary<FBGraphUser> *friends = (NSDictionary<FBGraphUser> *)[result objectForKey:@"data"];
            for (id<FBGraphUser> friend in friends)
            {
                if ([friend.name isEqual:user.name])
                {
                    NSString *fbEmail = [NSString stringWithFormat:@"%@@facebook.com",friend.username];
                    [self appendEmail:fbEmail];
                }
            }
            }}];
    }
    
    if (self.friendPickerController.selection.count >= 1) {
        [text appendString:[[self.friendPickerController.selection objectAtIndex:0] name]];
        if (self.friendPickerController.selection.count >                                                      1)
        [text appendFormat:@" + %@",[NSNumber numberWithDouble:(self.friendPickerController.selection.count - 1)]];
    }
    if (text.length > 0)
    {
        [self fillTextBoxAndDismiss:text];
        
    }
    else
        [self fillTextBoxAndDismiss:nil];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self fillTextBoxAndDismiss:emailTextField.text];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    emailTextField.text = text;
    [self checkForItemsAndSetClearOrCancel];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)appendEmail:(NSString *)email {
    if (!self.selectedFBEmailString)
        self.selectedFBEmailString = [[NSString alloc] init];
        self.selectedFBEmailString = [self.selectedFBEmailString stringByAppendingFormat:@"%@,",email];
}

@end
