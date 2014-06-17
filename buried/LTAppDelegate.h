//
//  Copyright (c) 2013 Parse. All rights reserved.

@class LTGrassViewController;

@interface LTAppDelegate : UIResponder <UIApplicationDelegate> {
    BOOL initialLoad;
    NSString *displayName;
}

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) LTGrassViewController *grassDelegate;

@end
