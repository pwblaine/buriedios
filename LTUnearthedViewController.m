//
//  LTUnearthedViewController.m
//  buried
//
//  Created by Patrick Blaine on 3/2/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "LTUnearthedViewController.h"
#import <Parse/Parse.h>
#import "UIImage+ResizeAdditions.h"
#import "UIBarButtonItem+_projectButtons.h"

@interface LTUnearthedViewController ()

@end

@implementation LTUnearthedViewController

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
    // Do any additional setup after loading the view from its nib.
    
    
    
    [self updateUserProfile];
    
    NSLog(@"user %@ logged in with email: %@",[PFUser currentUser].username,[[PFUser currentUser] email]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - NSURLConnectionDataDelegate

/* Callback delegate methods used for downloading the user's profile picture */

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
    
    UIImage *mediumRoundedImage = [image thumbnailImage:180 transparentBorder:0 cornerRadius:9 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:9 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumRoundedImageData = UIImagePNGRepresentation(mediumRoundedImage);
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    if (mediumRoundedImageData.length > 0) {
        PFFile *fileMediumRoundedImage = [PFFile fileWithData:mediumRoundedImageData];
        [fileMediumRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileMediumRoundedImage forKey:@"profilePictureMedium"];
                [[PFUser currentUser] saveEventually];
                NSLog(@"profile picture stored in medium size");
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
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary<FBGraphUser> *userData = (NSDictionary<FBGraphUser> *)result;
            
            if (userData[@"name"]) {self.title = userData[@"name"];}
            
            /* TODO updateProfile  */
            [[PFUser currentUser] setObject:userData forKey:@"profile"];
            
            // update facebook username, email, facebook profile, display name, facebook id and download profile pictures
            
            [[PFUser currentUser] setObject:userData[@"name"] forKey:@"displayName"];
            [[PFUser currentUser] setObject:userData[@"username"] forKey:@"facebookUsername"];
            [[PFUser currentUser] setObject:userData[@"id"] forKey:@"facebookId"];
            
            
            if (![[PFUser currentUser][@"profile"] isEqual:userData] || ![PFUser currentUser].email || ![[PFUser currentUser][@"email"] isEqualToString:userData[@"email"]])
            {
                
                NSLog(@"new profile data found\nupdating profile data...\n%@",userData);
                
                if (![PFUser currentUser].email || ![[PFUser currentUser][@"email"] isEqualToString:userData[@"email"]])
                {
                    [[PFUser currentUser] setObject:userData[@"email"] forKey:@"email"];
                    [[PFUser currentUser] setEmail:userData[@"email"]];
                    NSLog(@"adding/updating email");
                }
                
                [[PFUser currentUser] saveInBackground];
                
            } else {NSLog(@"user profile is up to date");}
            
            // Download the user's facebook profile picture
            profileImageData = [[NSMutableData alloc] init]; // the data will be loaded in here
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userData[@"id"]]];
            NSLog(@"profile picture URL created");
            
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                  timeoutInterval:2.0f];
            // Run network request asynchronously
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            
            NSLog(@"profile picture download initiated");
            if (!urlConnection) {
                NSLog(@"failed to download picture");
            }
            
        } else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"the facebook session was invalidated");
            [self logoutButtonTouchHandler:nil];
        } else {
            NSLog(@"some other error: %@", error);
        }
    }];
}



#pragma mark Logout methods

- (void)logoutButtonTouchHandler:(id)sender {
    [FBSession setActiveSession:nil];
    [PFUser logOut];
    // Return to login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

@end
