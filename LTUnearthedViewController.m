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

@interface LTUnearthedViewController ()

@end

@implementation LTUnearthedViewController

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
    self = [super initWithStyle:style];
    if (self)
    {
        self.parseClassName = @"capsule";
        self.textKey = @"deliveryDate";
        self.imageKey = @"image";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
    }
    return self;
}

- (PFQuery *)queryForTable {
    PFQuery *emailQuery = [PFQuery queryWithClassName:self.parseClassName];
    
    PFUser *currentUser = [PFUser currentUser];
    
    [currentUser fetchIfNeeded];
    
    // If no objects are loaded in memory, we look to the cache
    // first to fill the table and then subsequently do a query
    // against the network.
    if ([self.objects count] == 0) {
        emailQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    PFQuery *fbQuery = [PFQuery queryWithClassName:self.parseClassName];
    
    [fbQuery whereKey:@"email" containsString:[[currentUser objectForKey:@"facebookUsername"] stringByAppendingString:@"@facebook.com"]];
    
    [emailQuery whereKey:@"email" containsString:[currentUser email]];
    
    PFQuery *compundQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:fbQuery, emailQuery, nil]];
    
    [compundQuery includeKey:@"fromUser"];
    
    [compundQuery whereKey:@"sent" equalTo:@YES];
    
    [compundQuery orderByDescending:@"deliveryDate"];
    
    return compundQuery;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Add logout navigation bar button
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    // Add camera navigation bar button
    UIBarButtonItem *buryItButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(buryItButtonTouchHandler:)];
    self.navigationItem.rightBarButtonItem = buryItButton;
    
    // Add the temporary title
    self.title = @"buried.";
    
    [self updateUserProfile];
    
    
    // Update installation with current user info, create a channel for push directly to user by id, save the information to a Parse installation.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    // double check global is registered
    [currentInstallation addUniqueObject:@"global" forKey:@"channels"];
    
    // Register for user specific channels
    [[PFUser currentUser] fetchIfNeeded];
    
    // if there are existing channels overwrite them
    if (currentInstallation.channels.count > 1)
    currentInstallation.channels = @[@"global"];
    
    [currentInstallation addUniqueObject:[[PFUser currentUser] objectId] forKey:@"channels"];
    
    [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    
    [currentInstallation saveInBackground];
    
    NSLog(@"current channels: %@", [currentInstallation channels]);
    
}

- (void)viewDidAppear:(BOOL)animated {
    PFQuery *emailQuery = [PFQuery queryWithClassName:self.parseClassName];
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser fetchIfNeeded];
    
    // If no objects are loaded in memory, we look to the cache
    // first to fill the table and then subsequently do a query
    // against the network.
    if ([self.objects count] == 0) {
        emailQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    PFQuery *fbQuery = [PFQuery queryWithClassName:self.parseClassName];
    
    [fbQuery whereKey:@"email" containsString:[[currentUser objectForKey:@"facebookUsername"] stringByAppendingString:@"@facebook.com"]];
    
    // [fbQuery whereKey:@"sent" equalTo:@YES];
    
    [emailQuery whereKey:@"email" containsString:[currentUser email]];
    
    PFQuery *compundQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:fbQuery, emailQuery, nil]];
    
    [compundQuery whereKey:@"sent" notEqualTo:@YES];
    
    // set title for number of pending capsules (if none, display name, if 1, display Awaits You, display Await You)
    if (compundQuery.countObjects > 1)
        self.title = [NSString stringWithFormat:@"%lg Await You",(double)compundQuery.countObjects];
    else if (compundQuery.countObjects == 1)
        self.title = [NSString stringWithFormat:@"%lg Awaits You",(double)compundQuery.countObjects];
    else
        self.title = [NSString stringWithFormat:@"%@",[currentUser objectForKey:@"displayName"]];
    
    [self.tableView reloadData];
}

#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
    LTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [appDelegate showGrass:NO];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
    LTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [appDelegate showGrass:YES];
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
     
     [currentUser fetchIfNeeded];
     
     // Set left label to timestamp
     cell.textLabel.text = [NSDateFormatter localizedStringFromDate:[object objectForKey:self.textKey] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
     
     // If sent to self set label to blue
     if ([[object objectForKey:@"from"] isEqualToString:[currentUser email]] || [[[object objectForKey:@"fromUser"] objectId] isEqualToString:[currentUser objectId]])
     {
         cell.textLabel.textColor = [UIColor blueColor];
     } else {
         cell.textLabel.textColor = [UIColor colorWithRed:25/255.0f green:96/255.0f blue:36/255.0f alpha:1.0f];
     }
     cell.textLabel.textAlignment = NSTextAlignmentLeft;
     NSString *thought = [object objectForKey:@"thought"];
     
     if (cell.detailTextLabel.textColor != [UIColor blackColor])
         cell.detailTextLabel.textColor = [UIColor blackColor];
     
     if (thought.length > 1)
         cell.detailTextLabel.text = thought;
     else
     {
         cell.detailTextLabel.text = @"Picture";
         cell.detailTextLabel.textColor = [UIColor blackColor];
         
     }
    
     // Unread code: if current user isn't found in the readUsers tint brown.
     
     NSArray *readUsers = [object objectForKey:@"readUsers"];
     
     BOOL userHasRead = NO;
     
     if ([readUsers count] > 0)
     {
     for (PFUser *user in readUsers) {
         
         [user fetchIfNeeded];
         
         if ([[user objectId] isEqualToString:[currentUser objectId]]) {
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
    // As chuncks of the image are received, we build our data file
    [profileImageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
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

- (void)updateUserProfile
{
    // disable navigation and wait for response from server
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            
            NSLog(@"user %@ logged in with email: %@",[PFUser currentUser].username,[[PFUser currentUser] email]);
            // Parse the data received
            NSDictionary<FBGraphUser> *userData = (NSDictionary<FBGraphUser> *)result;
            
            if (![[PFUser currentUser][@"profile"] isEqual:userData] || ![PFUser currentUser].email || ![[PFUser currentUser][@"email"] isEqualToString:userData[@"email"]])
            {

            // TODO updateProfile
            [[PFUser currentUser] setObject:userData forKey:@"profile"];
            
            // update facebook username, email, facebook profile, display name, facebook id and download profile pictures
            [[PFUser currentUser] setObject:userData[@"name"] forKey:@"displayName"];
            [[PFUser currentUser] setObject:userData[@"username"] forKey:@"facebookUsername"];
                
            NSLog(@"new profile data found\nupdating profile data...\n%@",userData);
                
                if (![PFUser currentUser].email || ![[PFUser currentUser][@"email"] isEqualToString:userData[@"email"]])
                {
                    [[PFUser currentUser] setObject:userData[@"email"] forKey:@"email"];
                    NSLog(@"adding/updating email");
                }
                
                [[PFUser currentUser] saveInBackground];
                
            } else {NSLog(@"user profile is up to date");}
            /*
            // Download the user's facebook profile picture
            profileImageData = [[NSMutableData alloc] init]; // the data will be loaded in here
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userData[@"id"]]];
            NSLog(@"profile picture URL created");
            
            NSMutableURLRequest*urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                  timeoutInterval:2.0f];
            // Run network request asynchronously
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            
            NSLog(@"profile picture download initiated");
            if (!urlConnection) {
                NSLog(@"failed to download picture");
            }
             */
            // renable navigation upon receipt of server response
            self.navigationItem.leftBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
            // self.title = [[PFUser currentUser] objectForKey:@"displayName"];
        } else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"the facebook session was invalidated");
            [self logoutButtonTouchHandler:nil];
        } else {
            NSLog(@"some other error: %@", error);
            // renable navigation upon receipt of server response
            self.navigationItem.leftBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }];
}



#pragma mark Logout methods

- (void)logoutButtonTouchHandler:(id)sender {
    
    NSLog(@"logging out");
    [FBSession setActiveSession:nil];
    [PFUser logOut];
    // Return to login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)buryItButtonTouchHandler:(id)sender {
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


#pragma mark - Table view UIImage *theImage;


 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
     
 // Navigation logic may go here, for example:
 // Create the next view controller.
 LTCapsuleViewController *capsuleViewController = [[LTCapsuleViewController alloc] init];
 
 // Pass the selected object to the new view controller and add user to the readUsers array.
     
     PFObject *capsule = [self.objects objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
     capsuleViewController.capsule = capsule;
     
     BOOL hasRead = false;
     
     PFUser *currentUser = [PFUser currentUser];
     
     [currentUser fetchIfNeeded];
     
     for (PFUser *user in (NSArray *)[capsule objectForKey:@"readUsers"])
     {
         [user fetchIfNeeded];
         
         NSLog(@"comparing %@ to %@ in readUsers",[user objectId],[currentUser objectId]);
         if ([[user objectId] isEqualToString:[currentUser objectId]])
         {
             hasRead = true;
             NSLog(@"user found!");
         }
     }
     
     if (!hasRead)
     {
         NSLog(@"user hasn't read capsule yet, adding to readUsers.");
         [capsule addUniqueObject:[PFUser currentUser] forKey:@"readUsers"];
         NSLog(@"readUser count: %d",(int)[(NSArray *)[capsule objectForKey:@"readUsers"] count]);
         
         PFInstallation *currentInstallation = [PFInstallation currentInstallation];
         if (currentInstallation.badge > 0) {
             currentInstallation.badge--;
             [currentInstallation saveEventually];
             NSLog(@"decrementing badge number.  badges: %d",(int)currentInstallation.badge);
         }
         
     [capsule save];
     }
     
     NSLog(@"%@",capsule);
 
     // Push the view controller.
     [self.navigationController pushViewController:capsuleViewController animated:YES];

 }


@end
