//
//  PBBedrock.h
//  PBBedrock
//
//  Created by Nick Bolton on 1/1/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#ifndef PBBedrock_PBBedrock_h
#define PBBedrock_PBBedrock_h

# define PBDebugLog(...) if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"debugMode"] boolValue] == YES) { NSLog(@"[%@:%d (%p)]: %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, self, [NSString stringWithFormat:__VA_ARGS__]); }

#if DEBUG
#define PBLog(...) NSLog(__VA_ARGS__)
#else
#define PBLog(...) do { } while (0)
#endif

// add -DTCDEBUG to Other C Flags for Debug

#define PBLogOff(...) do { } while (0)
#define PBLogOn(...) NSLog(__VA_ARGS__)

#import "NSString+PBFoundation.h"
#import "NSArray+PBFoundation.h"
#import "NSObject+PBFoundation.h"
#import "NSLayoutConstraint+PBFoundation.h"
#import "NSNotification+PBFoundation.h"
#import "PBDateRange.h"
#import "PBCalendarManager.h"
#import "NSDate+PBFoundation.h"

#if TARGET_OS_IPHONE
#import "PBActionDelegate.h"
#import "UIAlertView+PBFoundation.h"
#import "UIColor+PBFoundation.h"
#import "UIImage+PBFoundation.h"
#import "UIView+PBFoundation.h"
#import "UIButton+PBFoundation.h"
#import "UIBezierView.h"
#import "UIBezierButton.h"
#import "UINavigationController+PBFoundation.h"
#else

#endif

#define PBLoc(key) NSLocalizedString(key, nil)
#define PBLocalizedString(key, comment) NSLocalizedStringFromTableInBundle(key, @"pixelbleed", [NSBundle bundleForClass: [PBDummyClass class]], comment)

#endif
