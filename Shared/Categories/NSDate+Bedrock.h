//
//  NSDate+Bedrock.h
//  Bedrock
//
//  Created by Nick Bolton on 2/10/11.
//  Copyright 2011 Pixelbleed LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBDateRange.h"

enum _TimePeriod {
    TimePeriod_None = 0,
    TimePeriod_All,
    TimePeriod_Today,
    TimePeriod_ThisWeek,
    TimePeriod_ThisMonth,
    TimePeriod_ThisYear,
    TimePeriod_Yesterday,
    TimePeriod_LastWeek,
    TimePeriod_LastMonth,
    TimePeriod_LastYear,
    TimePeriod_PreviousWeek,
    TimePeriod_PreviousMonth,
    TimePeriod_PreviousYear,
    TimePeriod_OtherDay,
    TimePeriod_OtherDateRange,
    TimePeriod_Tomorrow,
};

typedef NSInteger TimePeriod;

@interface NSDate(Bedrock)

+ (PBDateRange *)today;
+ (NSDate *)dateWithYear:(NSInteger)year
                   month:(NSInteger)month
                     day:(NSInteger)day;
+ (NSDate *)dateWithYear:(NSInteger)year
                   month:(NSInteger)month
                     day:(NSInteger)day
                   hours:(NSInteger)hours
                 minutes:(NSInteger)minutes;

- (PBDateRange *)yesterday;
- (PBDateRange *)tomorrow;
- (PBDateRange *)thisWeek;
- (PBDateRange *)lastWeek;
- (PBDateRange *)nextWeek;
- (PBDateRange *)thisMonth;
- (PBDateRange *)lastMonth;
- (PBDateRange *)nextMonth;
- (PBDateRange *)thisYear;

- (BOOL)isMidnight;

- (BOOL)isWithinRange:(PBDateRange *)dateRange;

- (NSInteger)dayOfTheWeek;
- (NSInteger)dayOfTheMonth;
- (NSInteger)dayOfTheYear;
- (NSDate *)firstDayOfMonth;
- (NSDate *)lastDayOfMonth;
- (NSInteger)weekday;
- (NSDate *)dateByAddingWeeks:(NSInteger)weeks;
- (NSDate *)dateByAddingDays:(NSInteger)days;
- (NSDate *)dateByAddingSeconds:(NSTimeInterval)seconds;
- (NSDate *)dateByAddingComponents:(NSDateComponents *)components;
- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger;
- (NSDate *)midnight;
- (PBDateRange *)dateIntervalForTimePeriod:(TimePeriod)timePeriod;
- (NSInteger)dayOfTheWeek:(NSCalendar *)cal;
- (NSInteger)dayOfTheMonth:(NSCalendar *)cal;
- (NSInteger)dayOfTheYear:(NSCalendar *)cal;
- (NSDate *)dateByAddingDays:(NSInteger)days withCal:(NSCalendar *)cal;
- (NSDate *)dateByAddingSeconds:(NSTimeInterval)seconds withCal:(NSCalendar *)cal;
- (PBDateRange *)dateIntervalForTimePeriod:(TimePeriod)timePeriod withCal:(NSCalendar *)cal;
- (NSDate *)midnight:(NSCalendar *)cal;
- (NSDate *)endOfDay;
- (NSDate *)endOfDay:(NSCalendar *)cal;
+ (NSString *)labelForTimePeriod:(TimePeriod)timePeriod;
- (NSDateComponents *)components:(NSCalendarUnit)components;
- (NSDateComponents *)components:(NSCalendarUnit)components toDate:(NSDate *)date;

- (NSInteger)daysInBetweenDate:(NSDate *)date;

- (NSInteger)valueForCalendarUnit:(NSCalendarUnit)calendarUnit;

- (NSDate*)beginningOfWeek;
- (NSDate*)beginningOfWeekForDate:(NSDate *)date;

+ (NSString *)labelForDayOfTheWeek:(NSCalendarUnit)dayOfTheWeek;
+ (NSString *)labelForTime:(NSCalendarUnit)hour;

#if TARGET_OS_IPHONE
- (BOOL)isGreaterThan:(id)object;
- (BOOL)isLessThan:(id)object;
- (BOOL)isGreaterThanOrEqualTo:(id)object;
- (BOOL)isLessThanOrEqualTo:(id)object;
#endif

@end
