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
#import "LTGrassViewController.h"

@interface LTStartScreenViewController : UIViewController <MBProgressHUDDelegate, PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate, LTGrassViewControllerDelegate, UITextFieldDelegate>
{
    IBOutlet UILabel *lastLoggedInLabel;
    NSString *savedDisplayName;
    
    IBOutlet UIView *signUpView;
    IBOutlet UIView *loginView;
    IBOutlet UIView *savedAccountView;
    IBOutlet UIView *sharedFieldsView;
    IBOutlet UIView *startView;
    
    UIView *currentViewState;
    NSMutableArray *currentViewElements;
    IBOutlet UIImageView *buriedLogo;
    
    IBOutlet UIButton *forgotPasswordButton;
    IBOutlet UIButton *facebookLoginButton;
    
    CGPoint originalViewCenter;
    
    CGRect topLogoPosition;
    CGRect centerLogoPostition;
    
    UIBarButtonItem *signInButton;
    UIBarButtonItem *signUpButton;
    UIBarButtonItem *continueButton;
    UIBarButtonItem *submitButton;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *notYouButton;
    
    MBProgressHUD *HUD;
    UITextField *currentResponder;
    UITapGestureRecognizer *closeTextFieldGesture;
    NSMutableArray *currentTextFields;
}

@property IBOutlet UITextField *usernameField;
@property IBOutlet UITextField *passwordField;
@property IBOutlet UITextField *confirmField;
@property IBOutlet UITextField *emailField;
@property NSDictionary *userInfo;

@property (retain) PFSignUpViewController *signUpVC;
@property (retain) PFLogInViewController *logInVC;

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

-(LTGrassState)defaultGrassStateForView;

@end
