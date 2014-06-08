//
//  Copyright (c) 2013 Parse. All rights reserved.

@interface LTAppDelegate : UIResponder <UIApplicationDelegate> {
    BOOL initialLoad;
    NSString *displayName;
}

@property (strong, nonatomic) UIWindow *window;

@property UIImageView *grassImage;
@property BOOL grassIsShowing;

- (void)showGrass:(BOOL)shouldShow animated:(BOOL)shouldAnimate;

@end
