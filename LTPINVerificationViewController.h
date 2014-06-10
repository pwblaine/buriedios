//
//  LTPINVerificationViewController.h
//  buried
//
//  Created by Patrick Blaine on 6/8/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTPINVerificationViewController : UIViewController
{
    IBOutlet UILabel *pinLabel;
    IBOutlet UIButton *submitButton;
    IBOutlet UIButton *cancelButton;
}

@property NSString *lastLoggedInUserId;
@property NSString *lastLoggedInUserName;
@property NSString *lastLoggedInFacebookId;
@property NSString *lastLoggedInDisplayName;

-(IBAction)submitButtonTouched:(id)sender;
-(IBAction)cancelButtonTouched:(id)sender;

@end
