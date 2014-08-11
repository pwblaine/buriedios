//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "LTAppDelegate.h"
#import <Bolts/Bolts.h>
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "LTStartScreenViewController.h"
#import "LTBuryItViewController.h"
#import "LTUnearthedViewController.h"
#import "LTGrassViewController.h"

@implementation LTAppDelegate

@synthesize grassDelegate;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //Ubertersters SDK initialization
    // [[Ubertesters shared] initialize];
    // ONLY ENABLE WHEN READY, CONFLICTS WITH VIEWDIDAPPEAR AND STOPS GRASS FROM LOADING
    
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
    
    [FBDialogs class];
    [FBWebDialogs class];
    [FBLoginView class];
    
    [FBFriendPickerViewController class];
    
    // set defaults
    self->initialLoad = YES;
    
    // Register for Notification Center
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    
    LTStartScreenViewController *startScreenVC = [[LTStartScreenViewController alloc] initWithNibName:@"LTStartScreenViewController" bundle:[NSBundle mainBundle]];
    
    // Set up initial view
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController: startScreenVC];
    
    self.grassDelegate = [[LTGrassViewController alloc] init];
    [(UINavigationController *)self.window.rootViewController setDelegate:self.grassDelegate];
    
    // retrieve and store any remote notification data
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    // test whether application was launched from a push notification or not
    if (notificationPayload)
    {
        NSLog(@"App was launched from a push notification");
        
        // grab the capsuleId and check if the push was for a newly unearthed capsule
        NSString *capsuleId = [notificationPayload objectForKey:@"cid"];
        
        if (capsuleId.length > 0)
        {
            NSLog(@"Push was for newly unearthed capsule %@",capsuleId);
            
            // if user is logged in, send them through to the capsule from the push
            if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
                LTUnearthedViewController *unearthedStream = [[LTUnearthedViewController alloc] initWithStyle:UITableViewStylePlain];
                [(UINavigationController *)self.window.rootViewController pushViewController:unearthedStream animated:NO];
                [unearthedStream presentCapsule:capsuleId fromSelectedCell:nil];
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                if (currentInstallation.badge > 0) {
                    currentInstallation.badge--;
                    [currentInstallation saveEventually];
                    NSLog(@"decrementing badge number.  badges: %d",(int)currentInstallation.badge);
                }
            }
            
        }
        
    } else {
        NSLog(@"App was launched normally");
    }
    
    // add grass as subview of window
    [self.grassDelegate addToFrontOfView:self.window.rootViewController.view];
    
    // set app background to white
    self.window.backgroundColor = [UIColor whiteColor];
    
    // make and display window, MUST BE DONE BEFORE ADDING SUBVIEWS
    [self.window makeKeyAndVisible];
 
    return YES;
}

// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
                   sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    // application returned from a sign on attempt
    NSLog(@"session was returned form an SSO attempt through the webView");
BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session] fallbackHandler:^(FBAppCall *call) {
    if (!call)
    {
        NSLog(@"no call data");
    } else
    {
        NSLog(@"call %@",call);
    }
    }];
    
    if (wasHandled)
    {
        NSLog(@"URL: %@",url);
        NSLog(@"annotation: %@",(NSString *)(id)annotation);
        if ([FBAppCall appCallFromURL:url])
        {
        NSLog(@"FB APP CALL: %@",[[FBAppCall appCallFromURL:url] debugDescription]);
        }
    } else
    {
        NSLog(@"URL : %@",url);
        NSLog(@"annotation: %@",(NSString *)(id)annotation);
    }
    
    return wasHandled;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    //NSLog(@"becoming active, test passed for a current user, and one that is linked to fb, restoring session");
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    self.grassDelegate.appIsComingBackFromBackground = YES;
    
    // Because app is unaware of push notifications received while in the background, reload the unearthedview if up
    if ([[(UINavigationController *)self.window.rootViewController visibleViewController] isKindOfClass:[LTUnearthedViewController class]])
    {
        if (!self->initialLoad)
        {
            //NSLog(@"LTUnearthedViewController detected as current view controller... refreshing UI");
            // if so run the refresh method
            [(LTUnearthedViewController *)[(UINavigationController *)self.window.rootViewController visibleViewController] loadObjects];
            [(LTUnearthedViewController *)[(UINavigationController *)self.window.rootViewController visibleViewController] updateTitleWithNumberOfBuriedCapsules];
        }
    } else {
        NSLog(@"self.window.rootViewController.visibleViewController class:%@",[[(UINavigationController *)self.window.rootViewController visibleViewController] class]);
        NSLog(@"current state of PFFacebookUtils %@, current user: %@", [PFFacebookUtils session],[PFUser currentUser]);
    }
    
    if (self->initialLoad)
        self->initialLoad = NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    if ([PFUser currentUser])
    {
        [[PFFacebookUtils session] close];
    }
}

#pragma mark Push Notification Methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    NSLog(@"Push notitifications registered successfully, saving installation data to Parse");
    
    // Upon proper registration with push notifications, save the information to a Parse installation.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation addUniqueObject:@"global" forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    // on a class that uses this data [self loadInstallData]; must be envoked in the ViewDidLoad method
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    // this code is run is user denies push notifications or they're not supported
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}
/*
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    // This code runs when the application is not in the foreground
    [PFPush handlePush:userInfo]; // ask Parse to create the Modal View and display the alert contents
    
    if ([[(UINavigationController *)self.window.rootViewController visibleViewController] isKindOfClass:[LTUnearthedViewController class]])
    {
        NSLog(@"LTUnearthedViewController detected as current view controller... refreshing UI");
        // if so run the refresh method
        [(LTUnearthedViewController *)[(UINavigationController *)self.window.rootViewController visibleViewController] loadObjects];
    } else {
        NSLog(@"self.window.rootViewController.visibleViewController class:%@",[[(UINavigationController *)self.window.rootViewController visibleViewController] class]);
    }
    
}*/

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
    
    NSLog(@"Push notification received while app was open in background or foreground");
    NSLog(@"Push notification contents:%@",userInfo);
    // This code runs if the app is open and a push notification comes in
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        NSLog(@"Application is in foreground...");
        // Check if the visibleViewController is an LTUnearthedViewController
        if ([[(UINavigationController *)self.window.rootViewController visibleViewController] isKindOfClass:[LTUnearthedViewController class]])
        {
            NSLog(@"LTUnearthedViewController detected as current view controller... refreshing UI");
                // if the push is to increase the awaits counter or something has unearthed, run the refresh method on LTUnearthed
                [(LTUnearthedViewController *)[(UINavigationController *)self.window.rootViewController visibleViewController] updateTitleWithNumberOfBuriedCapsules];
            // if the capsule contains cid info then also upload the capsule list
            if ([[userInfo objectForKey:@"cid"] length] > 0)
                [(LTUnearthedViewController *)[(UINavigationController *)self.window.rootViewController visibleViewController] loadObjects];
        } else {
            NSLog(@"self.window.rootViewController.visibleViewController class:%@",[[(UINavigationController *)self.window.rootViewController visibleViewController] class]);
        }
    } else {
        NSLog(@"Application is in background...");
        // Check if the visibleViewController is an LTUnearthedViewController
        if ([[(UINavigationController *)self.window.rootViewController visibleViewController] isKindOfClass:[LTUnearthedViewController class]])
        {
                NSLog(@"LTUnearthedViewController detected as current view controller");
                  
                // grab the capsuleId and check if the push was for a newly unearthed capsule
                NSString *capsuleId = [userInfo objectForKey:@"cid"];
            
                // test for what type of push it is
                if (capsuleId.length > 0)
                {
                // if the push is an unearthed capsule present it to the user
                NSLog(@"Push was for newly unearthed capsule %@",capsuleId);
                NSLog(@"Presenting capsule view controller for the capsule in question");
                [(LTUnearthedViewController *)[(UINavigationController *)self.window.rootViewController visibleViewController] presentCapsule:capsuleId fromSelectedCell:nil];
                    
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    if (currentInstallation.badge > 0) {
                        currentInstallation.badge--;
                        [currentInstallation saveEventually];
                        NSLog(@"decrementing badge number.  badges: %d",(int)currentInstallation.badge);
                    }
                }
            } else {
            NSLog(@"self.window.rootViewController.visibleViewController class:%@",[[(UINavigationController *)self.window.rootViewController visibleViewController] class]);
            }
        }
        
    }

@end
