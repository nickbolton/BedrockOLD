//
//  PBAppDelegate.m
//  CalendarDayView
//
//  Created by Nick Bolton on 2/1/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBAppDelegate.h"
#import "PBCalendarDayViewController.h"

@implementation PBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSDate *today = [[NSDate date] midnight];

    PBCalendarDayViewController *viewController =
    [[PBCalendarDayViewController alloc] init];
    viewController.dayDate = today;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
