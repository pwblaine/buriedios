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

#pragma mark UINavigationControllerDelegate methods
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

#pragma mark Delegate methods

+(LTGrassViewController *)delegate;

@end

#pragma mark LTGrassViewControllerProtocol

@protocol LTGrassViewControllerDelegate <NSObject>

// everyone that implements the grassView delegate must define a default state for the view
-(LTGrassState)defaultGrassStateForView;


#pragma mark view framing refrence

#pragma mark Portrait

+(NSInteger)statusBarHeight; // 20

+(NSInteger)navBarHeight; // 44

+(CGRect)LTGrassStateHiddenFrame; // 0x568,320x144

+(CGRect)LTGrassStateShrunkFrame; // -15x494,350x174

+(CGRect)LTGrassStateGrownFrame; // -30x459, 380x204

+(CGSize)iPhone5FullViewSize; // 320x568

+(CGPoint)iPhone5CenterOfFullView; //160x289

+(CGSize)iPhone4FullViewSize; // 320x480

+(CGPoint)iPhone4CenterOfFullView; //160x240

+(NSInteger)iPhone5ViewHeightOffset; //568-480 = 88

@end