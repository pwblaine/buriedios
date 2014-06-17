//
//  LTUnearthedViewController.h
//  buried
//
//  Created by Patrick Blaine on 3/2/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "LTGrassViewController.h"

@interface LTUnearthedViewController : PFQueryTableViewController <NSURLConnectionDelegate, UINavigationControllerDelegate, LTGrassViewControllerDelegate, UITableViewDelegate>
{
    NSMutableData *profileImageData;
    UIImage *smallPortrait;
    UIImage *defaultPortrait;
    BOOL initialLoad;
    BOOL isAtBottom;
    BOOL comingInFromOtherPage;
}

#pragma mark - Capsule tracking UI methods
- (void)updateTitleWithNumberOfBuriedCapsules;

#pragma mark - Capsule presentation methods
- (void)presentCapsule:(NSString *)capsuleId fromSelectedCell:(UITableViewCell *)cell;

#pragma mark - Logout methods

- (void)logoutButtonTouchHandler:(id)sender;
- (void)buryItButtonTouchHandler:(id)sender;

#pragma mark - NSURLConnectionDataDelegate

/* Callback delegate methods used for downloading the user's profile picture */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

-(LTGrassState)defaultGrassStateForView;

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
