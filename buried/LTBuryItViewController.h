//
//  LTBuryItViewController.h
//  buried.
//
//  Created by Mitch Solomon on 12/24/13.
//  Copyright (c) 2013 Loftier Thoughts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface LTBuryItViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate, FBFriendPickerDelegate, NSURLConnectionDelegate>
{
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextView *thoughtTextView;
    IBOutlet UISegmentedControl *timeframeSegmentedControl;
    IBOutlet UILabel *messagesToUserLabel;
    UIColor *errorColor;
    UIColor *successColor;
    UIImage *theImage;
    NSMutableData *profileImageData;
    
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
}

#pragma mark - NSURLConnectionDataDelegate

/* Callback delegate methods used for downloading the user's profile picture */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)updateUserProfile;

- (IBAction)pickFriendsButtonClick:(id)sender;

- (IBAction)cameraButtonTapped:(id)sender;
-(void)discardPhoto;
-(void)resetCamera;

-(IBAction)dismissKeyboardAndCheckInput:(id)sender;

-(void)setMessageToUserForTimeframe;

-(void)clearMessageToUser;

-(BOOL)validateFields;
-(BOOL)clearFields;
-(BOOL)checkForItems;

//UITextField Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField;
-(BOOL)textFieldDidBeginEditing:(UITextField *)textField;

// UITextView Delegate Methods
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
-(BOOL)textViewDidBeginEditing:(UITextView *)textView;

-(IBAction)buryIt:(id)sender;


@end
