//
//  LTUnearthedViewController.h
//  buried
//
//  Created by Patrick Blaine on 3/2/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LTUnearthedViewController : PFQueryTableViewController <NSURLConnectionDelegate, UINavigationControllerDelegate>
{
    NSMutableData *profileImageData;
    UIImage *smallPortrait;
    UIImage *defaultPortrait;
}

#pragma mark - Capsule tracking UI methods
- (void)updateTitleWithNumberOfBuriedCapsules;

#pragma mark - Logout methods

- (void)logoutButtonTouchHandler:(id)sender;
- (void)buryItButtonTouchHandler:(id)sender;

#pragma mark - NSURLConnectionDataDelegate

/* Callback delegate methods used for downloading the user's profile picture */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)updateUserProfile;

@end
