//
//  PBGlobalConstants.m
//  CalendarDayView
//
//  Created by Nick Bolton on 2/1/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBGlobalConstants.h"

NSTimeInterval const kTCSTimerMinuteInSeconds = 60.0f;
NSTimeInterval const kTCSTimerHourInSeconds = kTCSTimerMinuteInSeconds * 60.0f;
NSTimeInterval const kTCSTimerMinimumDuration = 15.0f * kTCSTimerMinuteInSeconds;
NSTimeInterval const kTCSTimerDayInSeconds = 24.0f * kTCSTimerHourInSeconds;
NSTimeInterval const kTCSTimerAutoDeleteThreshold = 3.0f * kTCSTimerMinuteInSeconds;
NSTimeInterval const kTCSTimerAutoPromoteThreshold = 12.0f * kTCSTimerMinuteInSeconds;

@implementation PBGlobalConstants

@end
