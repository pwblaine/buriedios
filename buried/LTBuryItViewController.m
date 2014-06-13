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
#import "LTUnearthedViewController.h"
#import "UIBarButtonItem+_projectButtons.h"
#import "LTAppDelegate.h"

@interface LTBuryItViewController ()

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

@end

@implementation LTBuryItViewController

@synthesize capsuleImage, capsuleThought;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
        
    }
    return self;
}

#pragma mark View Lifecycle

- (void) applyImagePreview {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);

    NSLog(@"shrinking image height/width for button, original sizing: %f x %f",self->theImage.size.width,self->theImage.size.height);
    if (theImage)
    {
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(24, 24));
        [theImage drawInRect: CGRectMake(0, 0, 24, 24)];
        UIImage *buttonImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        // replace camera with image
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem customNavBarButtonWithTarget:self action:@selector(cameraButtonTapped:) withImage:buttonImage];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![(LTAppDelegate *)[[UIApplication sharedApplication] delegate] grassIsShowing] || [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] grassIsShrunk])
    [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] showGrass:YES animated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    if (self.capsuleThought)
        self->thoughtTextView.text = self.capsuleThought;
    
    if (self.capsuleImage)
        self->theImage = self.capsuleImage;
    
    /*Parse.com Object Submit Code
     PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
     testObject[@"foo"] = @"bar";
     [testObject saveInBackground];*/
    
	// Do any additional setup after loading the view, typically from a nib.
    
    errorColor = [UIColor colorWithRed:111/255.0f green:0/255.0f blue:8/255.0f alpha:1.0f];
    successColor = [UIColor colorWithRed:25/255.0f green:96/255.0f blue:36/255.0f alpha:1.0f];
    
    // Add logout navigation bar button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // Add camera navigation bar button
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonTapped:)];
    self.navigationItem.rightBarButtonItem = cameraButton;
    
    if (theImage)
        [self applyImagePreview];
    
        [self checkForItemsAndSetClearOrCancel];
    
    // Add the temporary title
    self.title = @"New Capsule";
    [self setMessageToUserForTimeframe];
    
    emailTextField.placeholder = @"for my eyes only";
}


- (void)viewDidUnload {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self.friendPickerController = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

-(IBAction)dismissKeyboardAndCheckInput:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self.view endEditing:YES];
    [self checkForItemsAndSetClearOrCancel];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    return YES;
}

-(void)clearMessageToUser
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    messagesToUserLabel.text = @"";
}

-(BOOL)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    return YES;
}

-(BOOL)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboardAndCheckInput:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTouchHandler:)];
    return YES;
}

-(void)setMessageToUserForTimeframe {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
messagesToUserLabel.textColor = [UIColor lightGrayColor];
    if ([[timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex] isEqualToString:@"soon"])
messagesToUserLabel.text = @"will unearth within a week ";
    else if ([[timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex] isEqualToString:@"later"])
        messagesToUserLabel.text = @"will unearth within a month";
    else if ([[timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex] isEqualToString:@"someday"])
        messagesToUserLabel.text = @"will unearth within a few months";
    else if ([[timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex] isEqualToString:@"forgotten"])
        messagesToUserLabel.text = @"will unearth within a year";
    else
    {
        messagesToUserLabel.textColor = errorColor;
        messagesToUserLabel.text = @"every journey needs to end sometime...";
    }
    
}

-(IBAction)timeframeClicked:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self setMessageToUserForTimeframe];
}

-(BOOL)checkForItemsAndSetClearOrCancel
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    // Test for items in the capsule if so change the button to cancel
    if (theImage || thoughtTextView.text.length > 0 || self.friendPickerController.selection.count > 0)
    {
        if (theImage)
            [self applyImagePreview];
        else
            [self resetCamera];
        UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonTouchHandler:)];
        self.navigationItem.leftBarButtonItem = clearButton;
        return YES;
    } else {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelButtonTouchHandler:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        if (theImage)
            [self applyImagePreview];
        else
            [self resetCamera];
        return NO;
    }
}

-(BOOL)validateFields
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSString *thought = thoughtTextView.text;
    if (thought.length == 0 && !theImage) {
        messagesToUserLabel.textColor = errorColor;
        messagesToUserLabel.text = @"nothing buried, nothing gained...";
        return NO;
    }
    return YES;
}

-(void)resetCamera
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    // Add camera navigation bar button
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonTapped:)];
    self.navigationItem.rightBarButtonItem = cameraButton;
}

-(void)discardPhoto
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    theImage = nil;
    messagesToUserLabel.text = @"photo discarded";
    messagesToUserLabel.textColor =  errorColor;
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(setMessageToUserForTimeframe) userInfo:nil repeats:NO];
    [self checkForItemsAndSetClearOrCancel];
}

-(BOOL)clearFields
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    emailTextField.text = @"";
    thoughtTextView.text = @"";
    [self.friendPickerController clearSelection];
    
    [timeframeSegmentedControl setSelectedSegmentIndex:0];
    
    theImage = nil;
    [self resetCamera];
    
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonTapped:)];
    self.navigationItem.rightBarButtonItem = cameraButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    
    return YES;
}

#pragma mark
-(IBAction)buryIt:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    PFUser *user = [PFUser currentUser];
    if ([self validateFields])
    {
        NSLog(@"all fields validated successfully, sending...");
        PFObject *capsule = [PFObject objectWithClassName:@"capsule"];
        NSString *thought = thoughtTextView.text;
        
        NSString *timeframe = [timeframeSegmentedControl titleForSegmentAtIndex:timeframeSegmentedControl.selectedSegmentIndex];
        
        capsule[@"thought"] = thought;
        capsule[@"timeframe"] = timeframe;
        capsule[@"fromUserId"] = [user objectId];
        
        // create mutable arrays for user id testing
        NSMutableArray *mutableToUserIds = [NSMutableArray arrayWithObject:user.objectId];
        NSMutableArray *mutableToFbIds = [NSMutableArray array];
        
        // for everyone in the friendPicker, if they exist store the PFUser
        // if they don't have a buried account, store the facebookId
         for (FBGraphObject<FBGraphUser> *fbUser in self.friendPickerController.selection)
         {
             PFQuery *userQuery = [PFUser query];
             [userQuery whereKey:@"facebookId" equalTo:[fbUser objectID]];
             NSArray *objects = [userQuery findObjects];
             NSLog(@"query executed");
             if (objects.count < 1)
             {
                 NSLog(@"matching facebookId not found, storing facebookId");
                 [mutableToFbIds addObject:[fbUser objectID]];
             }
             else
             {
                 [mutableToUserIds addObject:[[objects firstObject] objectId]];
             }
         }
        
        //convert the mutable arrays to NSArrays for storage;
        capsule[@"toUserIds"] = [NSArray arrayWithArray:mutableToUserIds];
        capsule[@"toFbIds"] = [NSArray arrayWithArray:mutableToFbIds];
        for (UIButton *button in self.view.subviews) {
            button.enabled = NO;
        };
        
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        // Set indeterminate mode
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.delegate = self;
        HUD.labelText = @"burying capsule";
        [HUD show:YES];
        
        // Save capsule
        [capsule saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                
                if (self->theImage) {
                    
                    NSLog(@"image detected, uploading...");
                    
                    // Set indeterminate mode
                    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
                    HUD.labelText = @"digging the hole";
                    
                    //shrink the stored image resolution to 1136x852 (the maximum that will be displayed while maintaining aspect resolution)
                    UIImage *adjustedImage = self->theImage;
                    
                    if (self->theImage.size.width < 852 || self->theImage.size.height < 852)
                    {
                        NSLog(@"low quality image detected, no resizing needed.  %dx%f", self->theImage.size.width < 852, self->theImage.size.height);
                    // test for portrait or landscape picture and set dimensions appropriately
                    }
                    else if (self->theImage.size.height > self->theImage.size.width)
                    {
                        NSLog(@"portrait image detected, setting resolution to 852x1136");
                        UIGraphicsBeginImageContext(CGSizeMake(852, 1136));
                        [self->theImage drawInRect: CGRectMake(0, 0, 852, 1136)];
                        adjustedImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                    } else {
                        NSLog(@"landscape image detected, setting resolution to 1136x852");
                        UIGraphicsBeginImageContext(CGSizeMake(1136, 852));
                        [self->theImage drawInRect: CGRectMake(0, 0, 1136, 852)];
                        adjustedImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                    }
                    
                    // set to web average compression factor of 75%
                    NSData *selectedImageData = UIImageJPEGRepresentation(adjustedImage, 0.75f);
                    
                    NSDateFormatter *webSafeDateFormat = [[NSDateFormatter alloc] init];
                    [webSafeDateFormat setDateFormat:@"dd_MM_yyyy-HH_mm_ss-Z"];
                    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@-%@.jpg",user.objectId,[webSafeDateFormat stringFromDate:[NSDate date]]] data:selectedImageData];
                    
                    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded)
                        {
                        NSLog(@"image uploaded successfully");
                        HUD.mode = MBProgressHUDModeCustomView;
                        
                        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                        
                        HUD.labelText = @"it's buried.";
                        
                        NSLog(@"a thought was buried for %@ by %@ and will be delivered %@",capsule[@"toUserIds"], capsule[@"fromUserId"], capsule[@"timeframe"]);
                            
                            capsule[@"image"] = imageFile;
                            
                            [capsule saveEventually:^(BOOL succeeded, NSError *error) {
                                if (succeeded)
                                    NSLog(@"capsule %@ is now linked to image %@",[capsule objectId],[imageFile name]);
                                else
                                    NSLog(@"capsule %@ was not linked to image %@, please contact the developers",[capsule objectId],[imageFile name]);
                            }];
                            
                            NSLog(@"capsule contents: %@",capsule);
                        
                            [self clearFields];
                        
                            [NSTimer scheduledTimerWithTimeInterval:1 target:self.navigationController selector:@selector(popViewControllerAnimated:) userInfo:@YES repeats:NO];
                        } else {
                            
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
                        
                    } progressBlock:^(int percentDone) {
                        NSLog(@"%i%%",percentDone);
                        if (percentDone >= 80)
                            HUD.labelText = @"piling on dirt";
                        [HUD setProgress:(float)percentDone/100.0f];
                    }];
                } else {
                    // Show checkmark
                    
                    HUD.labelText = @"it's buried.";
                    
                    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                    
                    // Set custom view mode
                    HUD.mode = MBProgressHUDModeCustomView;
                    
                    NSLog(@"a thought was buried for %@ by %@ and will be delivered %@",capsule[@"email"], capsule[@"from"], capsule[@"timeframe"]);
                    
                    NSLog(@"capsule contents: %@",capsule);
                    
                    
                    [self clearFields];
                    
                    [NSTimer scheduledTimerWithTimeInterval:1 target:self.navigationController selector:@selector(popViewControllerAnimated:) userInfo:@YES repeats:NO];
                    
                }
                
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

- (IBAction)presentActionSheetForImageUpload
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Bury An Image In The Capsule" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take A Photo",@"Choose From Library", nil];
    self->cameraActionSheet = actionSheet;
    [self->cameraActionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSLog(@"buttonIndex == %ld", (long)buttonIndex);
    if (buttonIndex == self->cameraActionSheet.cancelButtonIndex)
        [self checkForItemsAndSetClearOrCancel]; // if cancel button tapped cancel out
    else if (buttonIndex == self->cameraActionSheet.firstOtherButtonIndex)
        [self showCamera:self->cameraActionSheet]; // if camera button tapped show camera
    else
        [self showLibraryPicker:self->cameraActionSheet]; // if library button tapped show library
}

- (IBAction)cameraButtonTapped:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (!theImage)
    {
        [self presentActionSheetForImageUpload];
    } else {
        LTPhotoDetailViewController *photoDetailViewController = [[LTPhotoDetailViewController alloc] init];
        photoDetailViewController.theImage = theImage;
        photoDetailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        photoDetailViewController.callingViewController = self;
        [self presentViewController:photoDetailViewController animated:YES completion:nil];
    }
}

#pragma mark Cancel Button methods

- (void)cancelButtonTouchHandler:(id)sender {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if ([self->thoughtTextView isFirstResponder])
    {
        self->thoughtTextView.text = @"";
        [self dismissKeyboardAndCheckInput:self];
    }
    else if ([self checkForItemsAndSetClearOrCancel])
    {
        [self clearFields];
        messagesToUserLabel.text = @"capsule cleared";
        messagesToUserLabel.textColor =  errorColor;
        [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(setMessageToUserForTimeframe) userInfo:nil repeats:NO];
        [self checkForItemsAndSetClearOrCancel];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark UIImagePickerControllerDelegate methods

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (error) {
        // Do anything needed to handle the error or display it to the user
        NSLog(@"image did not save successfully, error: %@ contextInfo:%@", error, ctxInfo);
    } else {
        // .... do anything you want here to handle
        // .... when the image has been saved in the photo album
        NSLog(@"image did save successfully, contextInfo:%@", ctxInfo);
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:NO completion:^{
        LTPhotoDetailViewController *photoVC = [[LTPhotoDetailViewController alloc] init];
        photoVC.theImage = image;
        photoVC.callingViewController = self;

        // save the image to the library if taken from a camera
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            NSLog(@"imagePicker used camera");
        } else {
            NSLog(@"imagePicker did not use camera");
            photoVC.launchedFromLibrary = true;
        }
        [self presentViewController:photoVC animated:NO completion:^{
            NSLog(@"photoVC presented");
        }];
    }];
    
    // store the image in a variable
    self->theImage = image;
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(32, 32));
    [image drawInRect: CGRectMake(0, 0, 32, 32)];
    UIImage *buttonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Tint Camera button after picture taken
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customNavBarButtonWithTarget:self action:@selector(cameraButtonTapped:) withImage:buttonImage];
    
    messagesToUserLabel.textColor = successColor;
    messagesToUserLabel.text = @"photo attached";
    
    [self checkForItemsAndSetClearOrCancel];

}

#pragma mark - Partner Classes
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    // Remove HUD from screen when the HUD hides
    [HUD removeFromSuperview];
	HUD = nil;
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

#pragma mark FPFriendPickerDelegate methods

- (IBAction)pickFriendsButtonClick:(id)sender {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
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
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSMutableString *text = [[NSMutableString alloc] init];
    if (self.friendPickerController.selection.count >= 1) {
        [text appendString:[[self.friendPickerController.selection objectAtIndex:0] name]];
        if (self.friendPickerController.selection.count > 1)
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
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self fillTextBoxAndDismiss:emailTextField.text];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    emailTextField.text = text;
    [self checkForItemsAndSetClearOrCancel];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)showCamera:(id)sender
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
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
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
}

-(IBAction)showLibraryPicker:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        // Create image picker controller
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        // Set source to the camera
        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        
        // Delegate is self
        imagePicker.delegate = self;
        
        // Show image picker
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

@end
