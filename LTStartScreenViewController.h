//
//  LTStartScreenViewController.h
//  buried
//
//  Created by Patrick Blaine on 6/8/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LTStartScreenViewController : UIViewController <MBProgressHUDDelegate>
{
    IBOutlet UIImageView *grassImage;
    IBOutlet UILabel *lastLoggedInLabel;
    IBOutlet UIButton *notYouButton;
    
    MBProgressHUD *HUD;
}

- (IBAction)loginButtonTouchHandler:(id)sender;
- (IBAction)notYouButtonTouched:(id)sender;

- (void)hudWasHidden:(MBProgressHUD *)hud;

@end
