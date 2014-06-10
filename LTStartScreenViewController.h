//
//  LTStartScreenViewController.h
//  buried
//
//  Created by Patrick Blaine on 6/8/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LTStartScreenViewController : UIViewController <MBProgressHUDDelegate, PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate>
{
    IBOutlet UIImageView *grassImage;
    IBOutlet UILabel *lastLoggedInLabel;
    IBOutlet UIButton *notYouButton;
    
    MBProgressHUD *HUD;
}

- (void)updateFbProfileForUser:(PFUser *)user;

- (IBAction)signUpButtonTouchHandler:(id)sender;
- (IBAction)signInButtonTouchHandler:(id)sender;
- (IBAction)continueButtonTouchHandler:(id)sender;
- (IBAction)notYouButtonTouched:(id)sender;

- (void)continueToUnearthedWithFbLoginPermissionsAfterPINVerificationBy:(id)sender;

- (void)changeButtonsForContinuingUser:(NSString *)displayName;

- (void)hudWasHidden:(MBProgressHUD *)hud;

#pragma mark - PFSignup Protocol
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info;

/// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user;

/// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error;

/// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController;

@end
