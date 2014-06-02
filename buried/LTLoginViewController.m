//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "LTLoginViewController.h"
#import "LTUnearthedViewController.h"
#import <Parse/Parse.h>
#import "LTAppDelegate.h"

@implementation LTLoginViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [super viewDidLoad];
    self.title = @"";
    
    // Check if user is cached and linked to Facebook, if so, bypass login    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self.navigationController pushViewController:[[LTUnearthedViewController alloc] initWithStyle:UITableViewStylePlain] animated:NO];
    }
    
    // Add logout navigation bar button
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Log In" style:UIBarButtonItemStyleBordered target:self action:@selector(loginButtonTouchHandler:)];
    self.navigationItem.rightBarButtonItem = loginButton;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self->lastLoggedInLabel.text = @"";
}

-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self.navigationItem.rightBarButtonItem.enabled = true;
    
    // if installation data found, retrieve all fields simultaneously testing for network connection
    [[PFInstallation currentInstallation] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error)
            NSLog(@"unable to fetch current installation");
        else {
            // if connection is successful, welcome last logged in user and update label
        NSString *lastLoggedInUserId = [[PFInstallation currentInstallation] objectForKey:@"lastLoggedInUserId"];
        PFQuery *userQuery = [PFUser query];
        NSString *displayName = [[userQuery getObjectWithId:lastLoggedInUserId] objectForKey:@"displayName"];
        NSLog(@"display name of last logged in user is %@",displayName);
        if (displayName.length > 0)
            self->lastLoggedInLabel.text = [NSString stringWithFormat:@"Welcome, %@",displayName];
        }
    }];
    
    if ((UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) && (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES))
    {
        // configure view for iPhone 5
        [UIView animateWithDuration:1.5f animations:^{
            self->grassImage.frame = CGRectMake(-30, 459.0f, 380, 204);
            self->grassImage.contentMode = UIViewContentModeScaleAspectFill;
        }];
    } else if ((UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) && (([[UIScreen mainScreen] bounds].size.height-480)?NO:YES)) {
        // configure view for iPhone 4
        [UIView animateWithDuration:1.5f animations:^{
            self->grassImage.frame = CGRectMake(-30, 374.0f, 380, 204);
            self->grassImage.contentMode = UIViewContentModeScaleAspectFill;
        }];
    }
    
}

-(void) viewDidDisappear:(BOOL)animated {
        NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
        self->grassImage.frame = CGRectMake(0, 568.0f, 320, 144);
        self->grassImage.contentMode = UIViewContentModeScaleAspectFit;
}


#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSLog(@"logging in");
    [(UIBarButtonItem*)sender setEnabled:NO];
    
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"email"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        // Send request to Facebook
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            // handle response
            if (!error) {
                // Parse the data received
                NSDictionary<FBGraphUser> *userData = (NSDictionary<FBGraphUser> *)result;
                // TODO updateProfile
                
                if (![[PFUser currentUser][@"profile"] isEqual:userData[@"profile"]])
                {
                
                    [[PFUser currentUser] setObject:userData forKey:@"profile"];
                
                // update facebook username, email, facebook profile, display name, facebook id and download profile pictures
                
                [[PFUser currentUser] setObject:userData[@"name"] forKey:@"displayName"];
                [[PFUser currentUser] setObject:userData[@"username"] forKey:@"facebookUsername"];
                [[PFUser currentUser] setObject:userData[@"id"] forKey:@"facebookId"];
                
                }
                
                if (![[[PFUser currentUser] username] isEqualToString:userData[@"username"]])
                {
                    [[PFUser currentUser] setUsername:userData[@"id"]];
                    [[PFUser currentUser] setPassword:@""];
                }
                if (![[[PFUser currentUser] email] isEqualToString:userData[@"email"]])
                    {
                        [[PFUser currentUser] setEmail:userData[@"email"]];
                        NSLog(@"adding/updating email and username");
                    }
                
                
                [[PFUser currentUser] saveEventually];
            }
        }];

        
        if (!user) {
            [(UIBarButtonItem*)sender setEnabled:YES];
            if (!error) {
                NSLog(@"uh oh. The user cancelled the Facebook login.");
                self.navigationItem.rightBarButtonItem.enabled = YES;
            } else {
                NSLog(@"uh oh. An error occurred: %@", error);
                self.navigationItem.rightBarButtonItem.enabled = YES;
                [PFUser logInWithUsername:user[@"facebookId"] password:nil];
            }
        } else if (user.isNew) {
            NSLog(@"user with facebook signed up and logged in!");
            [self.navigationController pushViewController:[[LTUnearthedViewController alloc] initWithStyle:UITableViewStylePlain] animated:NO];
        } else {
            NSLog(@"user with facebook logged in!");
            [self.navigationController pushViewController:[[LTUnearthedViewController alloc] initWithStyle:UITableViewStylePlain] animated:NO];
        }
    }];
}

@end
