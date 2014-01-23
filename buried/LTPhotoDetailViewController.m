//
//  LTPhotoDetailViewController.m
//  buried
//
//  Created by Patrick Blaine on 1/23/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "LTBuryItViewController.h"
#import "LTPhotoDetailViewController.h"

@interface LTPhotoDetailViewController ()

@end

@implementation LTPhotoDetailViewController

@synthesize theImage,callingViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    imageView.image = self.theImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)discardButtonTouched:(id)sender
{
    self.theImage = nil;
    [callingViewController resetCammra];
    [callingViewController discardPhoto];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)keepButtonTouched:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
