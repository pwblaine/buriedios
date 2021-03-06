//
//  LTPhotoDetailViewController.h
//  buried
//
//  Created by Patrick Blaine on 1/23/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LTPhotoDetailViewController : UIViewController <UINavigationControllerDelegate, MBProgressHUDDelegate, UIAlertViewDelegate>
{
    IBOutlet UIImageView *imageView;
    IBOutlet UIToolbar *topToolbar;
    IBOutlet UIBarButtonItem *leftButton;
    IBOutlet UIBarButtonItem *middleButton;
    IBOutlet UIBarButtonItem *rightButton;
}

@property UIImage *theImage;
@property (retain) UIViewController *callingViewController;
@property BOOL launchedFromLibrary;

-(IBAction)discardButtonTouched:(id)sender;
-(IBAction)actionButtonTouched:(id)sender;
-(IBAction)keepButtonTouched:(id)sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
