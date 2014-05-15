//
//  Copyright (c) 2013 Parse. All rights reserved.

#import <UIKit/UIKit.h>

@interface LTLoginViewController : UIViewController
{
    IBOutlet UIImageView *grassImage;
}

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)loginButtonTouchHandler:(id)sender;

@end
