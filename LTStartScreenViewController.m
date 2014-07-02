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


@implementation LTStartScreenViewController

@synthesize logInVC,signUpVC, userInfo, usernameField, passwordField, confirmField, emailField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
        // Custom initialization
        self->signInButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStyleBordered target:self action:@selector(signInButtonTouchHandler:)];
        self->signUpButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up" style:UIBarButtonItemStyleBordered target:self action:@selector(signUpButtonTouchHandler:)];
        self->continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Continue" style:UIBarButtonItemStyleBordered target:self action:@selector(continueButtonTouchHandler:)];
        self->submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitButtonTouchHandler:)];
        self->cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonTouchHandler:)];
        self->centerLogoPostition = CGRectMake(40,149,240,128);
        self->topLogoPosition = CGRectMake(40,89,240,128);
        self->currentViewElements = [[NSMutableArray alloc] init];
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
    self.navigationItem.leftBarButtonItem = self->signUpButton;
    
    // Add login/sign in navigation bar button;
    self.navigationItem.rightBarButtonItem = self->signInButton;
    
}

-(BOOL)checkForSavedUser
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self->savedDisplayName = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInDisplayName"];
    
    if (![self->savedDisplayName isEqualToString:@""])
    {
        return YES;
    }
    else
        return NO;
}

-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    if ([self checkForSavedUser])
    {
        self->lastLoggedInLabel.text = [NSString stringWithFormat:@"Welcome, %@",self->savedDisplayName];
        self.navigationItem.rightBarButtonItem = self->continueButton;
    } else {
        
        // Add login/sign in navigation bar button
        self.navigationItem.rightBarButtonItem = self->signInButton;
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self->originalViewCenter = self.view.center;
    if (self->currentViewState != self->savedAccountView)
        [self showView:self->startView];
    else
        [self showView:self->savedAccountView];
}

-(void) viewDidDisappear:(BOOL)animated {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    // Add login/sign in navigation bar button
    [self->HUD hide:YES];
}

-(void)changeButtonsForContinuingUser:(NSString *)displayName
{
    if (![self.navigationItem.leftBarButtonItem isEqual:self->signUpButton])
        [self.navigationItem setLeftBarButtonItem:self->signUpButton animated:YES];
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if ([self checkForSavedUser] || [PFUser currentUser])
    {
        if ([PFUser currentUser])
            displayName = [[PFUser currentUser] objectForKey:@"displayName"];
        if (![self->savedDisplayName isEqualToString:displayName])
            self->savedDisplayName = displayName;
            [[NSUserDefaults standardUserDefaults] setObject:displayName forKey:@"lastLoggedInDisplayName"];
            self->lastLoggedInLabel.text = [NSString stringWithFormat:@"Welcome, %@",displayName];
            NSLog(@"lastLoggedInLabel loaded");
            self->notYouButton.enabled = YES;
            NSLog(@"notYouButton loaded and enabled");
            [self.navigationItem setRightBarButtonItem:self->continueButton animated:YES];
    } else {
        if (![PFUser currentUser])
        {
            NSLog(@"no logged in or stored users detected");
        }
        else
             NSLog(@"displayName is invalid for user %@", [[PFUser currentUser] objectId]);
        [self showView:self->startView];
    }
}

#pragma mark - SignUp methods
- (IBAction)submitButtonTouchHandler:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: usernameField.text,@"username",passwordField.text,@"password",emailField.text,@"email", nil];
    NSLog(@"submitting userInfo: %@",userInfo);
    if ([self->signUpView isDescendantOfView:self->currentViewState])
    {
        [self signUpViewController:self.signUpVC shouldBeginSignUp:self.userInfo];
    } else if ([self->loginView isDescendantOfView:self->currentViewState])
    {
        [self logInViewController:logInVC shouldBeginLogInWithUsername:self.userInfo[@"username"] password:self.userInfo[@"password"]];
    }
}

- (IBAction)cancelButtonTouchHandler:(id)sender
{
     NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if ([self->signUpView isDescendantOfView:self->currentViewState])
    {
        [self signUpViewControllerDidCancelSignUp:self.signUpVC];
    } else if ([self->loginView isDescendantOfView:self->currentViewState])
    {
        [self logInViewControllerDidCancelLogIn:self.logInVC];
    }
    
}

- (NSMutableArray *)getTaggedElementsForView:(UIView *)view
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSMutableArray *taggedElements = [[NSMutableArray alloc] initWithArray:[self.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %i",@"tag",view.tag]]];
    
    if ([view isDescendantOfView:self->signUpView] || [view isDescendantOfView:self->loginView])
    {
        [taggedElements addObjectsFromArray:[[NSMutableArray alloc] initWithArray:[self.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %i",@"tag",self->sharedFieldsView.tag]]]];
    }
    return taggedElements;
}

- (void)disableAllBarButtons
{
    
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self->signInButton.enabled = NO;
    self->signUpButton.enabled = NO;
    self->cancelButton.enabled = NO;
    self->continueButton.enabled = NO;
    self->submitButton.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(void)enableAllBarButtons
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self->signInButton.enabled = YES;
    self->signUpButton.enabled = YES;
    self->cancelButton.enabled = YES;
    self->continueButton.enabled = YES;
    self->submitButton.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)showView:(UIView *)view
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    if ([view isDescendantOfView:self->startView] && [self checkForSavedUser])
    {
        view = self->savedAccountView;
    }
    
    NSMutableArray *elementsToShow = [self getTaggedElementsForView:view];
    NSMutableArray *elementsToHide = [self getTaggedElementsForView:self->currentViewState];
    if ([view isDescendantOfView:self->loginView] || [view isDescendantOfView:self->signUpView])
    {
        // make sure no shared elements are hidden
        NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
        for (UIView *element in elementsToHide) {
            if (element.tag == self->sharedFieldsView.tag)
            {
                NSLog(@"removing %@ from self->currentViewElements",element);
                [objectsToRemove addObject:element];
            }
        }
        [elementsToShow removeObjectsInArray:objectsToRemove];
        [elementsToHide removeObjectsInArray:objectsToRemove];
    }
    
    NSLog(@"items to hide: %@",self->currentViewElements);
    if (![self->currentViewState isDescendantOfView:view])
        [self hideViewElements:elementsToHide];
        
    [self disableAllBarButtons];
    
    for (UIView *element in elementsToShow)
        {
            element.alpha = 0;
            element.hidden = NO;
        }
        
        if ([view isDescendantOfView:self->signUpView] || [view isDescendantOfView:self->loginView])
        {
            NSLog(@"showing signup animation finished");
            [self.navigationItem setLeftBarButtonItem:self->cancelButton animated:YES];
            [self.navigationItem setRightBarButtonItem:self->submitButton animated:YES];
        } else if ([view isDescendantOfView:self->savedAccountView])
            [self changeButtonsForContinuingUser:self->savedDisplayName];
        else if ([view isDescendantOfView:self->startView])
        {
            [self.navigationItem setLeftBarButtonItem:self->signUpButton animated:YES];
            [self.navigationItem setRightBarButtonItem:self->signInButton animated:YES];
        }
    
    [UIView animateWithDuration:0.75 animations:^{
        for (UIView *element in elementsToShow) {
            element.alpha = 1;
        }
        if ([view isDescendantOfView:self->savedAccountView])
        {
            self->buriedLogo.frame = self->centerLogoPostition;
        } else if ([view isDescendantOfView:self->startView])
        {
            self->buriedLogo.center = self.view.center;
        } else if ([view isDescendantOfView:signUpView] || [view isDescendantOfView:loginView])
        {
            self->buriedLogo.frame = self->topLogoPosition;
        }
    } completion:^(BOOL finished) {
        NSLog(@"new view shown");
        self->currentViewState = view;
        self->currentViewElements = [self getTaggedElementsForView:self->currentViewState];
        self->currentTextFields = [NSMutableArray arrayWithArray:[self->currentViewElements sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            UIView *object = (UIView *)obj1;
            UIView *otherObject = (UIView *)obj2;
            NSNumber *theY = [[NSNumber alloc] initWithInt:object.center.y];
            NSNumber *theOtherY = [[NSNumber alloc] initWithInt:otherObject.center.y];
            return [theY compare:theOtherY];
        }]];
        NSLog(@"currentTextFields :%@",self->currentTextFields);
        [self->currentTextFields filterUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@",[UITextField class]]];
        NSLog(@"currentTextFields :%@",self->currentTextFields);
        [self enableAllBarButtons];
    }];
}

- (void)hideViewElements:(NSMutableArray *)viewElements
{
    
        NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (viewElements.count > 0)
        [self disableAllBarButtons];
        
        [UIView animateWithDuration:0.7 animations:^{
        for (UIView *element in viewElements) {
            element.alpha = 0;
        }
        } completion:^(BOOL finished) {
        NSLog(@"finished hiding");
        if (finished)
        {
            for (UIView *element in viewElements) {
                element.hidden = YES;
            }
        }
    }];
    }

- (IBAction)signUpButtonTouchHandler:(id)sender  {
     NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (!self.signUpVC)
    {
    self.signUpVC = [[PFSignUpViewController alloc] init];
    self.signUpVC.delegate = self;
    }
    [self showView:self->signUpView];
}

#pragma mark - SignIn methods
- (IBAction)signInButtonTouchHandler:(id)sender  {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (!self.logInVC)
    {
        self.logInVC = [[PFLogInViewController alloc] init];
        self.logInVC.delegate = self;
    }
    [self showView:self->loginView];
}

#pragma mark - Continue mehtods
/* Login to facebook method */
- (IBAction)continueButtonTouchHandler:(id)sender  {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    /* TODO implement PIN VC
     [self presentViewController:[[LTPINVerificationViewController alloc] init] animated:YES completion:^{
        NSLog(@"PinVC presented successfully");
    }];
     */
    [self continueToUnearthedWithFbLoginPermissionsAfterPINVerificationBy:sender];
}

- (void)continueToUnearthedWithFbLoginPermissionsAfterPINVerificationBy:
    (id)sender
{
    
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
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
                    
                    [self storeUserDataToDefaults:user];
                    
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

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSUInteger isNotLast = [[self->currentTextFields lastObject] indexGreaterThanIndex:[self->currentTextFields indexOfObject:self->currentResponder]];
    if (isNotLast != NSNotFound)
        textField.returnKeyType = UIReturnKeyNext;
    else
        textField.returnKeyType = UIDocumentChangeDone;
    self->currentResponder = textField;
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSLog(@"originalCenter: (%f, %f), self.view.center: (%f, %f)", self->originalViewCenter.x, self->originalViewCenter.y,textField.center.x,textField.center.y);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.view.center = CGPointMake(self.view.center.x, textField.center.y);
    } completion:^(BOOL finished) {
        NSLog(@"originalCenter: (%f, %f), self.view.center: (%f, %f)", self->originalViewCenter.x, self->originalViewCenter.y,textField.center.x,textField.center.y);
    }];
    [self.view addGestureRecognizer:[[UIGestureRecognizer alloc] initWithTarget:self->currentResponder action:@selector(endEditing:)]];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self->currentResponder.center.y == self.view.center.y)
    {
        return YES;
    } else
        return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSUInteger isNotLast = [[self->currentTextFields lastObject] indexGreaterThanIndex:[self->currentTextFields indexOfObject:self->currentResponder]];
    if (isNotLast == NSNotFound)
    {
        NSLog(@"last object detected");
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.center = self->originalViewCenter;
        } completion:^(BOOL finished) {
        if (finished)
            NSLog(@"keyboard hiding animation done");
    }];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField.returnKeyType == UIReturnKeyNext)
    {
    UITextField *nextUp = [self->currentTextFields objectAtIndex:([self->currentTextFields indexOfObject:self->currentResponder] + 1)];
        NSLog(@"nextUp:%@",nextUp);
        [nextUp becomeFirstResponder];
    }
    
    return NO;
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
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"lastLoggedInDisplayName"];
    
    NSLog(@"NSUserDefaults cleared for lastLoggedInUserId & displayName");
    
    [self showView:self->startView];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSLog(@"info: %@",info);
    return YES;
}

-(void)storeUserDataToDefaults:(PFUser*)user
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSString *lastLoggedInUserId = nil;
    NSString *lastLoggedInFacebookId = nil;
    NSString *lastLoggedInDisplayName = nil;
    NSString *lastLoggedInUserName = nil;
    
    //write to user defaults and update buttons
    if ([PFFacebookUtils isLinkedWithUser:user])
    {
        NSLog(@"fb account detected, id: %@", [user objectForKey:@"facebookId"]);
        
        lastLoggedInUserId = [user objectId];
        lastLoggedInFacebookId = [user objectForKey:@"facebookId"];
        lastLoggedInDisplayName = [user objectForKey:@"displayName"];
        lastLoggedInUserName = [user username];
        
    } else {
        
        //write to user defaults and update buttons
        
        lastLoggedInUserId = [user objectId];
        lastLoggedInFacebookId = @"";
        lastLoggedInDisplayName = @"";
        lastLoggedInUserName = [user username];
    }
    // write to user defaults
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInUserId forKey:@"lastLoggedInUserId"];
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInFacebookId forKey:@"lastLoggedInFacebookId"];
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInDisplayName forKey:@"lastLoggedInDisplayName"];
    self->savedDisplayName = lastLoggedInDisplayName;
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInUserName forKey:@"lastLoggedInUserName"];
    
    NSLog(@"written to NSUserDefaults for offline/immediate access: lastLoggedInUserId/%@ displayName/%@ userName/%@ lastLoggedInFacebookId/%@",lastLoggedInUserId,lastLoggedInDisplayName,lastLoggedInUserName,lastLoggedInFacebookId);
}

/// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [signUpController dismissViewControllerAnimated:YES completion:^{
        NSLog(@"signUpViewController dismissed with successful login, current user: %@",[PFUser currentUser]);
        [self storeUserDataToDefaults:user];
        [self showView:startView];
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
    [self showView:startView];
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
        [self storeUserDataToDefaults:user];
        [self showView:startView];
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
    [self showView:self->startView];
    
}

- (void)updateFbProfileForUser:(PFUser *)user
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
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
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    return LTGrassStateGrown;
}

@end
