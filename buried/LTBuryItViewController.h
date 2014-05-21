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

@interface LTBuryItViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate, FBFriendPickerDelegate>
{
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextView *thoughtTextView;
    IBOutlet UISegmentedControl *timeframeSegmentedControl;
    IBOutlet UILabel *messagesToUserLabel;
    UIColor *errorColor;
    UIColor *successColor;
    UIImage *theImage;
    
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
}

@property UIImage *capsuleImage;
@property NSString *capsuleThought;

-(IBAction)pickFriendsButtonClick:(id)sender;

-(IBAction)cameraButtonTapped:(id)sender;
-(void)discardPhoto;
-(void)resetCamera;

-(IBAction)dismissKeyboardAndCheckInput:(id)sender;

-(void)setMessageToUserForTimeframe;

-(void)clearMessageToUser;

-(BOOL)validateFields;
-(BOOL)clearFields;
-(BOOL)checkForItemsAndSetClearOrCancel;

//UITextField Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField;
-(BOOL)textFieldDidBeginEditing:(UITextField *)textField;

// UITextView Delegate Methods
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
-(BOOL)textViewDidBeginEditing:(UITextView *)textView;

-(IBAction)buryIt:(id)sender;


@end
