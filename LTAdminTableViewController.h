//
//  LTAdminTableViewController.h
//  buried
//
//  Created by Patrick Blaine on 7/15/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import <Parse/Parse.h>
#import "LTUnearthedViewController.h"
#import "MBProgressHUD.h"

@interface LTAdminTableViewController : LTUnearthedViewController
{
    
}

-(void)objectsDidLoad:(NSError *)error;

@property PFUser *admin;

@property __block NSMutableArray *users;

@property __block NSArray *latestCapsules;

@property BOOL loadingViewEnabled;

@end
