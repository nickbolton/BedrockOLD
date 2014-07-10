//
//  PBAppDelegate.m
//  PBEmitterViewControllerListExample
//
//  Created by Nick Bolton on 1/6/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBAppDelegate.h"
#import "PBViewController.h"

@implementation PBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    PBViewController *viewController = [[PBViewController alloc] init];

    UINavigationController *navigationViewController =
    [[UINavigationController alloc]
     initWithRootViewController:viewController];

    self.window.rootViewController = navigationViewController;

    [self.window makeKeyAndVisible];

    return YES;
}

@end
