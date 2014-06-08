//
//  Copyright (c) 2013 Parse. All rights reserved.

#import <UIKit/UIKit.h>

@interface LTLoginViewController : UIViewController
{
    IBOutlet UIImageView *grassImage;
    IBOutlet UILabel *lastLoggedInLabel;
    IBOutlet UIButton *notYouButton;
}

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)loginButtonTouchHandler:(id)sender;
- (IBAction)notYouButtonTouched:(id)sender;

@end
