//
//  LTAdminTableViewController.m
//  buried
//
//  Created by Patrick Blaine on 7/15/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "LTAdminTableViewController.h"

@interface LTAdminTableViewController ()

@end

@implementation LTAdminTableViewController

@synthesize admin, users;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.users = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loadingViewEnabled = NO;
}

- (PFQuery *)queryForTable
{
    //PFQuery *allCapsules = [PFQuery queryWithClassName:@"capsule"];
    
    PFQuery *allUsersQuery = [PFUser query];
    
    [allUsersQuery whereKey:@"displayName" notContainedIn:@[@"",[NSNull null]]];
    
    //NSMutableArray *latestCapsuleIds = [NSMutableArray array];
    
    //PFQuery *resultingQuery = [PFQuery queryWithClassName:@"capsule"];
    
    /* [allUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     
     if (error || (objects.count < 1)) {
     
     NSLog(@"error: %@", error);
     
     } else {
     
     self.users = [NSMutableArray arrayWithArray:objects];
     }
     
     }]; */
    
    return allUsersQuery;
    
    /*
     
     NSLog(@"allUsers : %@",[objects mutableArrayValueForKey:@"objectId"]);
     
     [allCapsules orderByDescending:self.textKey];
     
     for (PFUser *user in objects)
     {
     [allCapsules whereKey:@"fromUserId" containsString:user.objectId];
     
     PFObject *capsule = [allCapsules getFirstObject];
     
     if (capsule) {
     NSLog(@"error: %@",error);
     } else {
     
     NSLog(@"capsule: %@",capsule);
     
     [latestCapsuleIds addObject:capsule.objectId];
     
     NSLog(@"adding latest capsule %@, for user %@",capsule.objectId, user.objectId);
     }
     };
     }
     
     NSLog(@"latestCapsules: %@",latestCapsuleIds);
     
     [queryForTableCapsules whereKey:@"objectId" containedIn:latestCapsuleIds];
     [queryForTableCapsules orderByDescending:@"updatedAt"];
     
     userCount = [userCount initWithUnsignedInteger:objects.count];
     }];*/
    /*
     NSLog(@"comparing [latestCapsuleIds count] == [userCount unsignedIntValue] || %lu ~ %u",(unsigned long)[latestCapsuleIds count],[userCount unsignedIntValue]);
     
     if ([latestCapsuleIds count] == [userCount unsignedIntValue])
     {
     NSLog(@"both are equal, the block has computed");
     return queryForTableCapsules;
     } else {
     NSLog(@"looping around again, the block hasn't finished executing");
     return [self queryForTable];
     }*/
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.navigationController action:@selector(popViewControllerAnimated:)];
    self.navigationItem.title = @"Admin Menu";
    [self.navigationItem setRightBarButtonItems:[NSArray array] animated:YES];
    
    
}

-(void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *CellIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    NSString *nameToDisplay = [object objectForKey:@"displayName"];
    if (!nameToDisplay)
    {
        nameToDisplay = [object objectForKey:@"username"];
    }
    NSLog(@"name to display: %@",nameToDisplay);
    cell.textLabel.text = [NSString stringWithFormat:@"%@",nameToDisplay];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    self.HUD = [[MBProgressHUD alloc] initWithView:[[[UIApplication sharedApplication] windows] firstObject]];
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self.HUD];
    
    // Set indeterminate mode
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.delegate = self;
    self.HUD.labelText = @"sending...";
    [self.HUD show:YES];
    
    __block PFUser *userInFocus = (PFUser *)[self objectAtIndexPath:indexPath];
    __block PFQuery *capsuleQuery = [PFQuery queryWithClassName:@"capsule"];
    [capsuleQuery orderByDescending:@"deliveryDate"];
    [capsuleQuery whereKey:@"fromUserId" containsString:userInFocus.objectId];
    [capsuleQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"the capsules failed to load");
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [object setObject:[NSDate date] forKey:@"deliveryDate"];
            [object setObject:@NO forKey:@"sent"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error)
                {
                    NSLog(@"the capsule failed to save");
                }
                else if (succeeded)
                {
                    NSLog(@"Success! : %@",[PFCloud callFunction:@"unearthReadyCapsulesAndPushNotify" withParameters:[NSDictionary dictionary]]);
                } else
                {
                    NSLog(@"the capsule failed to save");
                }
                [tableView setUserInteractionEnabled:YES];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                self.HUD.mode = MBProgressHUDModeCustomView;
                self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                self.HUD.labelText = @"success!";
                [self.HUD removeFromSuperViewOnHide];
                [self.HUD hide:YES afterDelay:1.0f];
                
                /*
                
                self.HUD = [[MBProgressHUD alloc] initWithView:[[[UIApplication sharedApplication] windows] firstObject]];
                [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self.HUD];
                
                // Set indeterminate mode
                self.HUD.mode = MBProgressHUDModeIndeterminate;
                self.HUD.delegate = self;
                self.HUD.labelText = @"updating...";
                [self.HUD show:YES];
                
                self.latestCapsules = [NSArray array];
                
                for (PFUser *userInFocus in self.users) {
                    PFQuery *capsuleQuery = [PFQuery queryWithClassName:@"capsule"];
                    [capsuleQuery whereKey:@"fromUserId" containsString:userInFocus.objectId];
                    [capsuleQuery orderByDescending:@"deliveryDate"];
                    [capsuleQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if (error)
                        {
                            NSLog(@"unable to retrieve capsule data");
                        } else {
                            self.latestCapsules = [self.latestCapsules arrayByAddingObject:object];
                        }
                        self.HUD.mode = MBProgressHUDModeCustomView;
                        self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                        self.HUD.labelText = @"updated!";
                        [self.HUD removeFromSuperViewOnHide];
                        [self.HUD hide:YES afterDelay:1.0f];
                    }];
                }*/
            }];
            
        }
    }];
}


- (void)updateTitleWithNumberOfBuriedCapsules {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
}


#pragma mark LTGrassMethods

-(LTGrassState)defaultGrassStateForView
{
    return LTGrassStateHidden;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // intentionally left blank
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // intentionally left blank
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
