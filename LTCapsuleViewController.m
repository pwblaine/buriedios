//
//  LTCapsuleViewController.m
//  buried
//
//  Created by Patrick Blaine on 3/4/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

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

@synthesize capsule;

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
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    /* UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTapped:)];
    self.navigationItem.rightBarButtonItem = actionButton; */
    
    UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashButtonTapped:)];
     self.navigationItem.rightBarButtonItem = trashButton;
    
    self->imageButton.enabled = NO;
    self->thoughtButton.enabled = NO;
    self->thoughtContainer.text = @"";
    self.navigationItem.title = @"Loading...";
}

-(void)viewWillAppear:(BOOL)animated {
    self->activityIndicator.alpha = 1;
    self->theThought = [self.capsule objectForKey:@"thought"];
}

-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self->activityIndicator startAnimating];
    
    NSString *fromUserId = [self.capsule objectForKey:@"fromUserId"];
    PFQuery *fromUserIdQuery = [PFUser query];
    [fromUserIdQuery whereKey:@"objectId" equalTo:fromUserId];
    [fromUserIdQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            PFUser *user = [objects firstObject];
            NSString *displayName = [user objectForKey:@"displayName"];
            if (displayName.length > 0)
                self.title = [NSString stringWithFormat:@"From %@", displayName];
        }
    }];
    
    if (self->theThought.length > 1)
        self->thoughtButton.enabled = YES;
    
    self->imageContainer.file = [self.capsule objectForKey:@"image"];
    
    [self->imageContainer loadInBackground:^(UIImage *image, NSError *error) {
        if (error) {
            self->thoughtContainer.text = @"couldn't find your capsule, please refresh";
        }
        else if (image)
        {
            
            // this code is run if a picture is downloaded
            self->theImage = image; // store image in property

            self->imageContainer.image = image;
            self->imageContainer.frame = CGRectMake((320-285)/2, 130, 285, 285);
            self->imageButton.frame = CGRectMake((320-285)/2, 125, 285, 285);
            
            self->imageContainer.contentMode = UIViewContentModeScaleAspectFit;
            
            self->thoughtContainer.frame = CGRectMake(20, 415, 280, 65);
            self->thoughtButton.frame = CGRectMake(20, 415, 280, 65);
            
            self->imageButton.enabled = YES;
            
            if (!(self->theThought.length > 1) && (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) && (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES))
            {
                [UIView animateWithDuration:0.75f animations:^{
                    self->grassImage.frame = CGRectMake(-30, 459, 380, 204);
                    // self->grassImage.contentMode = UIViewContentModeScaleAspectFill;
                }];
            }
        } else {
            self->imageContainer.image = nil;
            if ((UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) && (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES))
            {
                [UIView animateWithDuration:0.75f animations:^{
                    self->grassImage.frame = CGRectMake(-30, 459, 380, 204);
                    // self->grassImage.contentMode = UIViewContentModeScaleAspectFill;
                }];
            }
        }
        // this code runs whether there's an image or not after its been retrieved
        if ([self->imageContainer.image isEqual:[UIImage imageWithContentsOfFile:@"burieddot152.png"]])
            self->imageContainer.image = nil;
        self->thoughtContainer.text = self->theThought;
        [self->activityIndicator stopAnimating];
        [self->activityIndicator setAlpha:0];
        NSString *timestampString = [NSDateFormatter localizedStringFromDate:self.capsule.createdAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
        self->timestamp.text = timestampString; // timestamp states created at date
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [UIView animateWithDuration:0.25f animations:^{
        self->grassImage.frame = CGRectMake(0, 474, 320, 144);
        self->grassImage.contentMode = UIViewContentModeScaleAspectFit;
        self->imageContainer.contentMode = UIViewContentModeCenter;
        self->imageContainer.image = [UIImage imageNamed:@"burieddot152.png"];
        self->thoughtContainer.text = @"";
    }];
    
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
    photoDetailViewController.callingViewController = self;
    photoDetailViewController.theImage = self->theImage;
    photoDetailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:photoDetailViewController animated:YES completion:nil];
}

- (IBAction)thoughtButtonTapped:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (self->theThought.length > 1)
    {
    LTThoughtDetailViewController *thoughtDetailViewController = [[LTThoughtDetailViewController alloc] init];
    thoughtDetailViewController.callingViewController = self;
    thoughtDetailViewController.theThought = self->theThought;
    thoughtDetailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:thoughtDetailViewController animated:YES completion:nil];
    }
}

- (IBAction)actionButtonTapped:(id)sender
{
    NSLog(@"<%@:%@:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

- (IBAction)forwardButtonTapped:(id)sender
{
    NSLog(@"<%@:%@:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    LTBuryItViewController *buryItViewController = [[LTBuryItViewController alloc] init];

    buryItViewController.capsuleImage = self->theImage;
    buryItViewController.capsuleThought = self->theThought;
    [self.navigationController pushViewController:buryItViewController animated:YES];
}

- (IBAction)trashButtonTapped:(id)sender
{
    NSString *capsuleId = [self.capsule objectId];
    [self.capsule deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
        NSLog(@"capsule %@ has been successfully removed from the database, popping to unearthed view",capsuleId);
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSLog(@"deleting capsule %@ failed with error %@, please try again",error,capsuleId);
        }
        
    }];
}

@end
