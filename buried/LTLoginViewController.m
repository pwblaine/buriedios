//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "LTLoginViewController.h"
#import "LTUnearthedViewController.h"
#import <Parse/Parse.h>

@implementation LTLoginViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    
    // Check if user is cached and linked to Facebook, if so, bypass login    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self.navigationController pushViewController:[[LTUnearthedViewController alloc] init] animated:NO];
    }
    
    // Add logout navigation bar button
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Log In" style:UIBarButtonItemStyleBordered target:self action:@selector(loginButtonTouchHandler:)];
    self.navigationItem.rightBarButtonItem = loginButton;
}


#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"email"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"user with facebook signed up and logged in!");
            [self.navigationController pushViewController:[[LTUnearthedViewController alloc] init] animated:YES];
        } else {
            NSLog(@"user with facebook logged in!");
            [self.navigationController pushViewController:[[LTUnearthedViewController alloc] init] animated:YES];
        }
    }];
}

@end
