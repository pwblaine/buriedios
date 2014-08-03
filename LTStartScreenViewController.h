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
    IBOutlet UIView *accountTypesView;
    
    UIView *currentViewState;
    NSMutableArray *currentViewElements;
    IBOutlet UIImageView *buriedLogo;
    
    IBOutlet UIButton *forgotPasswordButton;
    IBOutlet UIButton *facebookLoginButton;
    
    CGPoint originalViewCenter;
    
    CGRect topLogoPosition;
    CGRect centerLogoPostition;
    
    CGRect textFieldHighPosition;
    CGRect textFieldMedHighPosition;
    CGRect textFieldMedHighGroupedPosition;
    CGRect textFieldMedLowPosition;
    CGRect textFieldLowPosition;
    
    UIBarButtonItem *signInButton;
    UIBarButtonItem *signUpButton;
    UIBarButtonItem *continueButton;
    UIBarButtonItem *submitButton;
    UIBarButtonItem *goBackButton;
    UIBarButtonItem *clearButton;
    UIBarButtonItem *notYouButton;
    
    MBProgressHUD *HUD;
    UITextField *currentResponder;
    NSMutableArray *currentTextFields;
    
    CALayer *initialBorderSpecs;
}

@property IBOutlet UITextField *passwordField;
@property IBOutlet UITextField *confirmField;
@property IBOutlet UITextField *emailField;
@property NSDictionary *userInfo;

@property (retain) PFSignUpViewController *signUpVC;
@property (retain) PFLogInViewController *logInVC;

-(void)returnViewToOrigin;

- (IBAction)facebookLoginButtonTouchHandler:(id)sender;
- (IBAction)signUpButtonTouchHandler:(id)sender;
- (IBAction)signInButtonTouchHandler:(id)sender;
- (IBAction)continueButtonTouchHandler:(id)sender;
- (IBAction)notYouButtonTouched:(id)sender;
- (IBAction)goBackButtonTouchHandler:(id)sender;
- (IBAction)clearButtonTouchHandler:(id)sender;

- (void)changeButtonsForSavedUser;

- (void)hudWasHidden:(MBProgressHUD *)hud;

-(BOOL)isValidEmail:(NSString *)email;

-(BOOL)validateField:(UITextField *)textField;
-(void)validateFields:(NSArray *)fields;

-(void)storeUserDataToDefaults:(PFUser *)user;

#pragma mark - PFSignup Protocol

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info;

/// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user;

/// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error;

/// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController;

#pragma mark UINavigationControllerDelegate Protocol
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

#pragma mark LTGrassState Protocol

-(LTGrassState)defaultGrassStateForView;

#pragma mark LTUpdateResult

typedef NS_ENUM(NSInteger, LTUpdateResult) {
    LTUpdateSucceeded, // the case where
    LTUpdateNotNeeded, // the case where no change was necessary
    LTUpdateFailed
};

-(LTUpdateResult)updateFbProfileForUser:(PFUser *)user;

@end
