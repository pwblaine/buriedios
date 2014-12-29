//
//  LTBuryItViewController.h
//  buried.
//
//  Created by Mitch Solomon on 12/24/13.
//  Copyright (c) 2013 Loftier Thoughts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MBProgressHUD.h"
#import "LTGrassViewController.h"

@interface LTBuryItViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate, FBFriendPickerDelegate, UIActionSheetDelegate, LTGrassViewControllerDelegate>
{
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextView *thoughtTextView;
    IBOutlet UISegmentedControl *timeframeSegmentedControl;
    IBOutlet UILabel *messagesToUserLabel;
    IBOutlet UIButton   *buryItButton;
    
    UIColor *errorColor;
    UIColor *successColor;
    UIImage *theImage;
    
    UIActionSheet *cameraActionSheet;
    
    MBProgressHUD *HUD;
}

@property UIImage *capsuleImage;
@property NSString *capsuleThought;
@property enum UIImagePickerControllerSourceType source;
@property BOOL launchedPickerForLibrary;
@property BOOL libraryPictureKept;

-(IBAction)pickFriendsButtonClick:(id)sender;
-(IBAction)presentActionSheetForImageUpload;
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;

-(IBAction)cameraButtonTapped:(id)sender;
-(IBAction)showCamera:(id)sender;
-(IBAction)showLibraryPicker:(id)sender;
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

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo;

- (void)hudWasHidden:(MBProgressHUD *)hud;

- (LTGrassState)defaultGrassStateForView;

@end
