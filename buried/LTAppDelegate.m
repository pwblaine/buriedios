//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "LTAppDelegate.h"

#import <Parse/Parse.h>
#import "LTLoginViewController.h"
#import "QuickAddView.h"

@implementation LTAppDelegate


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // ****************************************************************************
    // Fill in with your Parse credentials:
    // ****************************************************************************
    [Parse setApplicationId:@"XDnTN3cpdPIhzRua58wPlXAJE41vKCHNlAmqAchK"
                  clientKey:@"fc2DivfMyIr6rvPWIkzWEVAGDLVimepvPgdnHctb"];

    // ****************************************************************************
    // Your Facebook application id is configured in Info.plist.
    // ****************************************************************************
    [PFFacebookUtils initializeFacebook];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
#ifdef __IPHONE_7_0
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    if ([self.window.rootViewController respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.window.rootViewController.edgesForExtendedLayout &= ~UIRectEdgeTop;
    }
#endif
#endif
#endif

    // Override point for customization after application launch.
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[LTLoginViewController alloc] init]];
    UIView *quickAddView = [[QuickAddView alloc] initWithFrame:CGRectMake(0, 494, 320, 568)];
    [self.window.rootViewController.view addSubview:quickAddView];
    [self.window.rootViewController.view bringSubviewToFront:quickAddView];
    [self showGrass:NO];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [[PFFacebookUtils session] close];
}

-(void)showGrass:(BOOL)shouldShow {
    // this method toggles the grass in the quick add field, it dissappears when its disabled
    for (QuickAddView *aView in self.window.rootViewController.view.subviews) {
        if ([aView isKindOfClass:[QuickAddView class]])
        {        NSLog(@"showGrass:%d",shouldShow);   }
        // finds the grass container in array of active subviews for the rootNav controller
        if ([aView isKindOfClass:[QuickAddView class]] && shouldShow) {
            [[(QuickAddView *)aView grassButton] setHidden:NO];
        } else if ([aView isKindOfClass:[QuickAddView class]] && !shouldShow) {
            [[(QuickAddView *)aView grassButton] setHidden:YES];
        }
    }
}

-(IBAction)slideGrass:(id)sender {
    // this method toggles the grass in the quick add field, it dissappears when its disabled
    for (QuickAddView *aView in self.window.rootViewController.view.subviews) {
        // finds the grass container in array of active subviews for the rootNav controller
        if ([aView isKindOfClass:[QuickAddView class]] && (aView.center.y == 778.0f)) {
            NSLog(@"grassCenter: (%f,%f)",aView.center.x,aView.center.y);
            NSLog(@"grassButtonCenter: (%f,%f)",aView.grassButton.center.x,aView.grassButton.center.y);
            [aView setCenter:CGPointMake(aView.center.x, aView.frame.size.height/2)];
            [aView setBackgroundColor:[UIColor blackColor]];
            aView.grassButton.center = CGPointMake(aView.center.x, aView.grassButton.center.y*-1/8);
            NSLog(@"grassCenter: (%f,%f)",aView.center.x,aView.center.y);
        } else if ([aView isKindOfClass:[QuickAddView class]]) {
            NSLog(@"grassCenter: (%f,%f)",aView.center.x,aView.center.y);
            [aView setCenter:CGPointMake(aView.center.x, 778.0f)];
            [aView setBackgroundColor:[UIColor clearColor]];
            aView.grassButton.center = CGPointMake(aView.center.x, aView.grassButton.frame.size.height/2);
            NSLog(@"grassCenter: (%f,%f)",aView.center.x,aView.center.y);
        }
    }
}

@end
