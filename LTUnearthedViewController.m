//
//  LTUnearthedViewController.m
//  buried
//
//  Created by Patrick Blaine on 3/2/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "LTAppDelegate.h"
#import "LTUnearthedViewController.h"
#import "LTBuryItViewController.h"
#import "LTCapsuleViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "UIBarButtonItem+_projectButtons.h"
#import "LTAdminTableViewController.h"

@interface LTUnearthedViewController () {
    LTAdminTableViewController * adminTableVC;
}

@end

@implementation LTUnearthedViewController

@synthesize allItems, HUD;

/* DEFAULT UI VIEW METHOD
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/
/* DEFAULT TABLE VIEW METHOD
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/


- (id)initWithStyle:(UITableViewStyle)style
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self = [super initWithStyle:style];
    if (self)
    {
        self.parseClassName = @"capsule";
        self.textKey = @"deliveryDate";
        self.imageKey = @"image";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self->initialLoad = YES;
        self.tableView.bounces = YES;
        self.tableView.delegate = self;
    }
    return self;
}

- (PFQuery *)queryForTable {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    PFQuery *toUserIdsQuery = [PFQuery queryWithClassName:self.parseClassName];
    
    PFUser *currentUser = [PFUser currentUser];
    
    // If no objects are loaded in memory, we look to the cache
    // first to fill the table and then subsequently do a query
    // against the network.
    if ([self.objects count] == 0) {
        toUserIdsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [toUserIdsQuery whereKey:@"toUserIds" containsAllObjectsInArray:@[currentUser.objectId]];
    
    [toUserIdsQuery whereKey:@"sent" equalTo:@YES];
    
    [toUserIdsQuery orderByDescending:@"deliveryDate"];
    
    return toUserIdsQuery;
}


- (void)viewDidLoad
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Add logout navigation bar button
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonTouchHandler:)];
    [logoutButton setEnabled:NO];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    // Add camera navigation bar button
    UIBarButtonItem *buryItButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(buryItButtonTouchHandler:)];
    [buryItButton setEnabled:NO];
    self.navigationItem.rightBarButtonItem = buryItButton;
    
    // Add the temporary title
    self.title = @"buried.";
    
}


- (void)updateTitleWithNumberOfBuriedCapsules {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    if ([self.navigationController.visibleViewController isMemberOfClass:[LTUnearthedViewController class]])
    {
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *toUserIdsQuery = [PFQuery queryWithClassName:self.parseClassName];
    
    [toUserIdsQuery whereKey:@"toUserIds" containsAllObjectsInArray:@[currentUser.objectId]];
    
    [toUserIdsQuery whereKey:@"sent" notEqualTo:@YES];
    
    [toUserIdsQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        // set title for number of pending capsules (if none, display name, if 1, display Awaits You, display Await You)
        NSLog(@"count for pending capsules: %i", count);
        if (error)
            NSLog(@"updating title received error: %@",error);
        else if (count > 1)
            self.title = [NSString stringWithFormat:@"%i Await You",count];
        else if (count == 1)
            self.title = [NSString stringWithFormat:@"%i Awaits You",count];
        else
            self.title = [NSString stringWithFormat:@"%@",[currentUser objectForKey:@"displayName"]];
        }];
    }

}

-(void)pushToAdminTable
{
    if ([self.navigationController.visibleViewController isMemberOfClass:[LTUnearthedViewController class]])
    {
        
    NSLog(@"admin user detected, changing view");
    self->adminTableVC = [[LTAdminTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self->adminTableVC.admin = [PFUser currentUser];/*
        self->adminTableVC.loadingViewEnabled = NO;
    NSLog(@"self.navigationItem.titleView.gestureRecognizers = %@",self.navigationController.navigationBar.gestureRecognizers);
    for (UITapGestureRecognizer *gesture in self.navigationController.navigationBar.gestureRecognizers)
    {
        NSLog(@"examining gesture %@", gesture);
        if ([gesture respondsToSelector:@selector(pushToAdminTable)])
        {
            NSLog(@"gesture responds to pushToAdminTable selector");
            [[gesture view] removeGestureRecognizer:gesture];
            NSLog(@"removing tap recognizer now that admin menu is being summoned, pushing admin menu...");
        }
    }*/
        [self.navigationController pushViewController:self->adminTableVC animated:YES];
        self->adminTableVC.HUD = self.HUD;
        self->adminTableVC.HUD.delegate = self->adminTableVC;
    }
}

- (void)loadAdmin
{
    
    self.HUD = [[MBProgressHUD alloc] initWithView:[[[UIApplication sharedApplication] windows] firstObject]];
    UIWindow *theWindow = [[[UIApplication sharedApplication] windows] firstObject];
    [theWindow addSubview:self.HUD];
    
    [theWindow bringSubviewToFront:self.HUD];
    
    // Set indeterminate mode
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.delegate = self;
    [self.HUD show:YES];
    [self pushToAdminTable];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (initialLoad)
    {
        initialLoad = NO;
        NSLog(@"initial load");
        
        PFUser *currentUser = [PFUser currentUser];
        NSLog(@"admin: %@",[currentUser objectForKey:@"admin"]);
        BOOL isAdmin = [[currentUser objectForKey:@"admin"] isEqualToString:@"ADMIN"];
        NSLog(@"regular user %@ with admin status of %i",currentUser,isAdmin);
        if (isAdmin)
        {
            if ([self.navigationController.visibleViewController isMemberOfClass:[LTUnearthedViewController class]])
            {
            NSLog(@"gestureRecognizers on title: %lu",(unsigned long)[self.navigationItem.titleView.gestureRecognizers count]);
            if ([self.navigationItem.titleView.gestureRecognizers count] == 0)
            {
                NSLog(@"attaching admin summon to titleview");
            UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToAdminTable)];
            [titleTap setNumberOfTapsRequired:2]; // 2 taps on the menu bar sends it to admin view
            [self.navigationController.navigationBar addGestureRecognizer:titleTap];
                }
            }
        }
    }
    else
    {
        [self loadObjects];
        NSLog(@"loading objects");
        [self updateTitleWithNumberOfBuriedCapsules];
    }
    
    
    // if user is looking at the full capsule view, they've been notified of everything already, clear the badges
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if (currentInstallation.badge > 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
        NSLog(@"removing all badges.  badges: %d",(int)currentInstallation.badge);
    }
    
    LTAppDelegate *appDelegate = (LTAppDelegate *)[UIApplication sharedApplication].delegate;
    [[appDelegate grassDelegate] setGrassState:[self defaultGrassStateForView] animated:YES];
}

#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)objectsDidLoad:(NSError *)error {
    
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self updateTitleWithNumberOfBuriedCapsules];
}

/*
 // Override to customize what kind of query to perform on the class. The default is to query for
 // all objects ordered by createdAt descending.
 - (PFQuery *)queryForTable {
 PFQuery *query = [PFQuery queryWithClassName:self.className];
 
 // If Pull To Refresh is enabled, query against the network by default.
 if (self.pullToRefreshEnabled) {
 query.cachePolicy = kPFCachePolicyNetworkOnly;
 }
 
 // If no objects are loaded in memory, we look to the cache first to fill the table
 // and then subsequently do a query against the network.
 if (self.objects.count == 0) {
 query.cachePolicy = kPFCachePolicyCacheThenNetwork;
 }
 
 [query orderByDescending:@"createdAt"];
 
 return query;
 }
 */
        


 // Override to customize the look of a cell representing an object. The default is to display
 // a UITableViewCellStyleDefault style cell with the label being the textKey in the object,
 // and the imageView being the imageKey in the object.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
     
 static NSString *CellIdentifier = @"Cell";
 
 PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 if (cell == nil) {
 cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
 }
 
     // Configure the cell
     
     PFUser *currentUser = [PFUser currentUser];
     
     // Set left label to timestamp
     NSString *timestampString = [NSDateFormatter localizedStringFromDate:[object objectForKey:self.textKey] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
     if (![cell.textLabel.text isEqualToString:timestampString])
     cell.textLabel.text = timestampString;
     
     // If sent to self set label to blue
     if ([[object objectForKey:@"fromUserId"] isEqualToString:currentUser.objectId])
     {
         if (![cell.textLabel.textColor isEqual:[UIColor blueColor]])
         cell.textLabel.textColor = [UIColor blueColor];
     } else {
         if (![cell.textLabel.textColor isEqual:[UIColor colorWithRed:25/255.0f green:96/255.0f blue:36/255.0f alpha:1.0f]])
         cell.textLabel.textColor = [UIColor colorWithRed:25/255.0f green:96/255.0f blue:36/255.0f alpha:1.0f];
     }
    
     if (cell.textLabel.textAlignment != NSTextAlignmentLeft)
         cell.textLabel.textAlignment = NSTextAlignmentLeft;
     
     NSString *thought = [object objectForKey:@"thought"];
     
     if (thought.length > 1)
     {
         if (![cell.detailTextLabel.text isEqualToString:thought])
         cell.detailTextLabel.text = thought;
         if (cell.detailTextLabel.textColor != [UIColor blackColor])
         cell.detailTextLabel.textColor = [UIColor blackColor];
     }
     else
     {
         NSString *picturePlaceholderString = @"Picture";
         if (![cell.detailTextLabel.text isEqualToString:picturePlaceholderString])
         cell.detailTextLabel.text = picturePlaceholderString;
         if (cell.detailTextLabel.textColor != [UIColor lightGrayColor])
         cell.detailTextLabel.textColor = [UIColor lightGrayColor];
     }
    
     // Unread code: if current user isn't found in the readUsers tint brown.
     
     NSArray *readUserIds = [object objectForKey:@"readUserIds"];
     
     BOOL userHasRead = NO;
     
     if ([readUserIds count] > 0)
     {
     for (NSString *userId in readUserIds) {
         
         if ([userId isEqualToString:[currentUser objectId]]) {
             userHasRead = YES;
             break;
         }
         
        }
     }
     if (!userHasRead)
     {
         cell.detailTextLabel.text = [NSString stringWithFormat:@"• %@",cell.detailTextLabel.text];
         cell.detailTextLabel.textColor = [UIColor brownColor];
     }

     
 return cell;
 }

/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
 return [self.objects objectAtIndex:indexPath.row];
 }
 */

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - UITableViewDataSource

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the object from Parse and reload the table view
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, and save it to Parse
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - UITableViewDelegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}
*/
// OLD METHODS

/*
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

*/
#pragma mark - NSURLConnectionDataDelegate

// Callback delegate methods used for downloading the user's profile picture

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    // As chuncks of the image are received, we build our data file
    [profileImageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    // All data has been downloaded, now we can set the image in the header image view
    
    NSLog(@"profile picture downloaded");
    
    if (profileImageData.length == 0) {
        NSLog(@"profile picture blank");
        return;
    }
    
    // The user's Facebook profile picture is cached to disk. Check if the cached profile picture data matches the incoming profile picture. If it does, avoid uploading this data to Parse.
    
    UIImage *image = [UIImage imageWithData:profileImageData];
    
    UIImage *mediumRoundedImage = [image thumbnailImage:180 transparentBorder:0 cornerRadius:20 interpolationQuality:kCGInterpolationDefault];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:8 interpolationQuality:kCGInterpolationDefault];
    
    NSData *mediumRoundedImageData = UIImagePNGRepresentation(mediumRoundedImage);
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    if (mediumRoundedImageData.length > 0) {
        PFFile *fileMediumRoundedImage = [PFFile fileWithData:mediumRoundedImageData];
        [fileMediumRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileMediumRoundedImage forKey:@"profilePictureMedium"];
                [[PFUser currentUser] saveEventually];
                NSLog(@"profile picture stored in medium size");
                [[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]imageView ] setImage:mediumRoundedImage];
            }
        }];
    }
    
    if (smallRoundedImageData.length > 0) {
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:@"profilePictureSmall"];
                [[PFUser currentUser] saveEventually];
                NSLog(@"profile picture stored in small size");
            }
        }];
        
    }
}


#pragma mark Logout methods

- (void)logoutButtonTouchHandler:(id)sender {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSLog(@"logging out");
    
    // clear any badges
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge > 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
        NSLog(@"clearing badges for user.  badges: %d",(int)currentInstallation.badge);
    }
    
    // remove user from device channels
    NSMutableArray *mutableChannels = [[[PFInstallation currentInstallation] channels] mutableCopy];
    NSString *userObjectId = [[PFUser currentUser] objectId];
    [mutableChannels removeObject:userObjectId];
    NSLog(@"removing user from push channels");
    [[PFInstallation currentInstallation] setChannels:[NSArray arrayWithArray:mutableChannels]];
    NSLog(@"storing userId as last logged in...");
    [[PFInstallation currentInstallation] setObject:userObjectId forKey:@"lastLoggedInUserId"];
    NSLog(@"saving updated installation data to Parse...");
    [currentInstallation saveEventually];
    NSLog(@"active channels for push: %@",mutableChannels);

    // write to user defaults
    NSString *displayName = [[PFUser currentUser] objectForKey:@"displayName"];
    if (![displayName isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"displayName"]])
    {
        [[NSUserDefaults standardUserDefaults] setObject:displayName forKey:@"displayName"];
     NSLog(@"written to NSUserDefaults for offline/immediate access: displayName/%@",displayName);
    }
    
    
    [FBSession setActiveSession:nil];
    [PFUser logOut];
    NSLog(@"user %@ successfully logged out", userObjectId);
    
    
    
    // Return to login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)buryItButtonTouchHandler:(id)sender {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self.navigationController pushViewController:[[LTBuryItViewController alloc] init] animated:YES];
    
}
/*
#pragma mark - Parse Methods

- (void)populateTable {
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    return cell;
}
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Table view cell select

- (void)presentCapsule:(NSString *)capsuleId fromSelectedCell:(UITableViewCell *)cell
{
    // Create the next view controller.
    LTCapsuleViewController *capsuleViewController = [[LTCapsuleViewController alloc] init];
    
    // Pass the selected object to the new view controller and add user to the readUsers array.
    
    PFObject *capsule = [PFQuery getObjectOfClass:@"capsule" objectId:capsuleId];
    capsuleViewController.capsule = capsule;
    
    BOOL hasRead = false;
    
    PFUser *currentUser = [PFUser currentUser];
    
    for (NSString *userId in (NSArray *)[capsule objectForKey:@"readUserIds"])
    {
        
        NSLog(@"comparing %@ to %@ in readUsers",userId,[currentUser objectId]);
        if ([userId isEqualToString:[currentUser objectId]])
        {
            hasRead = true;
            NSLog(@"user found!");
        }
    }
    
    if (!hasRead)
    {
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = [capsule objectForKey:@"thought"];
        
        NSLog(@"user hasn't read capsule yet, adding to readUsers.");
        [capsule addUniqueObject:[currentUser objectId] forKey:@"readUserIds"];
        NSLog(@"readUser count: %d",(int)[(NSArray *)[capsule objectForKey:@"readUserIds"] count]);
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        if (currentInstallation.badge > 0) {
            currentInstallation.badge--;
            [currentInstallation saveEventually];
            NSLog(@"decrementing badge number.  badges: %d",(int)currentInstallation.badge);
        }
        
        [capsule saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded)
                NSLog(@"capsule %@ has been saved",[currentUser objectId]);
        }];
    }
    
    NSLog(@"%@",capsule);
    
    // Push the view controller
    [self.navigationController pushViewController:capsuleViewController animated:YES];
}

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
     NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
     [self presentCapsule:[[self objectAtIndexPath:indexPath] objectId] fromSelectedCell:[self.tableView cellForRowAtIndexPath:indexPath]];
 }

- (LTGrassState)defaultGrassStateForView
{
    return LTGrassStateShrunk;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    LTGrassViewController *grassDelegate =  [LTGrassViewController delegate];
    
    if (([[[self.objects lastObject] objectId] isEqualToString:[[self objectAtIndexPath:indexPath] objectId]]) && ([grassDelegate grassState] == self.defaultGrassStateForView))
    {
            NSLog(@"match found for last capsule");
            [grassDelegate setGrassState:LTGrassStateHidden animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    LTGrassViewController *grassDelegate =  [LTGrassViewController delegate];
    
    if ((self.defaultGrassStateForView != [grassDelegate grassState]))
    {
        if ([[[self.objects lastObject] objectId] isEqualToString:[[self objectAtIndexPath:indexPath] objectId]])
        {
            NSLog(@"match found for not last capsule");
            [grassDelegate setGrassState:self.defaultGrassStateForView animated:YES];
        }
    }
}


@end
