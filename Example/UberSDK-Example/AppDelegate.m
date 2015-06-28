//
//  AppDelegate.m
//  UberSDK-Example
//
//  Copyright (c) 2015 Uber Technologies, Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "UBEndpointsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UBEndpointsViewController *viewController = [[UBEndpointsViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
