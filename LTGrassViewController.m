//
//  LTGrassViewController.m
//  buried
//
//  Created by Patrick Blaine on 6/14/14.
//  Copyright (c) 2014 Loftier Thoughts. All rights reserved.
//

#import "LTGrassViewController.h"
#import <Parse/Parse.h>
#import "LTAppDelegate.h"

#import "LTUnearthedViewController.h"

@interface LTGrassViewController ()
{
    LTGrassState currentGrassState;
    LTGrassState destinationGrassState;
}

@property (strong) id<LTGrassViewControllerDelegate> delegate;

@end

@implementation LTGrassViewController

@synthesize grassView, delegate, colorScheme;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.grassView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buriedlogo_250height.png"]];
        self.grassView.contentMode = UIViewContentModeScaleAspectFit;
        self.grassView.frame = CGRectMake(0, 568.0f, 320, 144);
        self->grassAnimationDuration = 0.75f;
        self->currentGrassState = LTGrassStateHidden;
        self->destinationGrassState = LTGrassStateHidden;
        self.appIsComingBackFromBackground = NO;
        self.colorScheme = @{@"errorColor":[UIColor colorWithRed:111/255.0f green:0/255.0f blue:8/255.0f alpha:1.0f], @"successColor":[UIColor colorWithRed:25/255.0f green:96/255.0f blue:36/255.0f alpha:1.0f]};
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

-(void)addToFrontOfView:(UIView *)theView
{
    if ( ((UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) && (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)))
    {
        [theView addSubview:self.grassView];
        [theView bringSubviewToFront:self.grassView];
    }
}

- (LTGrassState)setGrassState:(LTGrassState)newGrassState animated:(BOOL)isAnimated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    // test first if the grass is currently animating and not able to execute new requests.
    if (self.appIsComingBackFromBackground)
        self.appIsComingBackFromBackground = NO;
    else if (self->currentGrassState == LTGrassStateAnimating)
    {
        NSLog(@"grassIsAnimating setting newGrassState as desination");
        self->destinationGrassState = newGrassState;
        return self->currentGrassState;
    }
    else if (self->currentGrassState != newGrassState)
    {
        NSLog(@"updating grass");
        // secondly test for whether any update is needed, if not, quits out with the current grassState
        
        // if an update is needed, the animation status is initialized to the passed in value and the frame it will update to is initialized and filled with the coordinates for each case
        
        self->destinationGrassState = newGrassState;
        CGRect newFrame = CGRectNull;
        
        switch (newGrassState) {
            case LTGrassStateHidden:
                NSLog(@"LTGrassStateHidden");
                newFrame = CGRectMake(0, 568.0f, 320, 144);
                break;
            case LTGrassStateShrunk:
                NSLog(@"LTGrassStateShrunk");
                newFrame = CGRectMake(-15, 494, 350, 174);
                break;
            case LTGrassStateGrown:
                NSLog(@"LTGrassStateGrown");
                newFrame = CGRectMake(-30, 459.0f, 380, 204);
                break;
            default:
                NSLog(@"LTGrassStateAnimating");
                break;
        }
        
        // the animation block that will be either commited with duration is initialized to the newFrame
        void (^animation)(void) = ^{
            self.grassView.frame = newFrame;
        };
        
        if (isAnimated)
        {
            self->currentGrassState = LTGrassStateAnimating;
            [UIView animateWithDuration:self->grassAnimationDuration animations:animation completion:^(BOOL finished) {
                // when the animation splits the code to asynchronous, follow up and make sure the animation visibility process is up to date
                if (finished)
                {
                    NSLog(@"animation finished");
                    self->currentGrassState = newGrassState;
                if (self->destinationGrassState != self->currentGrassState)
                    NSLog(@"destination state has changed, reanimating");
                    [self setGrassState:self->destinationGrassState animated:YES];
                }
            }];
        } else {
            animation(); // if the isAnimated boolean is negative then invoke the animation block
            self->currentGrassState = newGrassState;
        }
        
    }
    return self->currentGrassState; // returns an LTGrassState object
};

-(LTGrassState)grassState
{
    //NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    return self->currentGrassState;
}

-(LTGrassState)destinationState
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    return self->currentGrassState;
    
}

#pragma mark UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    if ([viewController conformsToProtocol:@protocol(LTGrassViewControllerDelegate)])
    {
        NSLog(@"%@ conforms to LTGrassViewControllerDelegate, queueing default LTGrassState",[viewController class]);
        [self setGrassState:[(id<LTGrassViewControllerDelegate>)viewController defaultGrassStateForView] animated:YES];
    } else if (![viewController isMemberOfClass:[LTUnearthedViewController class]])
    {
        /*for (UITapGestureRecognizer *tapGesture in self.navigationController.navigationBar.gestureRecognizers) {
            NSLog(@"deactivating admin menu");
            [tapGesture removeTarget:(LTUnearthedViewController *)viewController action:@selector(pushToAdminTable)];
            [self.navigationController.navigationBar removeGestureRecognizer:tapGesture];
        };*/
    }
    NSLog(@"transferring to %@ via navController from %@...",[viewController class], [[navigationController visibleViewController] class]);
}

#pragma mark Singleton methods

+(LTGrassViewController*)delegate
{
    //NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    return [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] grassDelegate];
}

#pragma mark Color Scheme

+(UIColor *)errorColor{
    return [UIColor colorWithRed:111/255.0f green:0/255.0f blue:8/255.0f alpha:1.0f];
}

+(UIColor *)successColor{
    return [UIColor colorWithRed:25/255.0f green:96/255.0f blue:36/255.0f alpha:1.0f];
}

@end
