//
//  LTStartScreenViewController.m
//  buried
//
//  Created by Patrick Blaine on 6/8/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//


#import "LTUnearthedViewController.h"
#import <Parse/Parse.h>
#import "LTAppDelegate.h"
#import "LTStartScreenViewController.h"
#import "LTPINVerificationViewController.h"

@interface LTStartScreenViewController ()

@end

@implementation LTStartScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [super viewDidLoad];
    self.title = @"";
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self.navigationController pushViewController:[[LTUnearthedViewController alloc] initWithStyle:UITableViewStylePlain] animated:NO];
    }
    
    // Add signup navigation bar button
    UIBarButtonItem *signUpButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up" style:UIBarButtonItemStyleBordered target:self action:@selector(signUpButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = signUpButton;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    // Add login/sign in navigation bar button
    UIBarButtonItem *signInButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStyleBordered target:self action:@selector(signInButtonTouchHandler:)];
    self.navigationItem.rightBarButtonItem = signInButton;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self->lastLoggedInLabel.text = @"";
    self->lastLoggedInLabel.alpha = 0;
    self->notYouButton.alpha = 0;
    self->notYouButton.enabled = NO;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInUserId"] length] > 0)
    {
        UIBarButtonItem *continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Continue" style:UIBarButtonItemStyleBordered target:self action:@selector(continueButtonTouchHandler:)];
        self.navigationItem.rightBarButtonItem = continueButton;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        
        // Add login/sign in navigation bar button
        UIBarButtonItem *signInButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStyleBordered target:self action:@selector(signInButtonTouchHandler:)];
        self.navigationItem.rightBarButtonItem = signInButton;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self.navigationItem.rightBarButtonItem.enabled = true;
    
    // if connection is successful, welcome last logged in user and update label
            NSString *lastLoggedInUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInUserId"];
            if (lastLoggedInUserId.length > 0)
            {
                NSString *displayName = [[NSUserDefaults standardUserDefaults] objectForKey:@"displayName"];
                
                NSLog(@"display name of last logged in user is %@",displayName);
                // ensure the user has a display name set before attempting to preset
                
                [self changeButtonsForContinuingUser:displayName];
                
            }
    
}

-(void) viewDidDisappear:(BOOL)animated {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    // Add login/sign in navigation bar button
    [self->HUD hide:YES];
}

-(void)changeButtonsForContinuingUser:(NSString *)displayName
{
    if (displayName.length > 0)
    {
    self->lastLoggedInLabel.text = [NSString stringWithFormat:@"Welcome, %@",displayName];
    [UIView animateWithDuration:1.0f animations:^{
        self->lastLoggedInLabel.alpha = 1;
        self->notYouButton.alpha = 1;
        if (![self.navigationItem.rightBarButtonItem.title isEqualToString:@"Continue"])
        {
        self.navigationItem.rightBarButtonItem.title = @"Continue";
        self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    } completion:^(BOOL finished) {
        if (finished)
        {
            UIBarButtonItem *continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Continue" style:UIBarButtonItemStyleBordered target:self action:@selector(continueButtonTouchHandler:)];
            self.navigationItem.rightBarButtonItem = continueButton;
            self.navigationItem.rightBarButtonItem.enabled = YES;
            NSLog(@"lastLoggedInLabel loaded");
            self->notYouButton.enabled = YES;
            NSLog(@"notYouButton loaded and enabled");
        }
        }];
    } else {
        if (![PFUser currentUser])
            NSLog(@"no logged in or stored users detected");
        else
             NSLog(@"displayName is invalid for user %@", [[PFUser currentUser] objectId]);
    }
}

#pragma mark - SignUp methods
- (IBAction)signUpButtonTouchHandler:(id)sender  {
     NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    PFSignUpViewController *signUpVC = [[PFSignUpViewController alloc] init];
    signUpVC.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsEmail | PFSignUpFieldsSignUpButton | PFSignUpFieldsDismissButton;
    signUpVC.delegate = self;
    [self presentViewController:signUpVC animated:YES completion:^{
        NSLog(@"presenting signUpVC");
    }];
}

#pragma mark - SignIn methods
- (IBAction)signInButtonTouchHandler:(id)sender  {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    PFLogInViewController *signInVC = [[PFLogInViewController alloc] init];
    signInVC.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsFacebook | PFLogInFieldsDismissButton;
    signInVC.delegate = self;
    [self presentViewController:signInVC animated:YES completion:^{
        NSLog(@"presenting signInVC");
    }];
}

#pragma mark - Continue mehtods
/* Login to facebook method */
- (IBAction)continueButtonTouchHandler:(id)sender  {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    /* TODO implement PIN VC
     [self presentViewController:[[LTPINVerificationViewController alloc] init] animated:YES completion:^{
        NSLog(@"PinVC presented successfully");
    }];
     */ [self continueToUnearthedWithFbLoginPermissionsAfterPINVerificationBy:sender];
}

- (void)continueToUnearthedWithFbLoginPermissionsAfterPINVerificationBy:
    (id)sender
{
    NSLog(@"logging in");
    //[(UIBarButtonItem*)sender setEnabled:NO];
    
    self->HUD = [[MBProgressHUD alloc] initWithView:[[[UIApplication sharedApplication] windows] firstObject]];
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:HUD];
    
    // Set indeterminate mode
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.delegate = self;
    [HUD show:YES];
    
    // The permissions requested from the user
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            
            self->HUD.mode = MBProgressHUDModeCustomView;
            self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
            [self->HUD hide:YES afterDelay:1.0f];
            
            if (!error) {
                NSLog(@"uh oh. The user outright cancelled the Facebook login.");
                self.navigationItem.rightBarButtonItem.enabled = YES;
            } else {
                NSLog(@"uh oh. An error occurred: %@", error);
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
        } else {
            // Send request to Facebook
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                // handle response
                if (!error) {
                    
                    // Parse the data received
                    NSDictionary<FBGraphUser> *userData = (NSDictionary<FBGraphUser> *)result;
                    NSDictionary<FBGraphUser> *storedData = (NSDictionary<FBGraphUser> *)[user objectForKey:@"profile"];
                    
                    if (![storedData[@"updated_time"] isEqualToString:userData[@"updated_time"]])
                    {
                        
                        [[PFUser currentUser] setObject:userData forKey:@"profile"];
                        
                        // update facebook username, email, facebook profile, display name, facebook id and download profile pictures
                        
                        [[PFUser currentUser] setObject:userData[@"name"] forKey:@"displayName"];
                        [[PFUser currentUser] setObject:userData[@"username"] forKey:@"facebookUsername"];
                        [[PFUser currentUser] setObject:userData[@"id"] forKey:@"facebookId"];
                        
                        NSLog(@"updating profile and saving to parse");
                        
                        [[PFUser currentUser] saveEventually:^(BOOL succeeded, NSError *error) {
                            if (succeeded)
                            NSLog(@"new user profile successfully saved to parse");
                            else
                            NSLog(@"profile updating failed with error: %@",error);
                        }];
                    } else {
                        NSLog(@"profile is up to date");
                    }
                    
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    // Update installation with current user info, create a channel for push directly to user by id, save the information to a Parse installation.
                    
                    // double check global is registered
                    [currentInstallation addUniqueObject:@"global" forKey:@"channels"];
                    
                    // Register for user specific channels
                    PFUser *currentUser = [PFUser currentUser];
                    
                    /* if there are existing channels overwrite them
                     if (currentInstallation.channels.count > 1)
                     currentInstallation.channels = @[@"global"];*/
                    
                    [currentInstallation addUniqueObject:[currentUser objectId] forKey:@"channels"];
                    
                    PFUser *pointerToUser = [PFUser user];
                    pointerToUser.objectId = currentUser.objectId;
                    
                    [currentInstallation setObject:pointerToUser forKey:@"user"];
                    
                    [currentInstallation saveInBackground];
                    
                    NSLog(@"current channels: %@", [currentInstallation channels]);
                    
                    // write to user defaults
                    NSString *lastLoggedInUserId = [user objectId];
                    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInUserId forKey:@"lastLoggedInUserId"];
                    
                    NSString *lastLoggedInFacebookId = [userData objectForKey:@"id"];
                    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInFacebookId forKey:@"lastLoggedInFacebookId"];
                    
                    NSString *lastLoggedInDisplayName = [user objectForKey:@"displayName"];
                    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInDisplayName forKey:@"lastLoggedInDisplayName"];
                    
                    NSString *lastLoggedInUserName = [user username];
                    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInUserName forKey:@"lastLoggedInUserName"];
                    
                    NSLog(@"written to NSUserDefaults for offline/immediate access: lastLoggedInUserId/%@ displayName/%@ userName/%@ lastLoggedInFacebookId/%@",lastLoggedInUserId,lastLoggedInDisplayName,lastLoggedInUserName,lastLoggedInFacebookId);
                    
                    self->HUD.mode = MBProgressHUDModeCustomView;
                    self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                    [self.navigationController pushViewController:[[LTUnearthedViewController alloc] initWithStyle:UITableViewStylePlain] animated:YES];
                    
                } else {
                    
                    NSLog(@"cannot reach parse servers, profile not updated: , %@", error);
                    if (user.isNew)
                    {
                        self->HUD.mode = MBProgressHUDModeText;
                        self->HUD.labelText = @"initial setup failed";
                        self->HUD.detailsLabelText = @"try again, please";
                        [self->HUD hide:YES afterDelay:1.0f];
                    } else {
                        NSLog(@"warning: profile may or may not be out of date");
                        self->HUD.mode = MBProgressHUDModeCustomView;
                        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                        [self.navigationController pushViewController:[[LTUnearthedViewController alloc] initWithStyle:UITableViewStylePlain] animated:YES];
                    }
                }
            }];
        }
    }];

}

- (IBAction)notYouButtonTouched:(id)sender
{
    // as of this moment ass this button does is to clear the stored userId for the last logged in user to remove the greeting, however, with the new account management branch, this will play an integral role in switching accounts and allowing the user to authenticate again as someone else
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:@"" forKey:@"lastLoggedInUserId"];
    [currentInstallation saveEventually:^(BOOL succeeded, NSError *error) {
        NSLog(@"currently stored last logged in user: %@",[currentInstallation objectForKey:@"lastLoggedInUserId"]);
        if (succeeded)
            NSLog(@"lastLoggedInUserId cleared successfully and sync'd with parse");
        else
            NSLog(@"unabled to save the clearing of the last login to parse, please contact the team.");
    }];
    
    // clear stored account in user defaults
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"lastLoggedInUserId"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"displayName"];
    
    NSLog(@"NSUserDefaults cleared for lastLoggedInUserId & displayName");
    
    self->notYouButton.enabled = NO;
    [UIView animateWithDuration:0.3f animations:^{
        self->lastLoggedInLabel.alpha = 0;
        self->notYouButton.alpha = 0;
        self.navigationItem.rightBarButtonItem.title = @"Sign In";
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } completion:^(BOOL finished) {
        if (finished)
            NSLog(@"notYouButton and lastLoggedInLabel hidden");
        UIBarButtonItem *signInButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStyleBordered target:self action:@selector(signInButtonTouchHandler:)];
        self.navigationItem.rightBarButtonItem = signInButton;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSLog(@"Sign In button restored");
    }];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    return YES;
}

/// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [signUpController dismissViewControllerAnimated:YES completion:^{
        NSLog(@"signUpViewController dismissed with successful login, current user: %@",[PFUser currentUser]);
        /* TODO handle signup vc successful completion
        if (user) {
        
        //write to user defaults and update buttons
            [self changeButtonsForContinuingUser:[user username]];
        }
        
        // save working login data and pass it to PIN controller to be saved on submission
        LTPINVerificationViewController *pinVC = [[LTPINVerificationViewController alloc] init];
        [self presentViewController:pinVC animated:YES completion:^{
            NSLog(@"pinVC succesfully presented");
        }];*/
    }];
}

/// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

/// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

/*
 Sent to the delegate to determine whether the log in request should be submitted to the server.
@param username the username the user tries to log in with.
@param password the password the user tries to log in with.
@result a boolean indicating whether the log in should proceed.
*/
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
     NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    return YES;
}

/*! @name Responding to Actions */
/// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
     NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [logInController dismissViewControllerAnimated:YES completion:^{
        NSLog(@"loginviewController dismissed with successful login, current user: %@",[PFUser currentUser]);
        
        NSString *lastLoggedInUserId = nil;
        NSString *lastLoggedInFacebookId = nil;
        NSString *lastLoggedInDisplayName = nil;
        NSString *lastLoggedInUserName = nil;
        
        //write to user defaults and update buttons
        if ([PFFacebookUtils isLinkedWithUser:user])
        {
            NSLog(@"fb account detected, id: %@", [user objectForKey:@"facebookId"]);
            
            [self changeButtonsForContinuingUser:[user objectForKey:@"displayName"]];
        
        lastLoggedInUserId = [user objectId];
        lastLoggedInFacebookId = [user objectForKey:@"facebookId"];
        lastLoggedInDisplayName = [user objectForKey:@"displayName"];
        lastLoggedInUserName = [user username];
            
            [self continueButtonTouchHandler:self];
            
    } else {
        
        //write to user defaults and update buttons
        [self changeButtonsForContinuingUser:[user username]];
        
        lastLoggedInUserId = [user objectId];
        lastLoggedInFacebookId = @"";
        lastLoggedInDisplayName = @"";
        lastLoggedInUserName = [user username];
    }
        /* TODO save working login data and pass it to PIN controller to be saved on submission
        LTPINVerificationViewController *pinVC = [[LTPINVerificationViewController alloc] init];
        [self presentViewController:pinVC animated:YES completion:^{
            NSLog(@"pinVC succesfully presented");
        }];*/
    }];
}

/// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
     NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

/// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
     NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
}

- (void)updateFbProfileForUser:(PFUser *)user
{
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            
            // Parse the data received
            NSDictionary<FBGraphUser> *userData = (NSDictionary<FBGraphUser> *)result;
             NSDictionary<FBGraphUser> *storedData = (NSDictionary<FBGraphUser> *)[user objectForKey:@"profile"];
            
                if (![userData[@"updated_time"] isEqualToString:storedData[@"updated_time"]])
                {
                    
                    [[PFUser currentUser] setObject:userData forKey:@"profile"];
                    
                    // update facebook username, email, facebook profile, display name, facebook id and download profile pictures
                    
                    [[PFUser currentUser] setObject:userData[@"name"] forKey:@"displayName"];
                    [[PFUser currentUser] setObject:userData[@"username"] forKey:@"facebookUsername"];
                    [[PFUser currentUser] setObject:userData[@"id"] forKey:@"facebookId"];
                    
                    [[PFUser currentUser] saveEventually:^(BOOL succeeded, NSError *error) {
                        if (succeeded)
                            NSLog(@"new user profile successfully saved to parse");
                        else
                            NSLog(@"profile updating failed with error: %@",error);
                    }];
                } else {
                    NSLog(@"profile is up to date, no change");
                }
        } else {
            NSLog(@"unable to update profile");
        }
    }];
}

-(LTGrassState)defaultGrassStateForView
{
    return LTGrassStateGrown;
}

@end
