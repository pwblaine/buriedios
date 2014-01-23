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
    IBOutlet UIButton *deleteButton;
    IBOutlet UIButton *keepButton;
    IBOutlet UIImageView *imageView;
}

@property UIImage *theImage;
@property (retain) LTBuryItViewController *callingViewController;

-(IBAction)deleteButtonTouched:(id)sender;

-(IBAction)keepButtonTouched:(id)sender;

@end
