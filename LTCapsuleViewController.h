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
    IBOutlet UITextView *thoughtContainer;
    IBOutlet PFImageView *imageContainer;
    UIImage *theImage;
}

@property PFObject *capsule;

- (void)backButtonTouchHandler:(id)sender;
- (void)imageButtonTapped:(id)sender;
- (void)doneButtonTapped:(id)sender;

@end
