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

@interface LTStartScreenViewController()

-(void)hide:(BOOL)shouldHide afterDelay:(NSTimeInterval)afterDelay withCompletionBlock:(dispatch_block_t)completionBlock;

@end

@implementation LTStartScreenViewController

@synthesize logInVC,signUpVC, userInfo, passwordField, confirmField, emailField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
        // Custom initialization
        self->signInButton = [[UIBarButtonItem alloc] initWithTitle:@"log in" style:UIBarButtonItemStyleBordered target:self action:@selector(signInButtonTouchHandler:)];
        self->signUpButton = [[UIBarButtonItem alloc] initWithTitle:@"sign up" style:UIBarButtonItemStyleBordered target:self action:@selector(signUpButtonTouchHandler:)];
        self->continueButton = [[UIBarButtonItem alloc] initWithTitle:@"continue" style:UIBarButtonItemStyleBordered target:self action:@selector(initiateLoginSequence)];
        self->submitButton = [[UIBarButtonItem alloc] initWithTitle:@"submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitButtonTouchHandler:)];
        self->goBackButton = [[UIBarButtonItem alloc] initWithTitle:@"go back" style:UIBarButtonItemStyleBordered target:self action:@selector(goBackButtonTouchHandler:)];
        self->notYouButton = [[UIBarButtonItem alloc] initWithTitle:@"not you?" style:UIBarButtonItemStyleBordered target:self action:@selector(notYouButtonTouched:)];
        self->clearButton = [[UIBarButtonItem alloc] initWithTitle:@"clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearButtonTouchHandler:)];
        self->barButtons = [[NSMutableSet alloc] initWithObjects:self->signInButton,self->signUpButton,self->submitButton,self->goBackButton,self->notYouButton,self->clearButton, nil];
        self->centerLogoPostition = CGRectMake(40,149,240,128);
        self->topLogoPosition = CGRectMake(40,74,240,128);
        self->currentViewElements = [[NSMutableArray alloc] init];
        self->readPermissions = [NSArray arrayWithObjects:@"public_profile", @"email",@"user_friends",nil];    }
    return self;
}

- (void)viewDidLoad {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [super viewDidLoad];
    self.title = nil;
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self.navigationController pushViewController:[[LTUnearthedViewController alloc] initWithStyle:UITableViewStylePlain] animated:NO];
    }
    
    // Add signup navigation bar button
    self.navigationItem.leftBarButtonItem = self->signUpButton;
    
    // Add login/sign in navigation bar button;
    self.navigationItem.rightBarButtonItem = self->signInButton;
    
    self->initialBorderSpecs.borderColor = [[UIColor clearColor] CGColor];
    self->initialBorderSpecs.shadowColor = [[UIColor clearColor] CGColor];
    self->initialBorderSpecs.borderWidth = 1;
    self->initialBorderSpecs.cornerRadius = 8;
    self->initialBorderSpecs.masksToBounds = YES;
    
    for (UITextField *textField in [self.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@",@"class",[UITextField class]]]) {
        UIImageView *leftImageView;
        if ([textField.accessibilityLabel isEqualToString:@"email"])
        {
            leftImageView = [[UIImageView  alloc]  initWithImage:
                             [UIImage  imageNamed: @"iconmonstr-user-3-icon-40.png"]];
        } else if ([textField.accessibilityLabel isEqualToString:@"password"]) {
            leftImageView = [[UIImageView  alloc]  initWithImage:
                             [UIImage  imageNamed: @"iconmonstr-key-8-icon-48.png"]];
        } else {
            leftImageView = [[UIImageView  alloc]  initWithImage:
                             [UIImage  imageNamed: @"iconmonstr-key-7-icon-48.png"]];
        }
        [textField setTextAlignment:NSTextAlignmentCenter];
        
        textField.layer.backgroundColor = [[UIColor clearColor] CGColor];
        textField.layer.cornerRadius = 8;
        textField.layer.masksToBounds = NO;
        [textField  setLeftView:leftImageView];
        leftImageView.layer.cornerRadius = 8;
        leftImageView.layer.backgroundColor = [[UIColor colorWithRed:((float)127 / 255.0f) green:((float)140 / 255.0f) blue:((float)141 / 255.0f) alpha:0.0] CGColor];
        leftImageView.alpha = 0.5;
        [textField  setLeftViewMode: UITextFieldViewModeAlways];
    }
}


-(BOOL)isValidEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailPredicate evaluateWithObject:email];
}

-(BOOL)checkForSavedUser
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSString *userId = nil;
    NSString *sessionToken = nil;
    
    userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInUserId"];
    sessionToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInSessionToken"];
    
    if ((!userId) || (!sessionToken))
    {
        return NO;
    }
    else
    {
        
        NSLog(@"user found with id %@ & name %@ & fbid %@ & username %@ & sessionToken %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInUserId"],[[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInUserName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInDisplayName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInFacebookId"], [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInSessionToken"]);
        return YES;
    }
}


-(void)initializeHUD
{
    // we like our HUDs over everything so grab the top window and place the HUD there
    UIWindow *thePrimaryWindow = [[[UIApplication sharedApplication] windows] firstObject];
    
    // check to see if the HUD has ever been initialized, if it has just make sure its in front
    if (!self->HUD)
    {
        self->HUD = [[MBProgressHUD alloc] initWithView:[[[UIApplication sharedApplication] windows] firstObject]];
        [thePrimaryWindow addSubview:HUD];
        self->HUD.delegate = self;
    } else {
        [thePrimaryWindow bringSubviewToFront:self->HUD];
    }
}

-(void)clearHUD
{
    self->HUD.detailsLabelText = nil;
    self->HUD.labelText = nil;
    self->HUD.customView = nil;
    self->HUD.mode = MBProgressHUDModeIndeterminate;
}


-(void)checkUserFBLinkage:(PFUser *)user
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self->HUD.labelText = @"linking to facebook";
    if (![PFFacebookUtils isLinkedWithUser:user])
    {
        NSLog(@"PFFacebookUtils not linked with logged in user, attempting to link");
        [self openFacebookAuthentication];
    } else {
        NSLog(@"PFFacebookUtils linked with logged in user, login success");
        [self loginAttemptedWithBool:YES withError:nil];
    }
}

-(void)initiateLoginSequence {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self->HUD setLabelText:@"logging in"];
    [self->HUD show:YES];
    
    PFUser *currentUser = [PFUser currentUser];
    
    [self disableAllBarButtons];
    
    if (!currentUser)
    {
        NSLog(@"no current user, checking for saved user");
        if (![self checkForSavedUser]) {
            NSLog(@"no saved user found, login failed");
            [self loginAttemptedWithBool:NO withError:[NSError errorWithDomain:FacebookSDKDomain code:FBErrorLoginFailedOrCancelled userInfo:@{@"error":@"no saved or logged in user"}]];
        } else {
            NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInSessionToken"];
            [PFUser becomeInBackground:token block:^(PFUser *user, NSError *error) {
                if (user)
                {
                    if (error)
                    {
                        NSLog(@"could not become user with token %@, login failed",token);
                        [self loginAttemptedWithBool:NO withError:error];
                    } else {
                        NSLog(@"became user %@ with token %@, checking linkage",user.objectId,token);
                        [self checkUserFBLinkage:user];
                    }
                }
                else
                {
                    NSLog(@"could not become user, login failed");
                    [self loginAttemptedWithBool:NO withError:error];
                }
            }];
        }
    } else {
        NSLog(@"currentUser %@ found, checking linkage",currentUser.objectId);
        [self checkUserFBLinkage:currentUser];
    }
}


-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    if ([self checkForSavedUser] || [PFUser currentUser])
    {
        NSString *displayName = [[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInDisplayName"]] lowercaseString];
        displayName = [[PFUser currentUser] objectForKey:@"firstName"];
        self->lastLoggedInLabel.text = displayName;
        self.navigationItem.rightBarButtonItem = self->continueButton;
    } else {
        
        // Add login/sign in navigation bar button
        self.navigationItem.rightBarButtonItem = self->signInButton;
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    [self initializeHUD];
    
    [self showView:self->startView];
}

-(void) viewDidDisappear:(BOOL)animated {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    // Add login/sign in navigation bar button
    
    [self->HUD hide:YES];
    
    [self->currentViewElements arrayByAddingObjectsFromArray:self.view.subviews];
    [self->currentViewElements removeObject:self->buriedLogo];
    
    [self hideViewElements:self->currentViewElements];
    
    self->currentViewState = nil;
}

-(void)changeButtonsForSavedUser
{
    if (![self.navigationItem.leftBarButtonItem isEqual:self->signUpButton])
        [self.navigationItem setLeftBarButtonItem:self->signUpButton animated:YES];
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if ([self checkForSavedUser] || [PFUser currentUser])
    {
        NSString * displayName = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInDisplayName"];
        if ([PFUser currentUser])
        {
            displayName = [[PFUser currentUser] objectForKey:@"firstName"];
        }
        self->lastLoggedInLabel.text = [NSString stringWithFormat:@"welcome back, %@!",[displayName lowercaseString]];
        
        NSLog(@"lastLoggedInLabel loaded");
        NSLog(@"navBar elements loaded and enabled");
        
        [self.navigationItem setRightBarButtonItem:self->continueButton animated:YES];
        [self.navigationItem setLeftBarButtonItem:self->notYouButton animated:YES];
    } else {
        if (![PFUser currentUser])
        {
            NSLog(@"no logged in or stored users detected");
        }
        else
        {
            NSLog(@"displayName is invalid for user %@", [[PFUser currentUser] objectId]);
        }
    }
}

#pragma mark - SignUpView methods
- (IBAction)submitButtonTouchHandler:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    [self validateFields:self->currentTextFields];
    
    if ([self->currentResponder isFirstResponder])
    {
        [self->currentResponder resignFirstResponder];
        [self returnViewToOrigin];
    }
    
    [self disableAllBarButtons];
    
    // start the hud
    self->HUD.mode = MBProgressHUDModeIndeterminate;
    self->HUD.labelText = @"submitting";
    [self->HUD show:YES];
    
    self.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.emailField.text,@"username",self.passwordField.text,@"password",self.emailField.text,@"email", nil];
    NSLog(@"submitting userInfo: %@",self.userInfo);
    
    if ([self->signUpView isDescendantOfView:self->currentViewState])
    {
        if ([self signUpViewController:self.signUpVC shouldBeginSignUp:self.userInfo])
        {
            self->HUD.labelText = @"signing up";
            NSLog(@"signup fields are good to go");
            
            PFUser *userToSignup = [[PFUser alloc] init];
            
            [userToSignup setEmail:self.userInfo[@"email"]];
            [userToSignup setUsername:self.userInfo[@"email"]];
            [userToSignup setPassword:self.userInfo[@"password"]];
            [userToSignup setObject:self.userInfo[@"username"] forKey:@"displayName"];
            [userToSignup setObject:self.userInfo[@"username"] forKey:@"firstName"];
            
            [userToSignup signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    [self signUpViewController:self.signUpVC didSignUpUser:userToSignup];
                } else
                {
                    [self signUpViewController:self.signUpVC didFailToSignUpWithError:error];
                }
            }];
        } else {
            NSLog(@"signup fields had errors");
        }
    } else if ([self->loginView isDescendantOfView:self->currentViewState])
    {
        if ([self logInViewController:self.logInVC shouldBeginLogInWithUsername:self.userInfo[@"username"] password:self.userInfo[@"password"]])
        {
            [PFUser logInWithUsernameInBackground:self.userInfo[@"username"] password:self.userInfo[@"password"] block:^(PFUser *user, NSError *error) {
                if (!error)
                {
                    [self logInViewController:self.logInVC didLogInUser:user];
                } else
                {
                    [self logInViewController:self.logInVC didFailToLogInWithError:error];
                }
            }];
        }
    }
}

- (IBAction)goBackButtonTouchHandler:(id)sender
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

- (IBAction)clearButtonTouchHandler:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self->currentResponder setText:nil];
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
    for (UIBarButtonItem *item in self->barButtons) {
        item.enabled = NO;
    }
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(void)enableAllBarButtons
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    for (UIBarButtonItem *item in self->barButtons) {
        item.enabled = YES;
    }
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)showView:(UIView *)view
{
    
    [self clearHUD];
    
    [self disableAllBarButtons];
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    // only bounce in significantly if coming from off screen
    float damping = 0.8;
    float velocity = 0.5;
    float duration = 1;
    if (self->buriedLogo.center.y > 568)
    {
        NSLog(@"buried logo coming in from off screen!");
        damping = 0.6;
        duration = 2;
        velocity = 0.4;
    }
    // set up logo animation in block above
    
    if ([view isDescendantOfView:self->startView] && ([self checkForSavedUser] || [PFUser currentUser]))
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
    if (![self->currentViewState isDescendantOfView:view] && self->currentViewState)
        [self hideViewElements:elementsToHide];
    
    for (UIView *element in elementsToShow)
    {
        element.alpha = 0;
        element.hidden = NO;
    }
    
    if ([view isDescendantOfView:self->signUpView] || [view isDescendantOfView:self->loginView])
    {
        NSLog(@"showing signup animation finished");
        [self.navigationItem setLeftBarButtonItem:self->goBackButton animated:YES];
        [self.navigationItem setRightBarButtonItem:self->submitButton animated:YES];
        [passwordField setSecureTextEntry:([view isDescendantOfView:self->loginView])];
        
    } else if ([view isDescendantOfView:self->savedAccountView])
    {
        self->HUD.detailsLabelText = nil;
        self->HUD.labelText = nil;
        self->HUD.customView = nil;
        [self changeButtonsForSavedUser];
    }
    else if ([view isDescendantOfView:self->startView])
    {
        [self.navigationItem setLeftBarButtonItem:self->signUpButton animated:YES];
        [self.navigationItem setRightBarButtonItem:self->signInButton animated:YES];
    }
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionCurveEaseOut animations:^{
        if ([view isDescendantOfView:self->savedAccountView])
        {
            self->buriedLogo.frame = self->centerLogoPostition;
        } else if ([view isDescendantOfView:self->startView])
        {
            self->buriedLogo.center = self.view.center;
        } else if ([view isDescendantOfView:signUpView] || [view isDescendantOfView:self->loginView])
        {
            self->buriedLogo.frame = self->topLogoPosition;
        }
    } completion:^(BOOL finished) {
        NSLog(@"logo bounced in");
    }];
    
    [UIView animateKeyframesWithDuration:1.0 delay:0.3 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView  addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{for (UIView *element in elementsToShow) {
            element.alpha = 1;
        }
        }];
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
        
        NSLog(@"currentViewElements :%@",self->currentViewElements);
        [self->currentTextFields filterUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@",@"class",[UITextField class]]];
        self->originalViewCenter = CGPointMake(self.view.center.x, self.view.center.y);
        NSLog(@"currentTextFields :%@",self->currentTextFields);
        
        [self enableAllBarButtons];
        
    }];
}

- (void)hideViewElements:(NSMutableArray *)viewElements
{
    if (self.navigationItem.rightBarButtonItem.isEnabled)
        [self disableAllBarButtons];
    
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    [UIView animateWithDuration:0.5 animations:^{
        for (UIView *element in viewElements) {
            element.alpha = 0;
            if ([element isMemberOfClass:[UITextField class]])
            {
                [(UITextField *)[element self] setText:nil];
                ((UITextField *)[element self]).textColor = [UIColor darkTextColor];
            }
        }
    } completion:^(BOOL finished) {
        NSLog(@"finished hiding animation");
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
    [self.passwordField setSecureTextEntry:NO];
    [self.confirmField setSecureTextEntry:NO];
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

- (void)checkForLinkedUser:(PFUser *)user
{
        if (![PFFacebookUtils isLinkedWithUser:user])
        {
            [self goOpenFacebookAuthentication];
            /*
            NSLog(@"PFFacebookUtils not linked with logged in user, attempting to link");
            [PFFacebookUtils linkUser:user permissions:@[@"user_friends",@"public_profile", @"email"] block:^(BOOL succeeded, NSError *error) {
                NSLog(@"%i=succeeded, %@ = error",succeeded,error);
                if (succeeded)
                {
                    NSLog(@"successful linking to %@",[[PFUser currentUser] objectId]);
                    __block LTUpdateResult result = [self updateFbProfileForUser];
                    if ((result == LTUpdateNotNeeded) || (result == LTUpdateSucceeded))
                    {
                        [self loginAttemptedWithBool:YES];
                    }
                } else {
                    [self->HUD show:YES];
                    [self loginAttemptedWithBool:NO withError:error];
             
                     [[PFFacebookUtils session] closeAndClearTokenInformation];
                     FBSession *newSession = [FBSession activeSession];
                     if ([newSession state] != FBSessionStateCreated)
                     {
                     newSession =[[FBSession alloc] init];
                     [FBSettings setLoggingBehavior:[[NSSet alloc] initWithArray:@[FBLoggingBehaviorDeveloperErrors]]];
                     [newSession openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                     NSLog(@"session %@ | status %i | error %@",session,status,error);
                     switch (status)
                     {
                     case FBSessionStateOpen:
                     // call the legacy session delegate
                     //Now the session is open do corresponding UI changes
                     {
                     FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
                     [cacheDescriptor prefetchAndCacheForSession:session];
                     [FBSession openActiveSessionWithAllowLoginUI:NO];
                     [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"publish_stream",@"publish_actions", nil] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:NO completionHandler:nil];
                     NSLog(@"connection was opened and session is active");
                     [PFFacebookUtils linkUser:[PFUser currentUser] facebookId:[[session accessTokenData] userID]  accessToken:[[session accessTokenData] accessToken] expirationDate:[[session accessTokenData] expirationDate] block:^(BOOL succeeded, NSError *error) {
                     if (succeeded) {
                     logInSuccessful = YES;
                     } else {
                     NSLog(@"error in linking returned web account with currentUser == %@",error);
                     }
                     [self loginAttemptedWithBool:logInSuccessful];
                     }];
                     }
                     break;
                     case FBSessionStateClosedLoginFailed:
                     { // prefer to keep decls near to their use
                     // unpack the error code and reason in order to compute cancel bool
                     // call the legacy session delegate if needed
                     NSLog(@"closed login failed");
                     [self loginAttemptedWithBool:logInSuccessful];
                     }
                     break;
                     // presently extension, log-out and invalidation are being implemented in the Facebook class
                     default:
                     NSLog(@"default case");
                     [self loginAttemptedWithBool:logInSuccessful];
                     break; // so we do nothing in response to those state transitions
                     }
                     }];
                     }
                }
            }];*/
        }else
        {
        NSLog(@"PFFacebookUtils is already linked with a user w/ a sync'd fb account, just update profile and move on");
        __block LTUpdateResult result = [self updateFbProfileForUser];
        if ((result == LTUpdateNotNeeded) || (result == LTUpdateSucceeded))
        {
            NSLog(@"successful linking to %@",[[PFUser currentUser] objectId]);
            __block LTUpdateResult result = [self updateFbProfileForUser];
            if ((result == LTUpdateNotNeeded) || (result == LTUpdateSucceeded))
            {
                [self loginAttemptedWithBool:YES withError:nil];
            }
        } else {
            [self->HUD show:YES];
            [self loginAttemptedWithBool:NO withError:nil];
        }
    }
}

-(void)checkForLoggedInUser:(PFUser *)loggedInUser
{
    if (![PFUser currentUser] || ![loggedInUser isEqual:[PFUser currentUser]]) {
        NSLog(@"no logged in current user, will generate user by login through fb");
    } else {
        [self checkForLinkedUser:loggedInUser];
    }
}

#pragma mark - Continue mehtods
/* Login to facebook method */
- (IBAction)continueButtonTouchHandler:(id)sender  {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    self->HUD.mode = MBProgressHUDModeIndeterminate;
    self->HUD.labelText = @"checking for facebook";
    [self->HUD show:YES];
    
    NSLog(@"checking for saved user");
    NSString *savedSessionToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInSessionToken"];
    
    if ([self checkForSavedUser])
    {
        NSLog(@"saved user found with valid sessionToken");
        [PFUser becomeInBackground:savedSessionToken block:^(PFUser *user, NSError *error) {
            NSLog(@"becoming finished: user %@ | error %@ | currentUser %@ | lastLoggedInUserId %@", [user objectId], error, [[PFUser currentUser] objectId], [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInUserId"]);
            if (!user)
            {
                NSLog(@"becoming %@ did not return a user object",savedSessionToken);
                if (error)
                {
                    NSLog(@"and had error: %@",error);
                }else {
                    NSLog(@"and had no errors");
                }
            } else
            {
                NSLog(@"becoming %@ returned a user successfully we are %@ == %@",savedSessionToken,[PFUser currentUser],user);
                if (error)
                {
                    NSLog(@"and had error: %@",error);
                } else {
                    NSLog(@"and had no errors");
                    [self checkForLinkedUser:user];
                }
            }
        }];
    } else {
        [self checkForLoggedInUser:[PFUser currentUser]];
    }
}


-(void)hide:(BOOL)shouldHide afterDelay:(NSTimeInterval)afterDelay withCompletionBlock:(dispatch_block_t)completionBlock
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self->HUD hide:YES afterDelay:afterDelay];
    [self performBlockfterDelay:afterDelay withCompletionBlock:completionBlock];
}

-(void)performBlockFromTimer:(NSTimer*)timer
{
    dispatch_block_t completion = (dispatch_block_t)[timer userInfo];
    completion();
}

-(void)performBlockfterDelay:(NSTimeInterval)afterDelay withCompletionBlock:(dispatch_block_t)completionBlock
{
    [NSTimer scheduledTimerWithTimeInterval:afterDelay target:self selector:@selector(performBlockFromTimer:) userInfo:completionBlock repeats:NO];
}

-(void)hideHUDAfterDelay:(NSTimeInterval)delay andPerformSelector:(SEL)selector onTarget:(id)target withUserInfo:(id)timerUserInfo
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self->HUD hide:YES afterDelay:delay];
    [NSTimer scheduledTimerWithTimeInterval:delay target:target selector:selector userInfo:timerUserInfo repeats:NO];
}

-(void)pushUnearthedViewControllerFromTimer:(NSTimer *)timer
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    LTUnearthedViewController *unearthed = [[LTUnearthedViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:unearthed  animated:YES];
}

-(void)goOpenFacebookAuthentication
{
    
    // The permissions requested from the user, we're interested in their email address and their profile
    NSArray *permissionsArray = @[@"public_profile", @"email",@"user_friends"];
    NSLog(@"initializing fbuserlogin request with permissions array: %@",permissionsArray);
    
    FBSession *session = [[FBSession alloc] initWithPermissions:permissionsArray];
    
    [FBSession setActiveSession:session];
    
    [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
    
        switch (status) {
            case FBSessionStateOpen:
                NSLog(@"%@",error);
                [self loginAttemptedWithBool:NO withError:error];
                break;
            case FBSessionStateClosedLoginFailed: {
                // prefer to keep decls near to their use
                // unpack the error code and reason in order to compute cancel bool
                NSString *errorCode = [[error userInfo] objectForKey:FBErrorLoginFailedOriginalErrorCode];
                NSString *errorReason = [[error userInfo] objectForKey:FBErrorLoginFailedReason];
                
                
                if(error.code == 2 && ![errorReason isEqualToString:@"com.facebook.sdk:UserLoginCancelled"]) {
                    UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:errorCode
                                                                           message:errorReason
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"Ok"
                                                                 otherButtonTitles:nil];
                    [errorMessage performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                    errorMessage = nil;
                }
            }
                
                NSLog(@"%@",error);
                [self loginAttemptedWithBool:NO withError:error];
                break;
                // presently extension, log-out and invalidation are being implemented in the Facebook class
            default:
                
                NSLog(@"%@",error);
                [self loginAttemptedWithBool:NO withError:error];
                break; // so we do nothing in response to those state transitions
        }
    }];
    permissionsArray = nil;
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            // Handle the logged in scenario
            
            // You may wish to show a logged in view
            NSLog(@"session logged in");
            [self loginAttemptedWithBool:YES withError:nil];
            break;
        }
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed: {
            // Handle the logged out scenario
            
            // Close the active session
            [[PFFacebookUtils session] closeAndClearTokenInformation];
            
            NSLog(@"session logged out");
            // You may wish to show a logged out view
            
            break;
        }
        default:
            NSLog(@"session changed");
            break;
    }
    
    if (error) {
        // Handle authentication errors
        NSLog(@"error: %@ user message: %@",error,[FBErrorUtility userMessageForError:error]);if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
        {
            [self loginAttemptedWithBool:NO withError:error];
        } else
        {
            [self loginAttemptedWithBool:NO withError:error];
        }
    }
}

-(void)openFacebookAuthentication
{    // The permissions requested from the user, we're interested in their email address and their profile
    
    NSLog(@"openFacebook Authentication run");
   // NSLog(@"cleared out session");
    // Initialize a session object
    FBSession *session = [[FBSession alloc] init];
    // Set the active session
    [FBSession setActiveSession:session];
    // Open the session
    [session openWithBehavior:FBSessionLoginBehaviorWithNoFallbackToWebView
            completionHandler:^(FBSession *session,
                                FBSessionState status,
                                NSError *error) {
                // Respond to session state changes,
                // ex: updating the view
        [self sessionStateChanged:session state:status error:error];
    }];
}
    /*
    [FBSession.activeSession openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        switch (status){
            case FBSessionStateOpen:
                NSLog(@"FBSessionStateOpen | %@",error);
                didLogIn = YES;
                break;
            case FBSessionStateClosedLoginFailed:
                NSLog(@"FBSessionStateClosedLoginFailed");
                break;
            case FBSessionStateClosed:
                NSLog(@"FBSessionStateClosed");
                break;
            case FBSessionStateCreated:
                NSLog(@"FBSessionState1");
                break;
            case FBSessionStateCreatedOpening:
                NSLog(@"FBSessionState2");
                break;
            case FBSessionStateCreatedTokenLoaded:
                NSLog(@"FBSessionState3");
                break;
            case FBSessionStateOpenTokenExtended:
                NSLog(@"FBSessionState4");
                break;
            default:
                NSLog(@"FBSessionStateOther");
                break; // so we do nothing in response to those state transitions
        }
    }];
    permissionsArray = nil;
    [self loginAttemptedWithBool:didLogIn withError:[NSError errorWithDomain:FacebookSDKDomain code:208 userInfo:@{}]];*/

-(void)loginAttemptedWithBool:(BOOL)didLogIn withError:(NSError *)error
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (didLogIn)
    {
        NSLog(@"detected fb linkage, logging in");
        self->HUD.mode = MBProgressHUDModeCustomView;
        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buriediconcircleshine_37.png"]];
        self->HUD.labelText = @"welcome to buried";
        self->HUD.detailsLabelText = nil;
        [self hideHUDAfterDelay:1.0f andPerformSelector:@selector(pushUnearthedViewControllerFromTimer:) onTarget:self withUserInfo:@{@"animated":@YES}];
        
        [self enableAllBarButtons];
    }
    else
    {
        self->HUD.mode = MBProgressHUDModeCustomView;
        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]] && [PFUser currentUser])
        {
            self->HUD.labelText = @"login failure";
            [self->HUD setDetailsLabelText:[[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:@"error"]] lowercaseString]];
            [self->HUD hide:YES afterDelay:1.0f];
        } else if ([PFUser currentUser]) {
            NSLog(@"%@",[error localizedFailureReason] ? [error localizedFailureReason] : [[error userInfo] objectForKey:@"error"]
                  );
            self->HUD.labelText = @"couldn't connect to facebook";
            NSNumber *userCancelledCode = [NSNumber numberWithInteger:[error code] ? [error code] : [(NSError *)[[error userInfo]  objectForKey:@"error"] code]];
            if ([userCancelledCode isEqualToNumber:@2])
            {
                NSLog(@"user cancelled and denied access");
                [self->HUD setDetailsLabelText:@"facebook access was denied"];
            }
            else if ([userCancelledCode isEqualToNumber:@208])
            {
                NSLog(@"fb account linked to another account");
                [self->HUD setDetailsLabelText:@"that facebook account is already in use"];
            }
            else
            {
                NSLog(@"fb account linking failed with error %@",[FBErrorUtility userMessageForError:error]);
                [self->HUD setDetailsLabelText:[FBErrorUtility userMessageForError:error]];
            }
            
            [self hide:YES afterDelay:2.0f withCompletionBlock:^(){
                NSLog(@"session failed out");
                [self enableAllBarButtons];
            }];
            
        }
        else
        {
            [self->HUD setDetailsLabelText:[[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:@"error"]] lowercaseString]];
            self->HUD.labelText = @"no user found";
            [self->HUD hide:YES afterDelay:1.0f];
            [self enableAllBarButtons];
        }
    }
}


-(void)loginAttemptedWithBool:(BOOL)didLogIn
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (didLogIn)
    {
        NSLog(@"detected fb linkage, logging in");
        self->HUD.mode = MBProgressHUDModeCustomView;
        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buriediconcircleshine_37.png"]];
        self->HUD.labelText = @"welcome to buried";
        self->HUD.detailsLabelText = nil;
        [self hideHUDAfterDelay:1.0f andPerformSelector:@selector(pushUnearthedViewControllerFromTimer:) onTarget:self withUserInfo:@{@"animated":@YES}];
    }
    else
    {
        self->HUD.mode = MBProgressHUDModeCustomView;
        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]] && [PFUser currentUser])
        {
            self->HUD.labelText = @"login failure";
        } else if ([PFUser currentUser]) {
            self->HUD.labelText = @"fb failed to link";
        }
        else
        {
            self->HUD.labelText = @"no user found";
        }
        self->HUD.detailsLabelText = nil;
        [self->HUD hide:YES afterDelay:1.0f];
    }
}

- (void)facebookLoginButtonTouchHandler:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

-(LTUpdateResult)logInToFacebookWithSuccessHandler:(PFUserResultBlock)successHandler andErrorHandler:(PFUserResultBlock)errorHandler
{
    
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    __block LTUpdateResult result = LTUpdateResultNil;
    
    [self disableAllBarButtons];
    // This code if the user wishes to log in with Facebook
    
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSLog(@"creating modal progress hud");
    
    // Star our activity indicator HUD
    self->HUD.mode = MBProgressHUDModeIndeterminate;
    self->HUD.labelText = @"logging in";
    [self->HUD show:YES];
    
    // The permissions requested from the user, we're interested in their email address and their profile
    NSArray *permissionsArray = @[@"public_profile", @"email",@"user_friends"];
    NSLog(@"initializing fbuserlogin request with permissions array: %@",permissionsArray);
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        NSLog(@"returned user: %@,current user:%@, error: %@, activeSession: %@",user,[PFUser currentUser],error,[PFFacebookUtils session]);
        // login attempted
        if (!user) {
            // this case handles either a connection error or a cancelled login
            self->HUD.mode = MBProgressHUDModeCustomView;
            NSDictionary *errorUserInfo = [error userInfo];
            NSString *innerError = (NSString *)[errorUserInfo objectForKey:FBErrorLoginFailedOriginalErrorCode];
            
            // this code is run when the user chose to cancel the fb login
            if ([innerError isEqualToString:@"200"])
            {
                NSLog(@"uh oh. The user outright cancelled the Facebook login. error:%@",error);
                self->HUD.labelText = @"login cancelled";
                NSLog(@"%@",innerError);
                self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-circlemark"]];
                
            } else {
                NSLog(@"uh oh. an error:%@",error);
                self->HUD.labelText = @"login did not complete";
                NSLog(@"%@",innerError);
                self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-circlemark"]];
                
            }
        } else {
            // user succesfully returned, ask for the user's fb profile and store in parse db and locally on the phone
            successHandler(user,nil);
        }
    }];
    
    NSLog(@"login finished with result:%i",(int)result);
    return result;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    if ([self.navigationItem.rightBarButtonItem isEnabled])
    {
        [textField setReturnKeyType:UIReturnKeyDone];
        
        if ([textField isEqual:self.emailField])
        {
            [textField setKeyboardType:UIKeyboardTypeEmailAddress];
        }
        else
        {
            [textField setKeyboardType:UIKeyboardTypeASCIICapable];
        }
        
        return YES;
    }
    else
        return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self->currentResponder = textField;
    
    if (![textField.textColor isEqual:[UIColor darkTextColor]] || !(textField.alpha == 1))
    {
        
    }
    
    BOOL isNotLast = NO;
    
    if ([self->currentTextFields indexOfObject:textField] < (self->currentTextFields.count - 1))
        isNotLast = YES;
    
    self.navigationItem.leftBarButtonItem = self->clearButton;
    
    NSLog(@"currentResponder - %@ | textfield - %@",self->currentResponder.accessibilityLabel,textField.accessibilityLabel);
    
    __block NSInteger keyboardHeight = 432;
    __block NSInteger centerPointYForViewWithKeyboardUp = (self.view.frame.size.height - keyboardHeight)*2;
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        NSLog(@"%f,%f self.center %f, %f self.frame %f,%f self.bounds %i isediting",self.view.center.x,self.view.center.y,self.view.frame.origin.x,self.view.frame.origin.y,self.view.bounds.origin.x,self.view.bounds.origin.y,self.isEditing);
        
        NSLog(@"viewFrame w: %f h: %f",self.view.frame.size.width, self.view.frame.size.height);
        
        NSLog(@"%f view.center.y | %f textfield.center.y | %li keyboardHeight| %li centerPointYForViewWithKeyboardUp",self.view.center.y, textField.center.y, (long)keyboardHeight, (long)centerPointYForViewWithKeyboardUp);
        if (self.view.center.y == self->originalViewCenter.y)
        {
            NSLog(@"view.center.y: %f == self->originalViewCenter.y: %f",self.view.center.y, self->originalViewCenter.y);
            self.view.center = CGPointMake(self.view.center.x,centerPointYForViewWithKeyboardUp);
        }
        
        NSLog(@"text.center.y: %f | self.view.center.y: %f | emailField %f | offset %f",textField.center.y,self.view.center.y,self->emailField.center.y,(textField.center.y - self->emailField.center.y));
        self.view.center = CGPointMake((self.view.frame.size.width/2.0),centerPointYForViewWithKeyboardUp - (textField.center.y - self->emailField.center.y));
    } completion:^(BOOL finished) {
        NSLog(@"text.center.y: %f | self.view.center.y: %f | emailField.center.y %f",textField.center.y,self.view.center.y,self->emailField.center.y);
    }];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"should textfield %@ end its editing?",textField.accessibilityLabel);
    if ([textField isEditing])
    {
        NSLog(@"yes");
        return YES;
    }
    else
        return NO;
}

-(void)fieldToChangeBorderOf:(UITextField *)textField toColor:(CGColorRef)borderColor
{
    CABasicAnimation *color = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    color.toValue   = (__bridge id)borderColor;
    color.fromValue = (id)textField.layer.borderColor;
    // ... and change the model value
    textField.layer.borderColor = borderColor;
    
    CABasicAnimation *width = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    width.toValue = @1;
    width.fromValue = (id)[NSNumber numberWithFloat:textField.layer.borderWidth];
    // ... and change the model value
    textField.layer.borderWidth = 1.0f;
    
    CABasicAnimation *corner = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    corner.toValue = @8;
    corner.fromValue = (id)[NSNumber numberWithFloat:textField.layer.cornerRadius];
    // ... and change the model value
    textField.layer.cornerRadius = 8.0f;
    
    CAAnimationGroup *all = [CAAnimationGroup animation];
    // animate all as a group with the duration of 0.5 seconds
    all.duration   = 0.5;
    all.animations = @[color, width,corner];
    // optionally add other configuration (that applies to all animations)
    all.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [textField.layer addAnimation:all forKey:@"color and corner and width"];
    
    textField.layer.masksToBounds=YES;
}

-(void)revertField:(UITextField *)textField animated:(BOOL)animated
{
    CABasicAnimation *color = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    color.toValue   = (id)self->initialBorderSpecs.borderColor;
    color.fromValue = (id)textField.layer.borderColor;
    // ... and change the model value
    textField.layer.borderColor = self->initialBorderSpecs.borderColor;
    
    CABasicAnimation *width = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    width.toValue = (id)[NSNumber numberWithFloat:self->initialBorderSpecs.borderWidth];
    width.fromValue = (id)[NSNumber numberWithFloat:textField.layer.borderWidth];
    // ... and change the model value
    textField.layer.borderWidth = self->initialBorderSpecs.borderWidth;
    
    CABasicAnimation *corner = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    corner.toValue = @8;
    corner.fromValue = (id)[NSNumber numberWithFloat:textField.layer.cornerRadius];
    // ... and change the model value
    textField.layer.cornerRadius = 8.0f;
    
    CAAnimationGroup *all = [CAAnimationGroup animation];
    // animate all as a group with the duration of 0.5 seconds
    if (animated)
        all.duration = 0.3f;
    else
        all.duration = 0.0f;
    all.animations = @[color, width,corner];
    
    // optionally add other configuration (that applies to all animations)
    all.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [textField.layer addAnimation:all forKey:@"color and width and corner"];
    
    textField.layer.masksToBounds=YES;
}

-(BOOL)validateField:(UITextField *)textField
{
    NSLog(@"validateField called for %@",textField);
    if (textField.text.length < 1) {
        return NO;
    } else if ([textField isEqual:self.emailField])
    {
        if ([self isValidEmail:textField.text])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    } else if (![self.passwordField.text isEqualToString:self.confirmField.text] && [self->currentViewState isDescendantOfView:signUpView])
    {
        return NO;
    } else
    {
        return YES;
    }
    
}

-(void)flashFieldAsError:(NSArray *)fields {
    
    NSLog(@"validateAllFields Called");
    NSMutableDictionary *fieldsToChangeColorOf = [[NSMutableDictionary alloc] init];
    UIColor *changeColor = [LTGrassViewController errorColor];
    
    for (UITextField *textField in fields) {
        [fieldsToChangeColorOf setObject:changeColor forKey:textField.accessibilityLabel];
    }
    
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction
                              animations:^{
                                  for (UITextField *thisField in fields) {
                                      if ([[fieldsToChangeColorOf objectForKey:thisField.accessibilityLabel] isEqual:[LTGrassViewController errorColor]])
                                          thisField.alpha = 0;
                                  }
                              } completion:^(BOOL finished) {
                                  NSLog(@"hidden!");
                                  [UIView animateKeyframesWithDuration:1.5 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
                                      [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
                                          for (UITextField *thisField in fields) {
                                              if ([[fieldsToChangeColorOf objectForKey:thisField.accessibilityLabel] isEqual:[LTGrassViewController errorColor]])
                                              {
                                                  thisField.alpha = 1;
                                                  thisField.textColor = [fieldsToChangeColorOf objectForKey:thisField.accessibilityLabel];
                                              }
                                          }
                                      }];
                                      [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
                                          for (UITextField *thisField in fields) {
                                              if ([[fieldsToChangeColorOf objectForKey:thisField.accessibilityLabel] isEqual:[LTGrassViewController errorColor]])
                                                  thisField.alpha = 0;
                                          }
                                      }];
                                  } completion:^(BOOL finished) {
                                      NSLog(@"swapped out and showed message, then hid again");
                                      [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1 animations:^{
                                              for (UITextField *thisField in fields) {
                                                  
                                                  if ([[fieldsToChangeColorOf objectForKey:thisField.accessibilityLabel] isEqual:[LTGrassViewController errorColor]])
                                                  {
                                                      thisField.alpha = 1;
                                                      thisField.textColor = [UIColor darkTextColor];
                                                  }
                                              }
                                          }];
                                      } completion:^(BOOL finished) {
                                          if (finished)
                                          {
                                              NSLog(@"restored to original state");
                                          }
                                      }];
                                      
                                  }];
                              }];
    
}


-(void)validateFields:(NSArray *)fields {
    NSLog(@"validateAllFields Called");
    NSMutableDictionary *fieldsToChangeColorOf = [[NSMutableDictionary alloc] init];
    UIColor *changeColor = [[UIColor alloc] init];
    
    for (UITextField *textField in fields) {
        BOOL wasValidated = [self validateField:textField];
        if (wasValidated)
        {
            changeColor = [LTGrassViewController successColor];
        }
        else
        {
            changeColor = [LTGrassViewController errorColor];
        }
        
        if ([[fieldsToChangeColorOf objectForKey:self.emailField.accessibilityLabel] isEqual:[LTGrassViewController errorColor]] && ![textField.accessibilityLabel isEqualToString:self.emailField.accessibilityLabel])
        {
            NSLog(@"skipping %@",textField.accessibilityLabel);
        } else
        {
            [fieldsToChangeColorOf setObject:changeColor forKey:textField.accessibilityLabel];
        }
    }
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction
                              animations:^{
                                  for (UITextField *thisField in fields) {
                                      if ([[fieldsToChangeColorOf objectForKey:thisField.accessibilityLabel] isEqual:[LTGrassViewController errorColor]])
                                          thisField.alpha = 0;
                                  }
                              } completion:^(BOOL finished) {
                                  NSLog(@"hidden!");
                                  [UIView animateKeyframesWithDuration:1.5 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
                                      [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
                                          for (UITextField *thisField in fields) {
                                              if ([[fieldsToChangeColorOf objectForKey:thisField.accessibilityLabel] isEqual:[LTGrassViewController errorColor]])
                                              {
                                                  thisField.alpha = 1;
                                                  thisField.textColor = [fieldsToChangeColorOf objectForKey:thisField.accessibilityLabel];
                                              }
                                          }
                                      }];
                                      [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
                                          for (UITextField *thisField in fields) {
                                              if ([[fieldsToChangeColorOf objectForKey:thisField.accessibilityLabel] isEqual:[LTGrassViewController errorColor]])
                                                  thisField.alpha = 0;
                                          }
                                      }];
                                  } completion:^(BOOL finished) {
                                      NSLog(@"swapped out and showed message, then hid again");
                                      [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1 animations:^{
                                              for (UITextField *thisField in fields) {
                                                  
                                                  if ([[fieldsToChangeColorOf objectForKey:thisField.accessibilityLabel] isEqual:[LTGrassViewController errorColor]])
                                                  {
                                                      thisField.alpha = 1;
                                                      thisField.textColor = [UIColor darkTextColor];
                                                  }
                                              }
                                          }];
                                      } completion:^(BOOL finished) {
                                          if (finished)
                                          {
                                              NSLog(@"restored to original state");
                                          }
                                      }];
                                      
                                  }];
                              }];
}

-(void)revertAllFields {
    for (UITextField *textField in self->currentTextFields) {
        [self revertField:textField animated:YES];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    NSLog(@"textField %@ ended editing",textField.accessibilityLabel);
    
    self.navigationItem.leftBarButtonItem = self->goBackButton;
    self.navigationItem.rightBarButtonItem = self->submitButton;
}

-(void)returnViewToOrigin {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [UIView animateWithDuration:0.3 delay:[UIKeyboardAnimationDurationUserInfoKey floatValue] options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.center = CGPointMake(self->originalViewCenter.x, self->originalViewCenter.y);
    } completion:^(BOOL finished) {
        if (finished)
        {
            NSLog(@"keyboard hiding animation done");
            NSLog(@"clearing current responder");
            self->currentResponder = nil;
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    [textField resignFirstResponder];
    
    [self returnViewToOrigin];
    
    return NO; // disabled, textFields just close
}

- (IBAction)notYouButtonTouched:(id)sender
{
    // as of this moment ass this button does is to clear the stored userId for the last logged in user to remove the greeting, however, with the new account management branch, this will play an integral role in switching accounts and allowing the user to authenticate again as someone else
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    [currentInstallation removeObjectForKey:@"lastLoggedInUserId"];
    
    [currentInstallation saveEventually:^(BOOL succeeded, NSError *error) {
        NSLog(@"currently stored last logged in user: %@",[currentInstallation objectForKey:@"lastLoggedInUserId"]);
        if (succeeded)
            NSLog(@"lastLoggedInUserId cleared successfully and sync'd with parse");
        else
            NSLog(@"unabled to save the clearing of the last login to parse, please contact the team.");
    }];
    
    // clear stored account in user defaults
    [LTStartScreenViewController storeUserDataToDefaults:nil];
    NSLog(@"NSUserDefaults cleared for lastLoggedInUserId & displayName & facebookId & userName & sessionToken");
    
    // invalidating session
    [[PFFacebookUtils session] closeAndClearTokenInformation];
    [PFUser logOut];
    
    [self showView:self->startView];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self clearHUD];
    [self enableAllBarButtons];
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSLog(@"info: %@",info);
    
    if (![self isValidEmail:self.emailField.text])
    {
        self->HUD.mode = MBProgressHUDModeCustomView;
        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
        self->HUD.labelText = @"invalid email address";
        [self->HUD show:YES];
        [self->HUD hide:YES afterDelay:1.0f];
        
        return NO;
    } else if ((self.passwordField.text.length < 1) || (self.confirmField.text.length < 1))
    {
        self->HUD.mode = MBProgressHUDModeCustomView;
        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
        self->HUD.labelText = @"password is too short";
        [self->HUD show:YES];
        [self->HUD hide:YES afterDelay:1.0f];
        
        return NO;
    } else if (![self.passwordField.text isEqualToString:self.confirmField.text])
    {
        self->HUD.mode = MBProgressHUDModeCustomView;
        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
        self->HUD.labelText = @"passwords must match";
        [self->HUD show:YES];
        [self->HUD hide:YES afterDelay:1.0f];
        
        return NO;
    } else {
        NSLog(@"user info acceptable for signup");
        return YES;
    }
}

+(void)storeUserDataToDefaults:(PFUser*)user
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSString *lastLoggedInUserId = nil;
    NSString *lastLoggedInFacebookId = nil;
    NSString *lastLoggedInDisplayName = nil;
    NSString *lastLoggedInUserName = nil;
    NSString *lastLoggedInSessionToken = nil;
    NSDictionary *lastLoggedInUserFBAuthData = @{};
    
    //write to user defaults and update buttons
    if ([PFFacebookUtils isLinkedWithUser:user])
    {
        NSLog(@"fb account detected, id: %@", [user objectForKey:@"facebookId"]);
        lastLoggedInUserFBAuthData = [[user objectForKey:@"authData"] objectForKey:@"facebook"];
        
    }
    
    lastLoggedInUserId = [user objectId];
    lastLoggedInFacebookId = [user objectForKey:@"facebookId"];
    lastLoggedInDisplayName = [user objectForKey:@"firstName"];
    lastLoggedInUserName = [user username];
    lastLoggedInSessionToken = [user sessionToken];
    
    // write to user defaults
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInUserId forKey:@"lastLoggedInUserId"];
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInFacebookId forKey:@"lastLoggedInFacebookId"];
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInDisplayName forKey:@"lastLoggedInDisplayName"];
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInUserName forKey:@"lastLoggedInUserName"];
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInSessionToken forKey:@"lastLoggedInSessionToken"];
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInUserFBAuthData forKey:@"lastLoggedInUserFBAuthData"];
    
    NSLog(@"written to NSUserDefaults for offline/immediate access: lastLoggedInUserId/%@ displayName/%@ userName/%@ lastLoggedInFacebookId/%@ lastLoggedInSessionToken/%@/lastLoggedInUserFBAuthData/%@/",lastLoggedInUserId,lastLoggedInDisplayName,lastLoggedInUserName,lastLoggedInFacebookId,lastLoggedInSessionToken,[lastLoggedInUserFBAuthData description]);
}

/// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    
    NSLog(@"user %@ (%@) successfully signed up",user.username,user.objectId);
    [LTStartScreenViewController storeUserDataToDefaults:user];
    [self showView:self->startView];
    
    self->HUD.mode = MBProgressHUDModeCustomView;
    self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self->HUD.labelText = @"success!";
    
    [self->HUD hide:YES afterDelay:1.0f];
}

/// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    self->HUD.mode = MBProgressHUDModeCustomView;
    self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
    if ([error code] == 202)
    {
        self->HUD.labelText = @"username already taken";
        [self flashFieldAsError:[[NSArray alloc] initWithObjects:self.emailField, nil]];
    }
    else
    {
        self->HUD.labelText = @"login error";
    }
    
    [self->HUD hide:YES afterDelay:1.0f];
    NSLog(@"signing up user failed because error:%@",error);
}

/// Sent to the delegate whefn the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self showView:self->startView];
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
    if (![self isValidEmail:self.emailField.text])
    {
        self->HUD.mode = MBProgressHUDModeCustomView;
        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
        self->HUD.labelText = @"invalid email address";
        [self->HUD show:YES];
        [self->HUD hide:YES afterDelay:1.0f];
        
        return NO;
    } else if (self.passwordField.text.length < 1)  {
        self->HUD.mode = MBProgressHUDModeCustomView;
        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
        self->HUD.labelText = @"password is too short";
        [self->HUD show:YES];
        [self->HUD hide:YES afterDelay:1.0f];
        
        return NO;
    } else {
        NSLog(@"user info acceptable for login");
        return YES;
    }
}

/*! @name Responding to Actions */
/// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [LTStartScreenViewController storeUserDataToDefaults:user];
    NSLog(@"loginviewController dismissed with successful login, current user: %@",user);
    [self showView:self->startView];
    
    self->HUD.mode = MBProgressHUDModeCustomView;
    self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self->HUD.labelText = @"success!";
    [self->HUD hide:YES afterDelay:1.0f];
}

/// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    self->HUD.mode = MBProgressHUDModeCustomView;
    self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
    if ([error code] == 101)
    {
        self->HUD.labelText = @"password incorrect";
        [self flashFieldAsError:[[NSArray alloc] initWithObjects:self.passwordField
                                 , nil]];
    }
    else
    {
        self->HUD.labelText = @"login error";
        [self validateFields:self->currentTextFields];
    }
    
    [self->HUD hide:YES afterDelay:1.0f];
    NSLog(@"signing up user failed because error:%@",error);
}

/// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self showView:self->startView];
    
}
- (LTUpdateResult)updateFbProfileForUser
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    __block LTUpdateResult updateResult = LTUpdateResultNil;
    
    self->HUD.mode = MBProgressHUDModeCustomView;
    self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconmonstr-smiley-confused-icon-37_MB.png"]];
    self->HUD.labelText = @"figuring out if we've met before";
    [self->HUD show:YES];
    
    PFUser *user = [PFUser currentUser];
    
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"profile download finished");
        // the profile download finished either successfully or unsuccessfully
        if (error) {
            // there was an error downloading the profile
            NSLog(@"error in retrieving profile, failing out, error %@",error);
            
            // let the user know
            self->HUD.mode = MBProgressHUDModeCustomView;
            self->HUD.labelText = @"can't remember right now";
            self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconmonstr-smiley-scared-icon-37_MB.png"]];
            
            updateResult = LTUpdateFailed;
        } else {
            NSLog(@"profile retrieved successfully");
            NSLog(@"connection: %@,result: %@, error: %@",connection,result,error);
            
            NSDictionary<FBGraphUser> *userData = result;
            
            if ([[[PFUser currentUser] objectForKey:@"fbProfileChangedAt"] isEqualToString:userData[@"updated_time"]])
            {
                NSLog(@"buried's user info is up to date with facebook");
                
                self->HUD.mode = MBProgressHUDModeCustomView;
                self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconmonstr-smiley-wink-icon-48_MB.png"]];
                self->HUD.labelText = [NSString stringWithFormat:@"hello %@",[[[PFUser currentUser] objectForKey:@"firstName"] lowercaseString]];
                
                updateResult = LTUpdateNotNeeded;
            }
            else
            {
                
                NSLog(@"buried's user info is out of date with facebook");
                NSLog(@"syncing user data with facebook");
                
                self->HUD.mode = MBProgressHUDModeCustomView;
                self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconmonstr-quote-15-icon-37_MB.png"]];
                self->HUD.labelText = @"getting to know you better";
                
                [[PFUser currentUser] setObject:userData[@"id"] forKey:@"facebookId"];
                
                [[PFUser currentUser] setObject:userData[@"first_name"] forKey:@"firstName"];
                [[PFUser currentUser] setObject:userData[@"last_name"] forKey:@"lastName"];
                
                if (userData[@"last_name"])
                {
                    [[PFUser currentUser] setObject:[NSString stringWithFormat:@"%@ %@",userData[@"first_name"],userData[@"last_name"]] forKey:@"displayName"];
                } else {
                    [[PFUser currentUser] setObject:[NSString stringWithFormat:@"%@",userData[@"first_name"]]  forKey:@"displayName"];
                }
                [[PFUser currentUser] setObject:userData[@"updated_time"] forKey:@"fbProfileChangedAt"];
                
                
                NSLog(@"updating device's channels to listen for pushes for the now logged in user");
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                // Update installation with current user info, create a channel for push directly to user by id, save the information to a Parse installation.
                
                // double check global is registered
                [currentInstallation addUniqueObject:@"global" forKey:@"channels"];
                
                // Register for user specific channels;
                [currentInstallation addUniqueObject:[user objectId] forKey:@"channels"];
                
                // save the addition of the user's id to the channels
                [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!succeeded)
                    {
                        NSLog(@"user %@ installation failed to save with error (%@), they will not be configured to receive pushes",[[PFUser currentUser] objectId],error);
                    } else
                    {
                        NSLog(@"installation data saved for user %@, they can now receive pushes correctly",[[PFUser currentUser] objectId]);
                    }
                }];
                
                NSLog(@"current channels: %@", [currentInstallation channels]);
                
                // save the user's sync'd model locally to the device and to the parse cloud
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!succeeded)
                    {
                        NSLog(@"user %@ installation failed to save with error (%@), they will not be configured to receive pushes",[[PFUser currentUser] objectId],error);
                    } else
                    {
                        NSLog(@"installation data saved for user %@, they can now receive pushes correctly",[[PFUser currentUser] objectId]);
                        self->HUD.mode = MBProgressHUDModeCustomView;
                        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconmonstr-smiley-wink-icon-48_MB.png"]];
                        self->HUD.labelText = [NSString stringWithFormat:@"hello %@",[[[PFUser currentUser] objectForKey:@"firstName"] lowercaseString]];
                    }
                }];
                [LTStartScreenViewController storeUserDataToDefaults:user];
            };
        }
    }];
    
    return updateResult;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSLog(@"NavController current view is %@",[[navigationController visibleViewController] class]);
    NSLog(@"New view controller is %@",[viewController class]);
}

-(LTGrassState)defaultGrassStateForView
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    return LTGrassStateGrown;
}

@end
