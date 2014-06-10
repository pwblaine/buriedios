//
//  Copyright (c) 2013 Parse. All rights reserved.

@interface LTAppDelegate : UIResponder <UIApplicationDelegate> {
    BOOL initialLoad;
    NSString *displayName;
    CGRect grownGrassFrame;
    CGRect shrunkGrassFrame;
    CGRect hiddenGrassFrame;
}

@property (strong, nonatomic) UIWindow *window;

@property UIImageView *grassImage;
@property BOOL grassIsShowing;
@property BOOL isAnimatingGrass;
@property BOOL grassIsShrunk;

- (void)showGrass:(BOOL)shouldShow animated:(BOOL)shouldAnimate;
-(void)shrinkGrassAnimated:(BOOL)shouldAnimate;

@end
