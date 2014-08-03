//
//  NSUserNotification+Bedrock.m
//  Bedrock
//
//  Created by Nick Bolton on 1/14/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSUserNotification+Bedrock.h"

@implementation NSUserNotification (Bedrock)

+ (void)postNotification:(NSString *)title
         informativeText:(NSString *)informativeText
                userInfo:(NSDictionary *)userInfo {
    NSUserNotification *notification = [[NSUserNotification alloc] init];

    notification.title = title;
    notification.informativeText = informativeText;
    notification.deliveryDate = [NSDate date];
    notification.soundName = NSUserNotificationDefaultSoundName;
    notification.userInfo = userInfo;

    [[NSUserNotificationCenter defaultUserNotificationCenter]
     deliverNotification:notification];
}

+ (void)postNotification:(NSString *)title
         informativeText:(NSString *)informativeText
                    icon:(NSImage *)icon
                userInfo:(NSDictionary *)userInfo {

    NSUserNotification *notification = [[NSUserNotification alloc] init];

    notification.title = title;
    notification.informativeText = informativeText;
    notification.deliveryDate = [NSDate date];
    notification.soundName = NSUserNotificationDefaultSoundName;
    notification.userInfo = userInfo;

    [[NSUserNotificationCenter defaultUserNotificationCenter]
     deliverNotification:notification];
}

+ (void)postNotification:(NSString *)title
         informativeText:(NSString *)informativeText {
    [self postNotification:title informativeText:informativeText userInfo:nil];
}

@end
