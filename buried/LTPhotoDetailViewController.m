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
    
    self->imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    if ((UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) && (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES))
    {
    }
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    NSLog(@"statusBarFrame.height = %f",statusBarFrame.size.height);
    
        self->imageView.frame = CGRectMake(0, statusBarFrame.size.height, self->imageView.frame.size.width, (self->imageView.frame.size.height - statusBarFrame.size.height));

    // set top toolbar to transparent
     [self->topToolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    // adjust top toolbar for calling view controller
    NSMutableArray *mutableTopToolbarItems = [[self->topToolbar items] mutableCopy];
    NSLog(@"%@ copied",mutableTopToolbarItems);
    
    if ([self.callingViewController isKindOfClass:[LTBuryItViewController class]])
    {
        UIBarButtonItem *tempLeft  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(discardButtonTouched:)];
        
        // if from bury it view, the picture can use: discard, actions, keep
        [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->leftButton] withObject:tempLeft];
        self->leftButton = tempLeft;
        
        UIBarButtonItem *tempMiddle  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTouched:)];
        
        [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->middleButton] withObject:tempMiddle];
        self->middleButton = tempMiddle;
        
        UIBarButtonItem *tempRight  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(keepButtonTouched:)];
        [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->rightButton] withObject:tempRight];
        self->rightButton = tempRight;
    }
    else
    {
        UIBarButtonItem *tempLeft  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(forwardButtonTapped:)];
        
        [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->leftButton] withObject:tempLeft];
        self->leftButton = tempLeft;
        
        UIBarButtonItem *tempMiddle  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTouched:)];
        
        [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->middleButton] withObject:tempMiddle];
        self->middleButton = tempMiddle;
        
        UIBarButtonItem *tempRight  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(keepButtonTouched:)];
        
        [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->rightButton] withObject:tempRight];
        self->rightButton = tempRight;
    }
    
    [self->topToolbar setItems:mutableTopToolbarItems animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    NSLog(@"image is %f x %f",self.theImage.size.width,self.theImage.size.height);
    if ([self.callingViewController isKindOfClass:[LTBuryItViewController class]])
    {
        // This code is run if the view is called from a BuryItViewController
    }
    else {
        /* This code is run if the view is called from any other controller
        [UIView animateWithDuration:0.5 delay:2.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self->imageView.contentMode = UIViewContentModeScaleAspectFill;
        } completion:^(BOOL finished) {
            self->scrollView.contentSize = self->imageView.frame.size;
        
        NSLog(@"imageView is %f x %f",self->imageView.frame.size.width,self->imageView.frame.size.height);
            NSLog(@"scrollView is %f x %f",self->scrollView.contentSize.width,self->scrollView.contentSize.height);
        }]; */
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>",NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

-(void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>",NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
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

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if (error) {
        // Do anything needed to handle the error or display it to the user
        NSLog(@"image did not save successfully, error: %@ contextInfo:%@", error, ctxInfo);
    } else {
        // .... do anything you want here to handle
        // .... when the image has been saved in the photo album
        NSLog(@"image did save successfully, contextInfo:%@", ctxInfo);
        MBProgressHUD * HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.delegate = self;
        HUD.labelText = @"image saved";
        [self.view addSubview:HUD];
        [HUD show:YES];
        [HUD hide:YES afterDelay:1];
    }
    
}

-(IBAction)actionButtonTouched:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    UIImageWriteToSavedPhotosAlbum(self.theImage, self, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
    
}

- (IBAction)forwardButtonTapped:(id)sender
{
    NSLog(@"<%@:%@:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    LTBuryItViewController *buryItViewController = [[LTBuryItViewController alloc] init];
    
    buryItViewController.capsuleImage = self->theImage;
    
    [self.callingViewController dismissViewControllerAnimated:YES completion:^{
        [self.callingViewController.navigationController pushViewController:buryItViewController animated:YES];
    }];
    
}



@end
