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

@synthesize admin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (PFQuery *)queryForTable
{
    PFQuery *oneCapsulePerUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [oneCapsulePerUserQuery orderByDescending:self.textKey];
    NSMutableOrderedSet *uniqueFromIdCapsuleSet = [oneCapsulePerUserQuery mutableOrderedSetValueForKey:@"fromUserId"];
    [oneCapsulePerUserQuery whereKey:@"fromUserId" containedIn:[uniqueFromIdCapsuleSet array]];
    return oneCapsulePerUserQuery;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.navigationController action:@selector(popViewControllerAnimated:)];
    self.navigationItem.title = @"Admin Menu";
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
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    NSString *nameToDisplay = [object objectForKey:@"displayName"];
    if ([nameToDisplay isEqualToString:@""])
    {
        nameToDisplay = [(PFUser *)object username];
    }

    cell.textLabel.text = nameToDisplay;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",object.createdAt];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    PFObject *capsule = [PFObject objectWithClassName:@"capsule"];
    capsule = [self objectAtIndexPath:indexPath];
    [capsule setObject:[NSDate date] forKey:@"deliveryDate"];
    [capsule setObject:false forKey:@"sent"];
    [capsule saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"capsule set to deliver now sucesssfully from user : %@",[capsule objectForKey:@"fromUserId"]);
            NSLog(@"running unearthAndSendPushesForAllReadyCapsules for users : %@",[capsule objectForKey:@"toUserIds"]);
            [PFCloud callFunction:@"unearthAndSendPushesForAllReadyCapsules" withParameters:@{}];
            self.navigationItem.title = @"Success!";
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self.navigationItem selector:@selector(setTitle:) userInfo:@"Admin Menu" repeats:NO];
        }
    }];
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
