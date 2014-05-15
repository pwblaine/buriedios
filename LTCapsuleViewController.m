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
    self->theThought = [self.capsule objectForKey:@"thought"];
    self->thoughtContainer.text = self->theThought;
    self->imageContainer.file = [self.capsule objectForKey:@"image"];
    self->imageButton.hidden = YES;
    [self->imageContainer loadInBackground:^(UIImage *image, NSError *error) {
        self->imageContainer.contentMode = UIViewContentModeScaleAspectFit;
        if (error) {
            self->thoughtContainer.text = @"couldn't find your capsule, please refresh";
        }
        else if (self->theThought.length > 1 && image)
        {
            // this code is run with both a picture and a thought
            self->theImage = image;
            self->imageContainer.image = image;
            self->imageButton.hidden = NO;
            self->thoughtContainer.frame = CGRectMake(0, 415, 320, 65);
            self->thoughtButton.frame = CGRectMake(0, 415, 320, 65);
        }
        else if (image)
        {
            // this code is run with just a picture
            self->theImage = image;
            self->imageContainer.frame = CGRectMake(0, 130, 320, 365);
            self->imageButton.frame = self->imageContainer.frame;
            self->imageContainer.image = image;
            self->thoughtContainer.alpha = 0;
            self->thoughtButton.hidden = YES;
        }
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
    LTThoughtDetailViewController *thoughtDetailViewController = [[LTThoughtDetailViewController alloc] init];
    thoughtDetailViewController.callingViewController = self;
    thoughtDetailViewController.theThought = self->theThought;
    thoughtDetailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:thoughtDetailViewController animated:YES completion:nil];
}

@end
