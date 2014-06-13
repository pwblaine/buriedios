//
//  Copyright (c) 2013 Parse. All rights reserved.

@interface LTAppDelegate : UIResponder <UIApplicationDelegate> {
    BOOL initialLoad;
    NSString *displayName;
    CGRect grownGrassFrame;
    CGRect shrunkGrassFrame;
    CGRect hiddenGrassFrame;
    float grassAnimationDuration;
}

@property (strong, nonatomic) UIWindow *window;

@property UIImageView *grassImage;

@property BOOL isAnimatingGrass;

@property BOOL grassIsShrunk;
@property BOOL grassIsShowing;

- (void)showGrass:(BOOL)shouldShow animated:(BOOL)shouldAnimate;

-(void)shrinkGrassAnimated:(BOOL)shouldAnimate;

#pragma mark LTGrassStates

typedef NS_ENUM(NSInteger, LTGrassState) {
    LTGrassStateAnimating,
    LTGrassStateHidden,
    LTGrassStateShrunk,
    LTGrassStateGrown
};

-(LTGrassState)setGrassState:(LTGrassState)newGrassState animated:(BOOL)isAnimated;

-(LTGrassState)grassState;

@end
