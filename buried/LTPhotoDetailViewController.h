//
//  LTPhotoDetailViewController.h
//  buried
//
//  Created by Patrick Blaine on 1/23/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTPhotoDetailViewController : UIViewController <UINavigationControllerDelegate>
{
    IBOutlet UIImageView *imageView;
    IBOutlet UIToolbar *topToolbar;
    IBOutlet UIBarButtonItem *trashButton;
}

@property UIImage *theImage;
@property (retain) UIViewController *callingViewController;

-(IBAction)discardButtonTouched:(id)sender;
-(IBAction)keepButtonTouched:(id)sender;

@end
