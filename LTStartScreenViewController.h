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
#import "Facebook.h"
#import <ParseUI/ParseUI.h>

@class  FBSession;

@interface LTStartScreenViewController : UIViewController <MBProgressHUDDelegate, PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate, LTGrassViewControllerDelegate, UITextFieldDelegate, UIWebViewDelegate, FBWebDialogsDelegate>
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
    IBOutlet FBLoginView *facebookLoginButton;
    
    CGPoint originalViewCenter;
    CGPoint currentLogoPosition;
    CGPoint staticLogoPosition;
    
    CGPoint topLogoPosition;
    CGPoint centerLogoPostition;
    
    CGPoint underLogoPosition;
    CGPoint overLogoPosition;
    
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
    UIBarButtonItem *logOutButton;
    
    NSMutableArray *barButtons;
    
    MBProgressHUD *HUD;
    UITextField *currentResponder;
    NSMutableArray *currentTextFields;
    
    CALayer *initialBorderSpecs;
    
    NSArray *readPermissions;
    
    CGRect buriedLogoPosition;
    
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
- (IBAction)logOutButtonTouched:(id)sender;
- (IBAction)goBackButtonTouchHandler:(id)sender;
- (IBAction)clearButtonTouchHandler:(id)sender;

- (void)changeButtonsForSavedUser;

-(void)clearHUD;
- (void)hudWasHidden:(MBProgressHUD *)hud;

-(BOOL)isValidEmail:(NSString *)email;

-(BOOL)validateField:(UITextField *)textField;
-(void)validateFields:(NSArray *)fields;

+(NSString *)syncUserSessionCacheForKey:(NSString *)key;
+(void)clearCachedUsers;
+(BOOL)storeUserDataToDefaults:(PFUser *)user;

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
    LTUpdateFailed,
    LTUpdateResultNil
};

#pragma mark Facebook/buried. user handling methods

-(IBAction)initiateLoginSequence;

-(BOOL)checkForSavedUser; // the first step in the initiateLoginSequence, see if a user is cached or signed in.

-(void)checkUserFBLinkage:(PFUser *)user; // tests if a certain user is linked to fb and continues login sequence

-(void)openFacebookAuthentication; // present the login workflow in a embedded webview and check to see if FB account is already is use

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error; // handler follows the active session and handles the error cases

-(LTUpdateResult)updateFbProfileForUser; // update profile from FB and store in defaults

-(void)loginAttemptedWithSuccess:(BOOL)success withError:(NSError *)error; // result method in either success or failure and notify user

@end

