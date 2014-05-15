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

@synthesize theImage,callingViewController,hidesLeftDeleteButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self->imageView.image = self.theImage;
    
    // if the view is flagged to hide the delete button, remove it from the view
    if (self.hidesLeftDeleteButton) {
        NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self->topToolbar.items];
        [toolbarItems removeObject:self->trashButton];
        self->topToolbar.items = toolbarItems;
    }
    
    // set top toolbar to transparent
    [self->topToolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)discardButtonTouched:(id)sender
{
    self.theImage = nil;
    [callingViewController resetCamera];
    [callingViewController discardPhoto];
    [self.callingViewController dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(IBAction)keepButtonTouched:(id)sender
{
    self.navigationController.navigationBar.translucent = NO;
    [self.callingViewController dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

@end
