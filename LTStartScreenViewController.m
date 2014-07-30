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
        self->continueButton = [[UIBarButtonItem alloc] initWithTitle:@"continue" style:UIBarButtonItemStyleBordered target:self action:@selector(continueButtonTouchHandler:)];
        self->submitButton = [[UIBarButtonItem alloc] initWithTitle:@"submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitButtonTouchHandler:)];
        self->goBackButton = [[UIBarButtonItem alloc] initWithTitle:@"go back" style:UIBarButtonItemStyleBordered target:self action:@selector(goBackButtonTouchHandler:)];
        self->notYouButton = [[UIBarButtonItem alloc] initWithTitle:@"not you?" style:UIBarButtonItemStyleBordered target:self action:@selector(notYouButtonTouched:)];
        self->clearButton = [[UIBarButtonItem alloc] initWithTitle:@"clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearButtonTouchHandler:)];
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
    
    self->closeTextFieldGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapInMainView:)];
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self.navigationController pushViewController:[[LTUnearthedViewController alloc] initWithStyle:UITableViewStylePlain] animated:NO];
    }
    
    // Add signup navigation bar button
    self.navigationItem.leftBarButtonItem = self->signUpButton;
    
    // Add login/sign in navigation bar button;
    self.navigationItem.rightBarButtonItem = self->signInButton;
    
    self->initialBorderSpecs.borderColor = self.emailField.layer.borderColor;
    self->initialBorderSpecs.borderWidth = self.emailField.layer.borderWidth;
    self->initialBorderSpecs.cornerRadius = self.emailField.layer.cornerRadius;
    self->initialBorderSpecs.masksToBounds = self.emailField.layer.masksToBounds;
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
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInUserId"] length] > 0)
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
        self->lastLoggedInLabel.text = [[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInDisplayName"]] lowercaseString];
        self.navigationItem.rightBarButtonItem = self->continueButton;
    } else {
        
        // Add login/sign in navigation bar button
        self.navigationItem.rightBarButtonItem = self->signInButton;
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
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
    if ([self checkForSavedUser])
    {
        NSString * displayName = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoggedInDisplayName"];
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
            NSLog(@"displayName is invalid for user %@", [[PFUser currentUser] objectId]);
        [self showView:self->startView];
    }
}

#pragma mark - SignUpView methods
- (IBAction)submitButtonTouchHandler:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self cleanUpAfterEditing];
    
    if (!self->HUD)
    {
        self->HUD = [[MBProgressHUD alloc] initWithView:[[[UIApplication sharedApplication] windows] firstObject]];
        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:HUD];
        
        self->HUD.delegate = self;
    }
    
    self->HUD.mode = MBProgressHUDModeIndeterminate;
    self->HUD.labelText = @"submitting";
    [self->HUD show:YES];
    
    self.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.emailField.text,@"username",self.passwordField.text,@"password",self.emailField.text,@"email", nil];
    NSLog(@"submitting userInfo: %@",self.userInfo);
    
    if ([self->signUpView isDescendantOfView:self->currentViewState])
    {
        if ([self signUpViewController:self.signUpVC shouldBeginSignUp:self.userInfo])
        {
            self->HUD.labelText=@"signing up";
            NSLog(@"signup fields are good to go");
            
            PFUser *userToSignup = [[PFUser alloc] init];
            
            [userToSignup setEmail:self.userInfo[@"email"]];
            [userToSignup setUsername:self.userInfo[@"username"]];
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
            NSLog(@"signup fields have errors");
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
    [self cleanUpAfterEditing];
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
    [self->currentResponder setText:@""];
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
    self->goBackButton.enabled = NO;
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
    self->goBackButton.enabled = YES;
    self->continueButton.enabled = YES;
    self->submitButton.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)showView:(UIView *)view
{
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
    if (![self->currentViewState isDescendantOfView:view] && self->currentViewState)
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
        [self.navigationItem setLeftBarButtonItem:self->goBackButton animated:YES];
        [self.navigationItem setRightBarButtonItem:self->submitButton animated:YES];
        [passwordField setSecureTextEntry:([view isDescendantOfView:self->loginView])];
    } else if ([view isDescendantOfView:self->savedAccountView])
        [self changeButtonsForSavedUser];
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
        } else if ([view isDescendantOfView:signUpView] || [view isDescendantOfView:loginView])
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
        self->originalViewCenter = self.view.center;
        NSLog(@"currentTextFields :%@",self->currentTextFields);
        [self enableAllBarButtons];
    }];
}

- (void)hideViewElements:(NSMutableArray *)viewElements
{
    
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (viewElements.count > 0)
        [self disableAllBarButtons];
    
    [UIView animateWithDuration:0.5 animations:^{
        for (UIView *element in viewElements) {
            element.alpha = 0;
            if ([element isMemberOfClass:[UITextField class]])
            {
                [(UITextField *)[element self] setText:@""];
                ((UITextField *)[element self]).layer.borderColor = self->initialBorderSpecs.borderColor;
                ((UITextField *)[element self]).layer.borderWidth = self->initialBorderSpecs.borderWidth;
                ((UITextField *)[element self]).layer.cornerRadius = self->initialBorderSpecs.cornerRadius;
                ((UITextField *)[element self]).layer.masksToBounds = self->initialBorderSpecs.masksToBounds;
            }
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

- (void)continueToUnearthedWithFbLoginPermissionsAfterPINVerificationBy:(id)sender
{
    // This code if the user wishes to log in with Facebook
    
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSLog(@"creating modal progress hud");
    //[(UIBarButtonItem*)sender setEnabled:NO];
    
    // we like our HUDs over everything so grab the top window and place the HUD there
    UIWindow *thePrimaryWindow = [[[UIApplication sharedApplication] windows] firstObject];
    
    // check to see if the HUD has ever been initialized
    if (!self->HUD)
    {
    self->HUD = [[MBProgressHUD alloc] initWithView:[[[UIApplication sharedApplication] windows] firstObject]];
    [thePrimaryWindow addSubview:HUD];
    } else {
        [thePrimaryWindow bringSubviewToFront:self->HUD];
    }
    
    // Star our activity indicator HUD
    self->HUD.mode = MBProgressHUDModeIndeterminate;
    self->HUD.delegate = self;
    self->HUD.labelText = @"logging in";
    [self->HUD show:YES];
    
    // The permissions requested from the user, we're interested in their email address and their profile
    NSArray *permissionsArray = @[@"public_profile", @"email"];
    NSLog(@"initializing fbuserlogin request with permissions array: %@",permissionsArray);
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        NSLog(@"returned user: %@,current user:%@, error: %@, activeSession: %@",user,[PFUser currentUser],error,[PFFacebookUtils session]);
        // login attempted
        if (!user) {
            // this case handles either a connection error or a cancelled login
            self->HUD.mode = MBProgressHUDModeCustomView;
            
            if (!error) {
                // this code is run when the user chose to cancel the fb login
                NSLog(@"uh oh. The user outright cancelled the Facebook login.");
                self->HUD.labelText = @"login cancelled";
                self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-circlehand.png"]];
                [self->HUD hide:YES afterDelay:1.0f];
            } else {
                // this code is run when the user tried to login but ran into a connection or authentication error
                NSLog(@"uh oh. An error occurred: %@", error);
                self->HUD.labelText = @"%@",[[error userInfo] objectForKey:@"error"];
                self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
                [self->HUD hide:YES afterDelay:1.0f];
            }
        } else {
            // user succesfully returned, ask for the user's fb profile and store in parse db and locally on the phone
            [self updateFbProfileForUser:user];
            
            NSLog(@"user successfully returned, grabbing fb data if necessary...");
                        if (!user.username || !user.email || ![user objectForKey:@"displayName"])
                        {
                        }else{
                            // send the user on through to the unearthed view
                    [self.navigationController pushViewController:[[LTUnearthedViewController alloc] initWithStyle:UITableViewStylePlain] animated:YES];
                        }
        }
    }];
    
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
    
    BOOL isNotLast = NO;
    
    if ([self->currentTextFields indexOfObject:textField] < (self->currentTextFields.count - 1))
        isNotLast = YES;
    
    self.navigationItem.leftBarButtonItem = clearButton;
    
    self->currentResponder = textField;
    NSLog(@"currentResponder - %@ | textfield - %@",self->currentResponder,textField);
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        NSLog(@"%f,%f self.center %f, %f self.frame %f,%f self.bounds %i isediting",self.view.center.x,self.view.center.y,self.view.frame.origin.x,self.view.frame.origin.y,self.view.bounds.origin.x,self.view.bounds.origin.y,self.isEditing);
        
        NSLog(@"viewFrame w: %f h: %f",self.view.frame.size.width, self.view.frame.size.height);
        NSInteger keyboardHeight = 432;
        NSInteger centerPointYForViewWithKeyboardUp = (self.view.frame.size.height - keyboardHeight)*2;
        NSLog(@"%f view.center.y | %f textfield.center.y | %li keyboardHeight| %li centerPointYForViewWithKeyboardUp",self.view.center.y, textField.center.y, (long)keyboardHeight, (long)centerPointYForViewWithKeyboardUp);
        if (self.view.center.y == self->originalViewCenter.y)
        {
            [self.view addGestureRecognizer:closeTextFieldGesture];
            NSLog(@"view.center.y: %f == originalViewCenter.y: %f",self.view.center.y, self->originalViewCenter.y);
            self.view.center = CGPointMake(self.view.center.x,centerPointYForViewWithKeyboardUp);
        }
        NSLog(@"text.center.y: %f | self.view.center.y: %f | emailField %f | offset %f",textField.center.y,self.view.center.y,self->emailField.center.y,(textField.center.y - self->emailField.center.y));
        self.view.center = CGPointMake((self.view.frame.size.width/2.0),centerPointYForViewWithKeyboardUp - (textField.center.y - self->emailField.center.y));
    } completion:^(BOOL finished) {
        NSLog(@"text.center.y: %f | self.view.center.y: %f | emailField.center.y %f",textField.center.y,self.view.center.y,self->emailField.center.y);
    }];
}

-(void)handleTapInMainView:(UITapGestureRecognizer *)sender
{
    NSLog(@"handling tap in main view");
    [self cleanUpAfterEditing];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"should textfield %@ end its editing?",textField.accessibilityLabel);
    if ([self->currentResponder isEditing])
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
    
    [NSTimer scheduledTimerWithTimeInterval:all.duration target:self selector:@selector(callRevertField:) userInfo:@{@"textField":textField,@"animated":@YES} repeats:NO];
}

-(void)callRevertField:(NSTimer *)timer
{
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
    width.toValue = (id)[NSNumber numberWithFloat:self->initialBorderSpecs.cornerRadius];
    corner.fromValue = (id)[NSNumber numberWithFloat:textField.layer.cornerRadius];
    // ... and change the model value
    textField.layer.cornerRadius = self->initialBorderSpecs.cornerRadius;
    
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

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSArray *fieldsToChangeColorOf = [NSArray arrayWithObject:textField];
    NSLog(@"textField %@ ended editing",textField.placeholder);
    CGColorRef borderColor = CGColorCreate(0, 0);
    if ([textField isEqual:self.emailField])
    {
        if ([self isValidEmail:textField.text])
        {
            borderColor = [[UIColor greenColor] CGColor];
        }
        else
        {
            borderColor = [[UIColor redColor] CGColor];
        }
    } else
    {
        if ([self->currentViewState isDescendantOfView:self->signUpView])
        {
            fieldsToChangeColorOf = @[self.passwordField,self.confirmField];
            if (![self.passwordField.text isEqualToString:self.confirmField.text] || textField.text.length < 1)
            {
                borderColor = [[UIColor redColor] CGColor];
            } else
            {
                borderColor = [[UIColor greenColor] CGColor];
            }
        } else if (textField.text.length < 1) {
            borderColor = [[UIColor redColor] CGColor];
        } else
        {
            borderColor = [[UIColor greenColor] CGColor];
        }
    }
    
    for (UITextField *field in fieldsToChangeColorOf) {
        [self fieldToChangeBorderOf:field toColor:borderColor];
    }
}

-(void)cleanUpAfterEditing
{
    
    NSLog(@"cleanup after editing");
    if ([self->currentResponder isFirstResponder])
    {
        [self->currentResponder resignFirstResponder];
    }
    
    self.navigationItem.leftBarButtonItem = self->goBackButton;
    self.navigationItem.rightBarButtonItem = self->submitButton;
    
    if (!CGPointEqualToPoint(self.view.center, originalViewCenter))
    {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.center = self->originalViewCenter;
        } completion:^(BOOL finished) {
            if (finished)
            {
                NSLog(@"keyboard hiding animation done");
                self->currentResponder = nil;
            }
        }];
    }
    
    [self.view removeGestureRecognizer:self->closeTextFieldGesture];
}

-(void)moveToNextTextField
{
    UITextField *textField = self->currentResponder;
    UITextField *nextUp;
    if ([self->currentTextFields indexOfObject:textField] < (self->currentTextFields.count - 1))
    {
        nextUp = [self->currentTextFields objectAtIndex:([self->currentTextFields indexOfObject:self->currentResponder] + 1)];
        NSLog(@"nextUp:%@",nextUp);
    }
    else {
        nextUp = [self->currentTextFields objectAtIndex:0];
    }
    [nextUp becomeFirstResponder];
}

-(void)moveToPreviousTextField
{
    UITextField *textField = self->currentResponder;
    UITextField *nextUp;
    if ([self->currentTextFields indexOfObject:textField] > 0)
    {
        nextUp = [self->currentTextFields objectAtIndex:([self->currentTextFields indexOfObject:self->currentResponder] - 1)];
        NSLog(@"nextUp:%@",nextUp);
    }
    else {
        nextUp = [self->currentTextFields objectAtIndex:([self->currentTextFields count] - 1)];
    }
    [nextUp becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"should return");
    [textField resignFirstResponder];
    [self cleanUpAfterEditing];
    return NO; // disabled, textFields just close
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
    
    if ((self.passwordField.text.length < 1) || (![self isValidEmail:self.emailField.text]))
    {
        self->HUD.mode = MBProgressHUDModeCustomView;
        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
        self->HUD.labelText = @"fill out all fields";
        [self->HUD show:YES];
        [self->HUD hide:YES afterDelay:1.0f];
        
        return NO;
    } else if (![self.passwordField.text isEqualToString:self.confirmField.text])
    {
        self->HUD.mode = MBProgressHUDModeCustomView;
        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
        self->HUD.labelText = @"password and confirm must match";
        [self->HUD show:YES];
        [self->HUD hide:YES afterDelay:1.0f];
        
        return NO;
    } else {
        NSLog(@"user info acceptable for signup");
        return YES;
    }
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
    }
    
        lastLoggedInUserId = [user objectId];
        lastLoggedInFacebookId = [user objectForKey:@"facebookId"];
        lastLoggedInDisplayName = [user objectForKey:@"firstName"];
        lastLoggedInUserName = [user username];
    
    // write to user defaults
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInUserId forKey:@"lastLoggedInUserId"];
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInFacebookId forKey:@"lastLoggedInFacebookId"];
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInDisplayName forKey:@"lastLoggedInDisplayName"];
    [[NSUserDefaults standardUserDefaults] setObject:lastLoggedInUserName forKey:@"lastLoggedInUserName"];
    
    NSLog(@"written to NSUserDefaults for offline/immediate access: lastLoggedInUserId/%@ displayName/%@ userName/%@ lastLoggedInFacebookId/%@",lastLoggedInUserId,lastLoggedInDisplayName,lastLoggedInUserName,lastLoggedInFacebookId);
}

/// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    
    NSLog(@"user %@ (%@) successfully signed up",user.username,user.objectId);
    [self storeUserDataToDefaults:user];
    [self showView:startView];
    
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
    self->HUD.labelText = [error userInfo][@"error"];
    [self->HUD hide:YES afterDelay:1.0f];
    NSLog(@"signing up user failed because error:%@",error);
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
    if ((![self isValidEmail:self.emailField.text]) || (self.passwordField.text.length < 1))
    {
        self->HUD.mode = MBProgressHUDModeCustomView;
        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
        self->HUD.labelText = @"fill out all fields";
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
    __block PFUser * blockUser = user;
    [self storeUserDataToDefaults:blockUser];
        NSLog(@"loginviewController dismissed with successful login, current user: %@",blockUser);
        [self showView:startView];
        
        self->HUD.mode = MBProgressHUDModeCustomView;
        self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        self->HUD.labelText = @"success!";
        [self->HUD hide:YES afterDelay:1.0f];
}

/// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    NSLog(@"error in login: %@",error);
    [self->HUD hide:YES afterDelay:1.0f];
}

/// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self showView:self->startView];
    
}

- (BOOL)updateFbProfileForUser:(PFUser *)user
{
    __block BOOL updated = NO;
    self->HUD.labelText = @"figuring out if we've met before";
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"profile download finished");
        // the profile download finished either successfully or unsuccessfully
        if (error) {
            // there was an error downloading the profile
            NSLog(@"error in retrieving profile, failing out");
            
            // let the user know
            self->HUD.mode = MBProgressHUDModeCustomView;
            self->HUD.labelText = @"%@",[[error userInfo] objectForKey:@"error"];
            self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-mark.png"]];
            [self->HUD hide:YES afterDelay:1.0f];
            
            updated = NO;
        } else {
            NSLog(@"profile retrieved successfully");
            NSLog(@"connection: %@,result: %@, error: %@",connection,result,error);
            
            NSDictionary<FBGraphUser> *userData = result;
            
            if ([[user objectForKey:@"fbProfileChangedAt"] isEqualToString:userData[@"updated_time"]])
            {
                NSLog(@"buried's user info is up to date with facebook");
                updated = NO;
            }
            else
            {
                
                NSLog(@"buried's user info is out of date with facebook");
                NSLog(@"syncing user data with facebook");
                self->HUD.labelText = @"getting to know you better";
                
                [user setObject:userData[@"id"] forKey:@"facebookId"];
                
                [user setObject:userData[@"first_name"] forKey:@"firstName"];
                [user setObject:userData[@"last_name"] forKey:@"lastName"];
                
                [user setObject:[NSString stringWithFormat:@"%@ %@",userData[@"first_name"],userData[@"last_name"]] forKey:@"displayName"];
                
                [user setObject:userData[@"updated_time"] forKey:@"fbProfileChangedAt"];
                
                
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
                        NSLog(@"user %@ installation failed to save with error (%@), they will not be configured to receive pushes",[user objectId],error);
                    } else
                    {
                        NSLog(@"installation data saved for user %@, they can now receive pushes correctly",[user objectId]);
                    }
                }];
                
                NSLog(@"current channels: %@", [currentInstallation channels]);
                
                // save the user's sync'd model locally to the device and to the parse cloud
                [self storeUserDataToDefaults:user];
                
                NSError *__autoreleasing * userSaveFbProfileError = NULL;
                [user save:(NSError *__autoreleasing *)userSaveFbProfileError];
                // if the user fails and is new, ensure we have enough user data to operate correctly
                if (userSaveFbProfileError)
                {
                    NSLog(@"User profile could not be saved");
                }
            }
            // shows success hud
            self->HUD.mode = MBProgressHUDModeCustomView;
            self->HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            self->HUD.labelText = [NSString stringWithFormat:@"hello %@",[[[PFUser currentUser] objectForKey:@"firstName"] lowercaseString]];
            [self->HUD hide:YES afterDelay:1.0f];
            updated = YES;
        }
    }];
    return updated;
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
