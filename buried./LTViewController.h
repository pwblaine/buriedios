//
//  LTViewController.h
//  buried.
//
//  Created by Loftier Thoughts on 12/18/13.
//  Copyright (c) 2013 Loftier Thoughts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LTViewController : UIViewController
{
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextView *thoughtTextView;
    IBOutlet UISegmentedControl *timeframeSegmentedControl;
    IBOutlet UILabel *messagesToUserLabel;
    UIColor *errorColor;
    UIColor *successColor;
}

-(IBAction)dismissKeyboardAndCheckInput:(id)sender;

-(void)clearMessageToUser;

-(BOOL)validateFields;

//UITextField Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField;
-(BOOL)textFieldDidBeginEditing:(UITextField *)textField;

// UITextView Delegate Methods
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
-(BOOL)textViewDidBeginEditing:(UITextView *)textView;

-(IBAction)buryIt:(id)sender;

-(PFObject *)adjustCapsuleDeliveryForForTimeframe:(PFObject *)capsule;

-(NSNumber *)getDaysSinceLaunch;
-(NSNumber *)getIntervalOfDay;
-(NSNumber *)getNumberOfIntervalsInADay;

-(PFObject *)getAppVariables; // returns an instance of the appVariables
  
@end
