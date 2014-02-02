//
//  NSDateComponents+Bedrock.m
//  Calendar
//
//  Created by Nick Bolton on 2/2/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "NSDateComponents+Bedrock.h"

@implementation NSDateComponents (Bedrock)

+ (NSDateComponents *)components:(NSCalendarUnit)components
                        fromDate:(NSDate *)date {

    NSCalendar *calendar =
    [[PBCalendarManager sharedInstance] calendarForCurrentThread];

    return
    [calendar
     components:components
     fromDate:date];
}

@end
