//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "LTAppDelegate.h"

#import <Parse/Parse.h>
#import "LTLoginViewController.h"
#import "QuickAddView.h"
#import "LTBuryItViewController.h"

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
    
    // Register for Notification Center
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    
    // Set up initial view
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

-(void)summonBuryItViewWithCamera {
    NSLog(@"summonBuryItViewWithCamera");
    LTBuryItViewController *controller = [[LTBuryItViewController alloc] init];
    [(UINavigationController *)self.window.rootViewController pushViewController:controller animated:YES];
    [controller cameraButtonTapped:self];
    // if line above fails use this...
    // [NSTimer scheduledTimerWithTimeInterval:1 target:controller selector:@selector(cameraButtonTapped:) userInfo:nil repeats:NO];
}

-(IBAction)slideGrass:(id)sender {
    
    [self summonBuryItViewWithCamera];
    /*
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
    }*/
}

#pragma Push Notification Methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Push notitifications registered successfully, saving installation data to Parse");
    
    // Upon proper registration with push notifications, save the information to a Parse installation.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation addUniqueObject:@"global" forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    // on a class that uses this data [self loadInstallData]; must be envoked in the ViewDidLoad method
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

@end
