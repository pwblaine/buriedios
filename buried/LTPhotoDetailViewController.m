//
//  LTPhotoDetailViewController.m
//  buried
//
//  Created by Patrick Blaine on 1/23/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "LTBuryItViewController.h"
#import "LTPhotoDetailViewController.h"
#import "LTCapsuleViewController.h"

@interface LTPhotoDetailViewController ()

@end

@implementation LTPhotoDetailViewController

@synthesize theImage,callingViewController,launchedFromLibrary;

- (void)viewDidLoad
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"%@",[self class]);
    
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
        if (([(LTBuryItViewController *)self.callingViewController source] != UIImagePickerControllerSourceTypeCamera) && self.launchedFromLibrary)
        {
            UIBarButtonItem *tempRight  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(goBackToLibrary:)];
            
            // if from bury it view, the picture can use: discard, actions, keep
            [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->rightButton] withObject:tempRight];
            self->rightButton = tempRight;
            
            [mutableTopToolbarItems removeObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->middleButton]];
            
            UIBarButtonItem *tempLeft  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(keepButtonTouched:)];
            [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->leftButton] withObject:tempLeft];
            self->leftButton = tempLeft;
            
        } else {
        UIBarButtonItem *tempRight  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(keepButtonTouched:)];
        
        // if from bury it view, the picture can use: discard, actions, keep
        [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->leftButton] withObject:tempRight];
        self->leftButton = tempRight;
        
            if ([(LTBuryItViewController *)self.callingViewController source] == 0)
            {
        UIBarButtonItem *tempMiddle  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTouched:)];
        
        [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->middleButton] withObject:tempMiddle];
        self->middleButton = tempMiddle;
            } else
                [mutableTopToolbarItems removeObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->middleButton]];
        
        UIBarButtonItem *tempLeft  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(discardButtonTouched:)];
        [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->rightButton] withObject:tempLeft];
        self->rightButton = tempLeft;
        }
    }
    else
    {
        UIBarButtonItem *tempRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(keepButtonTouched:)];
        
        [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->rightButton] withObject:tempRight];
        self->rightButton = tempRight;
        
        UIBarButtonItem *tempMiddle  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTouched:)];
        
        [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->middleButton] withObject:tempMiddle];
        self->middleButton = tempMiddle;
        
        UIBarButtonItem *tempLeft  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(forwardButtonTapped:)];
        
        [mutableTopToolbarItems replaceObjectAtIndex:[mutableTopToolbarItems indexOfObject:self->leftButton] withObject:tempLeft];
        self->leftButton = tempLeft;
    }
    
    [self->topToolbar setItems:mutableTopToolbarItems animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    NSLog(@"image is %f x %f",self.theImage.size.width,self.theImage.size.height);
    if ([self.presentingViewController isKindOfClass:[LTBuryItViewController class]])
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Discard Photo" message:@"Do you really want to discard this?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView setTag:1];
    [alertView show];
}
    
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    {
        // only occurs in a buryItView currently
        NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
        
        if (alertView.tag == 1)
        {
            // code for the discard alert
            if (buttonIndex == alertView.firstOtherButtonIndex)
            {
            self.theImage = nil;
            [(LTBuryItViewController *)self.callingViewController resetCamera];
            [(LTBuryItViewController *)self.callingViewController discardPhoto];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
        if (alertView.tag == 2)
        {
            if (buttonIndex != alertView.cancelButtonIndex)
            {
            // code for the forwarding alert
            LTBuryItViewController *buryItViewController = [[LTBuryItViewController alloc] init];
            buryItViewController.capsuleImage = self->theImage;
            if (buttonIndex == alertView.firstOtherButtonIndex + 1)
                buryItViewController.capsuleThought = [(LTCapsuleViewController *)self.callingViewController theThought];
            
            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                [self.callingViewController.navigationController pushViewController:buryItViewController animated:YES];
                }];
            }
        }
    
}

-(IBAction)keepButtonTouched:(id)sender
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if ([self.callingViewController isKindOfClass:[LTBuryItViewController class]])
        {
        if ([(LTBuryItViewController *)self.callingViewController source] != UIImagePickerControllerSourceTypeCamera)
        {
            self.launchedFromLibrary = NO;
        }
        }
    }];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Forward To New Capsule" message:@"Which would you like to forward to start a new capsule with..." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Just This", @"All Of It", nil];
    [alertView setTag:2];
    [alertView show];
}


- (IBAction)goBackToLibrary:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [(LTBuryItViewController *)self.callingViewController discardPhoto];
        [(LTBuryItViewController *)self.callingViewController resetCamera];
        [(LTBuryItViewController *)self.callingViewController showLibraryPicker:self.callingViewController];
    }];
}



@end
