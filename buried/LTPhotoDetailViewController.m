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
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self->imageView.image = self.theImage;
    
    // if the view is not LTBuryItViewController, remove it from the view
    if (![self.callingViewController isKindOfClass:[LTBuryItViewController class]])
    {
        NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self->topToolbar.items];
        [toolbarItems removeObject:self->trashButton];
        self->topToolbar.items = toolbarItems;
        // TODO add action button for saving/sharing
    }
    
    // set top toolbar to transparent
    [self->topToolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)discardButtonTouched:(id)sender
{
    // only occurs in a buryItView currently
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self.theImage = nil;
    [(LTBuryItViewController *)self.callingViewController resetCamera];
    [(LTBuryItViewController *)self.callingViewController discardPhoto];
    [self.callingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)keepButtonTouched:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [self.callingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
