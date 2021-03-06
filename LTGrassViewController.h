//
//  LTGrassViewController.h
//  buried
//
//  Created by Patrick Blaine on 6/14/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTGrassViewController : UIViewController <UINavigationControllerDelegate> {
    float grassAnimationDuration;
}

#pragma mark LTGrassStates

typedef NS_ENUM(NSInteger, LTGrassState) {
    LTGrassStateAnimating,
    LTGrassStateHidden,
    LTGrassStateShrunk,
    LTGrassStateGrown
};

-(void)addToFrontOfView:(UIView *)view;

-(LTGrassState)setGrassState:(LTGrassState)newGrassState animated:(BOOL)isAnimated;

-(LTGrassState)grassState;
-(LTGrassState)destinationState;

@property (retain, nonatomic) IBOutlet UIImageView *grassView;
@property (assign) BOOL appIsComingBackFromBackground;
@property NSDictionary *colorScheme;

#pragma mark UINavigationControllerDelegate methods
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

#pragma mark LTGrassView static methods

+(LTGrassViewController *)delegate;

+(UIColor *)errorColor;

+(UIColor *)successColor;

@end

#pragma mark LTGrassViewControllerProtocol

@protocol LTGrassViewControllerDelegate <NSObject>

// everyone that implements the grassView delegate must define a default state for the view
-(LTGrassState)defaultGrassStateForView;

@end