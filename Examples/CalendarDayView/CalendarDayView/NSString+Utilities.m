//
//  NSString+Utilities.m
//  Sometime
//
//  Created by Nick Bolton on 12/1/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

+ (NSString *)durationTextForDuration:(NSTimeInterval)duration
                            startTime:(NSDate *)startTime
                               active:(BOOL)active {

    NSTimeInterval timeInterval = round(duration);

    if (timeInterval <= 0.0f) {
        timeInterval = 0.0f;
    }

    NSCalendar *calendar =
    [[PBCalendarManager sharedInstance] calendarForCurrentThread];

    NSDate *endTime = [startTime dateByAddingTimeInterval:timeInterval];

    NSDateComponents *dateComponents =
    [calendar
     components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
     fromDate:startTime
     toDate:endTime
     options:0];

    NSInteger hours = dateComponents.hour;
    NSInteger minutes = dateComponents.minute;
    NSInteger seconds = dateComponents.second;
    NSInteger days = dateComponents.day;
    NSInteger years = dateComponents.year;
    NSInteger months = dateComponents.month;

    if (years > 0) {

        if (years == 1 && months == 0 && days == 0 && hours == 0 && minutes == 0 && seconds == 0) {
            return [NSString stringWithFormat:PBLoc(@"%dy"), 1];
        }

        NSDateComponents *yearComponents = [[NSDateComponents alloc] init];
        yearComponents.year = years;

        NSDate *remainingDaysDate =
        [calendar
         dateByAddingComponents:yearComponents
         toDate:startTime
         options:0];

        NSDateComponents *dayComponents =
        [calendar
         components:NSCalendarUnitDay
         fromDate:remainingDaysDate
         toDate:endTime
         options:0];

        NSInteger reminderDays = dayComponents.day;

        NSTimeInterval yearFraction = reminderDays / 364.0f;

        if (yearFraction >= 1.0f) {
            years++;
            return [NSString stringWithFormat:PBLoc(@"%ldy"), (long)years];
        }

        BOOL hasFraction = yearFraction != ceilf(yearFraction);

        timeInterval = years + yearFraction;

        if (hasFraction) {
            return [NSString stringWithFormat:PBLoc(@"%.2fy"), timeInterval];
        } else {
            return [NSString stringWithFormat:PBLoc(@"%.0fy"), timeInterval];
        }
    }

    if (months > 0) {

        if (months == 1 && days == 0 && hours == 0 && minutes == 0 && seconds == 0) {
            return [NSString stringWithFormat:PBLoc(@"%dm"), 1];
        }

        NSTimeInterval monthFraction = days / 31.0;

        BOOL hasFraction = monthFraction != ceilf(monthFraction);

        timeInterval = months + monthFraction;

        if (hasFraction) {
            return [NSString stringWithFormat:PBLoc(@"%.2fm"), timeInterval];
        } else {
            return [NSString stringWithFormat:PBLoc(@"%.0fm"), timeInterval];
        }
    }

    if (days > 0) {

        if (days == 1 && hours == 0 && minutes == 0 && seconds == 0) {
            return [NSString stringWithFormat:PBLoc(@"%dd"), 1];
        }

        NSTimeInterval elapsedTime = timeInterval / kTCSTimerDayInSeconds;

        BOOL hasFraction = elapsedTime != ceilf(elapsedTime);

        if (hasFraction) {
            return [NSString stringWithFormat:PBLoc(@"%.2fd"), timeInterval / kTCSTimerDayInSeconds];
        } else {
            return [NSString stringWithFormat:PBLoc(@"%.0fd"), timeInterval / kTCSTimerDayInSeconds];
        }
    }

    if (hours > 0) {

        if (hours == 1 && minutes == 0 && seconds == 0) {
            return [NSString stringWithFormat:PBLoc(@"%dh"), 1];
        }

        NSTimeInterval elapsedTime = timeInterval / kTCSTimerHourInSeconds;

        BOOL hasFraction = elapsedTime != ceilf(elapsedTime);

        if (hasFraction) {
            return [NSString stringWithFormat:PBLoc(@"%.2fh"), timeInterval / kTCSTimerHourInSeconds];
        } else {
            return [NSString stringWithFormat:PBLoc(@"%.0fh"), timeInterval / kTCSTimerHourInSeconds];
        }
    }

    if (minutes > 0) {

        if (minutes == 1 && seconds == 0) {
            return [NSString stringWithFormat:PBLoc(@"%dm"), 1];
        }

        NSTimeInterval elapsedTime = timeInterval / kTCSTimerMinuteInSeconds;

        BOOL hasFraction = elapsedTime != ceilf(elapsedTime);

        if (hasFraction) {
            return [NSString stringWithFormat:PBLoc(@"%.2fm"), timeInterval / kTCSTimerMinuteInSeconds];
        } else {
            return [NSString stringWithFormat:PBLoc(@"%.0fm"), timeInterval / kTCSTimerMinuteInSeconds];
        }
    }
    
    return [NSString stringWithFormat:PBLoc(@"%lds"), (long)seconds];
}

@end
