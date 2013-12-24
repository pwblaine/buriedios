//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "LTLoginViewController.h"
#import "LTBuryItViewController.h"
#import <Parse/Parse.h>

@implementation LTLoginViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    
    // Check if user is cached and linked to Facebook, if so, bypass login    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self.navigationController pushViewController:[[LTBuryItViewController alloc] init] animated:NO];
    }
    
    // Add logout navigation bar button
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Log In" style:UIBarButtonItemStyleBordered target:self action:@selector(loginButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = loginButton;
}


#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
        
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                /* REMOVED decided against user cancel error message
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
                 */
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self.navigationController pushViewController:[[LTBuryItViewController alloc] init] animated:YES];
        } else {
            NSLog(@"User with facebook logged in!");
            [self.navigationController pushViewController:[[LTBuryItViewController alloc] init] animated:YES];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}


@end
