//
//  NSCalendar+Bedrock.m
//  Calendar
//
//  Created by Nick Bolton on 1/20/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "NSCalendar+Bedrock.h"

@implementation NSCalendar (Bedrock)

- (NSInteger)daysWithinEraFromDate:(NSDate *)startDate
                            toDate:(NSDate *)endDate {

    NSInteger startDay =
    [self
     ordinalityOfUnit:NSDayCalendarUnit
     inUnit: NSEraCalendarUnit
     forDate:startDate];

    NSInteger endDay =
    [self
     ordinalityOfUnit:NSDayCalendarUnit
     inUnit:NSEraCalendarUnit
     forDate:endDate];

    return endDay-startDay;
}

@end
