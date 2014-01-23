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
#import "UIBarButtonItem+_projectButtons.h"

@interface LTBuryItViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate>
{
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextView *thoughtTextView;
    IBOutlet UISegmentedControl *timeframeSegmentedControl;
    IBOutlet UILabel *messagesToUserLabel;
    UIColor *errorColor;
    UIColor *successColor;
    NSData *selectedImageData;
    
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
}

- (IBAction)cameraButtonTapped:(id)sender;

-(IBAction)dismissKeyboardAndCheckInput:(id)sender;

-(void)setMessageToUserForTimeframe;

-(void)clearMessageToUser;

-(BOOL)validateFields;

//UITextField Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField;
-(BOOL)textFieldDidBeginEditing:(UITextField *)textField;

// UITextView Delegate Methods
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
-(BOOL)textViewDidBeginEditing:(UITextView *)textView;

-(IBAction)buryIt:(id)sender;

-(NSNumber *)getDaysSinceLaunch;
-(NSNumber *)getIntervalOfDay;
-(NSNumber *)getNumberOfIntervalsInADay;

-(PFObject *)getAppVariables; // returns an instance of the appVariables

@end
