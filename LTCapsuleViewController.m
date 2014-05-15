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
    NSString *toBeTitle = @"";
    
    NSString *from = [self.capsule objectForKey:@"from"];
    
    if (from.length > 0)
        toBeTitle = from;
    else
        toBeTitle = @"Capsule";
    
    PFUser *fromUser = [self.capsule objectForKey:@"fromUser"];
    [fromUser fetchIfNeeded];
    NSString *displayName = [fromUser objectForKey:@"displayName"];
    if (displayName.length > 0)
        toBeTitle = displayName;
    
    self.title = toBeTitle;
    
    NSString *timestampString = [NSDateFormatter localizedStringFromDate:self.capsule.createdAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    self->timestamp.text = timestampString; // timestamp states created at date
    self->imageButton.enabled = NO;
    self->thoughtButton.enabled = NO;
    self->thoughtContainer.text = @"";
    self->theThought = [self.capsule objectForKey:@"thought"];
}

-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
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
            self->theImage = image;
            self->imageContainer.image = image;
            self->imageContainer.frame = CGRectMake(0, 130, 320, 285);
            self->imageContainer.contentMode = UIViewContentModeScaleAspectFit;
            self->thoughtContainer.frame = CGRectMake(20, 415, 280, 65);
            self->thoughtButton.frame = CGRectMake(0, 415, 320, 65);
            self->imageButton.enabled = YES;
            if (!(self->theThought.length > 1) && (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) && (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES))
            {
                [UIView animateWithDuration:0.75f animations:^{
                    self->grassImage.frame = CGRectMake(-30, 459.0f, 380, 204);
                    self->grassImage.contentMode = UIViewContentModeScaleAspectFill;
                }];
            }
        } else {
            self->imageContainer.image = nil;
        }
        self->thoughtContainer.text = self->theThought;
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIView animateWithDuration:0.25f animations:^{
        self->grassImage.frame = CGRectMake(0, 474, 320, 144);
        self->grassImage.contentMode = UIViewContentModeScaleAspectFit;
    }];
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

@end
