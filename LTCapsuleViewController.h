//
//  LTCapsuleViewController.h
//  buried
//
//  Created by Patrick Blaine on 3/4/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LTCapsuleViewController : UIViewController <UINavigationControllerDelegate>
{
    IBOutlet UILabel *timestamp;
    IBOutlet UILabel *thoughtContainer;
    IBOutlet PFImageView *imageContainer;
    UIImage *theImage;
    NSString *theThought;
    IBOutlet UIButton *imageButton;
    IBOutlet UIButton *thoughtButton;
    IBOutlet UIImageView *grassImage;
}

@property PFObject *capsule;

- (void)backButtonTouchHandler:(id)sender;
- (IBAction)imageButtonTapped:(id)sender;
- (IBAction)thoughtButtonTapped:(id)sender;

@end
