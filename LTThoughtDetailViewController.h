//
//  LTThoughtDetailViewController.h
//  buried
//
//  Created by Patrick Blaine on 5/14/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTThoughtDetailViewController : UIViewController <UIAlertViewDelegate>
{
    IBOutlet UITextView *thoughtView;
    IBOutlet UIToolbar *topToolbar;
    IBOutlet UIBarButtonItem *actionButton;
}

@property NSString *theThought;
@property (retain) UIViewController *callingViewController;

-(IBAction)actionButtonTouched:(id)sender;
-(IBAction)doneButtonTouched:(id)sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
