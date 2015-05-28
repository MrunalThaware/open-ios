//
//  AppDelegate.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 04/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "AppDelegate.h"
#import "SimpleStartViewController.h"
#import "PrepaidViewController.h"

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor colorWithRed:236.0f/255.0 green:236.0f/255.0 blue:236.0f/255.0 alpha:1.0f];
    
#if defined (Bind_SDK)
    SimpleStartViewController *viewController = [[SimpleStartViewController alloc] initWithNibName:@"SimpleStartViewController" bundle:nil];
#elif defined (Prepaid_SDK)
    PrepaidViewController *viewController = [[PrepaidViewController alloc] initWithNibName:@"PrepaidViewController" bundle:nil];
#endif
    
    // add into nav contoller
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.window makeKeyAndVisible];
    return YES;
}
@end
