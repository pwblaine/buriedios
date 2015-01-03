//
//  LTCapsuleViewController.m
//  buried
//
//  Created by Patrick Blaine on 3/4/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "LTAppDelegate.h"
#import "LTCapsuleViewController.h"
#import "LTPhotoDetailViewController.h"
#import "LTThoughtDetailViewController.h"
#import "LTBuryItViewController.h"
#import "LTUnearthedViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "UIBarButtonItem+_projectButtons.h"

@interface LTCapsuleViewController ()

@end

@implementation LTCapsuleViewController

@synthesize capsule,theImage,theThought;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    }
    return self;
}

- (void)viewDidLoad
{
    
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(backButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    /*
     self.navigationItem.rightBarButtonItem = actionButton; */
    
    UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashButtonTapped:)];
    self.navigationItem.rightBarButtonItem = trashButton;
    
    self->imageButton.enabled = NO;
    self->thoughtButton.enabled = NO;
    self->thoughtContainer.text = @"";
    self.navigationItem.title = @"loading...";
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self->activityIndicator.alpha = 1;
    self->imageContainer.alpha = 0.0f;
    self->thoughtContainer.alpha = 0.0f;
    self.theThought = [self.capsule objectForKey:@"thought"];
    
    NSString *fromUserId = [self.capsule objectForKey:@"fromUserId"];
    PFQuery *fromUserIdQuery = [PFUser query];
    [fromUserIdQuery whereKey:@"objectId" equalTo:fromUserId];
    [fromUserIdQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self->activityIndicator startAnimating];
    
    self->imageContainer.file = [self.capsule objectForKey:@"image"];
    
    [self->imageContainer loadInBackground:^(UIImage *image, NSError *error) {
        if (error) {
            self->thoughtContainer.text = @"couldn't find your capsule, please refresh";
        }
        else if (image)
        {
            

            // this code is run if a picture is downloaded
            self.theImage = image; // store image in property
            
            
            NSLog(@"picture code is running");
            
            [UIView animateWithDuration:.5f delay:.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self->imageContainer.image = image;
                self->imageContainer.contentMode = UIViewContentModeScaleAspectFit;
                self->imageContainer.alpha = 1.0f;
                self->thoughtContainer.alpha = 1.0f;
                ;
            } completion:^(BOOL finished) {
                NSLog(@"animation done");
            }];
            
            self->imageButton.enabled = YES;
            
            LTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate.grassDelegate setGrassState:LTGrassStateShrunk animated:YES];
            
        } else {
            LTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate.grassDelegate setGrassState:LTGrassStateShrunk animated:YES];
            self->thoughtContainer.contentMode = UIViewContentModeRedraw;
            
            [UIView animateWithDuration:.5f delay:.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self->imageContainer.contentMode = UIViewContentModeCenter;
                self->imageContainer.alpha = 1.0f;
                self->thoughtContainer.alpha = 1.0f;
                
            } completion:^(BOOL finished) {
                NSLog(@"animation done");
            }];
            NSLog(@"no picture found in the capsule");
        }
        // this code runs whether there's an image or not after its been retrieved
        if (self.theThought.length > 1)
        { NSLog(@"thethought > 1");
            self->thoughtButton.enabled = YES;
        }
        else
        {
            LTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate.grassDelegate setGrassState:LTGrassStateGrown animated:YES];
            
        }
        if ([self->imageContainer.image isEqual:[UIImage imageWithContentsOfFile:@"burieddot152.png"]])
        {
            self->imageContainer.image = nil;
        }
        self.navigationItem.title = @"buried.";
        self->thoughtContainer.text = self.theThought;
        [UIView animateWithDuration:.5f delay:.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self->activityIndicator setAlpha:0];
            self->thoughtContainer.center = CGPointMake(self->thoughtContainer.center.x,self->thoughtContainer.center.y - 72);
        } completion:^(BOOL finished) {
            NSLog(@"animation done");
            [self->activityIndicator stopAnimating];
        }];
        NSString *timestampString = [NSDateFormatter localizedStringFromDate:self.capsule.createdAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
        self->timestamp.text = timestampString; // timestamp states created at date
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self->imageContainer.alpha = 0;
    [UIView animateWithDuration:0.25f animations:^{
        self->imageContainer.contentMode = UIViewContentModeScaleAspectFit;
        self->imageContainer.image = [UIImage imageNamed:@"burieddot152.png"];
    }];
    self->thoughtContainer.text = @"";
    self->timestamp.text = @"";
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)backButtonTouchHandler:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)imageButtonTapped:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    LTPhotoDetailViewController *photoDetailViewController = [[LTPhotoDetailViewController alloc] init];
    photoDetailViewController.theImage = self.theImage;
    photoDetailViewController.callingViewController = self;
    photoDetailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:photoDetailViewController animated:YES completion:nil];
    
}

- (IBAction)thoughtButtonTapped:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (self.theThought.length > 1)
    {
        LTThoughtDetailViewController *thoughtDetailViewController = [[LTThoughtDetailViewController alloc] init];
        thoughtDetailViewController.theThought = self.theThought;
        thoughtDetailViewController.callingViewController = self;
        thoughtDetailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:thoughtDetailViewController animated:YES completion:nil];
    }
}

- (IBAction)actionButtonTapped:(id)sender
{
    NSLog(@"<%@:%@:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

- (IBAction)trashButtonTapped:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"delete capsule" message:@"are you sure you want to delete this capsule permanently?" delegate:self cancelButtonTitle:@"no" otherButtonTitles:@"yes", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex)
    {
        NSString *capsuleId = [self.capsule objectId];
        NSMutableArray *toUsersArray = [[NSMutableArray alloc] initWithArray:[self.capsule objectForKey:@"toUserIds"]];
        NSLog(@"userIdArray: %@",toUsersArray);
        NSString *userId = [[PFUser currentUser] objectId];
        NSLog(@"toUserIds for capsule %@: %@",capsuleId,toUsersArray);
        if ([toUsersArray containsObject:userId])
            [toUsersArray removeObject:userId];
        NSLog(@"userId %@ removed from capsule %@",userId,capsuleId);
        [self.capsule setObject:[[NSArray alloc] initWithArray:toUsersArray] forKey:@"toUserIds"];
        [self.capsule saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // if capsule is no longer attached to any users, remove from db.
            if (succeeded && ([[self.capsule objectForKey:@"toUserIds"] count] == 0) && ([[self.capsule objectForKey:@"toFbIds"] count] == 0))
            {
                NSLog(@"capsule left in database with no users, popping to unearthed view");
                
                /*NSLog(@"capsule identified as empty, removing from db...");
                 [self.capsule deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 if (succeeded)
                 {
                 NSLog(@"capsule %@ has been successfully removed from the database, popping to unearthed view",capsuleId);
                 [self.navigationController popViewControllerAnimated:YES];
                 } else {
                 NSLog(@"deleting capsule %@ failed with error %@, please try again",error,capsuleId);
                 }
                 
                 }];*/
            } else if ([[self.capsule objectForKey:@"toUserIds"] count] != 0)
            {
                NSLog(@"toUserIds for capsule %@: %@, popping to unearthed view...",capsuleId,toUsersArray);
            }
            if (error)
            {
                NSLog(@"saving capsule %@ failed with error: %@",capsuleId,error);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

@end