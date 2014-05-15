//
//  LTPhotoDetailViewController.h
//  buried
//
//  Created by Patrick Blaine on 1/23/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTBuryItViewController.h"

@interface LTPhotoDetailViewController : UIViewController <UINavigationControllerDelegate>
{
    IBOutlet UIButton *discardButton;
    IBOutlet UIButton *keepButton;
    IBOutlet UIImageView *imageView;
    IBOutlet UIToolbar *topToolbar;
    IBOutlet UIBarButtonItem *trashButton;
}

@property UIImage *theImage;
@property (retain) LTBuryItViewController *callingViewController;
@property BOOL hidesLeftDeleteButton;

-(IBAction)discardButtonTouched:(id)sender;

-(IBAction)keepButtonTouched:(id)sender;

@end
