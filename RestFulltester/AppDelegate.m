//
//  AppDelegate.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 13/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "AppDelegate.h"
#import "SampleViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication*)application
didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SampleViewController *sampleViewController = [[SampleViewController alloc] initWithNibName:@"SampleViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:sampleViewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}
@end
