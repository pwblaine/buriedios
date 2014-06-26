//
//  LTCapsuleViewController.h
//  buried
//
//  Created by Patrick Blaine on 3/4/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LTCapsuleViewController : UIViewController <UINavigationControllerDelegate, UIAlertViewDelegate>
{
    
    IBOutlet UILabel *timestamp;
    IBOutlet UILabel *thoughtContainer;
    
    IBOutlet PFImageView *imageContainer;
    
    IBOutlet UIButton *imageButton;
    IBOutlet UIButton *thoughtButton;    
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
    BOOL downloaded;
}

@property PFObject *capsule;
@property UIImage *theImage;
@property NSString *theThought;

- (IBAction)backButtonTouchHandler:(id)sender;
- (IBAction)imageButtonTapped:(id)sender;
- (IBAction)thoughtButtonTapped:(id)sender;
- (IBAction)actionButtonTapped:(id)sender;
- (IBAction)trashButtonTapped:(id)sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
