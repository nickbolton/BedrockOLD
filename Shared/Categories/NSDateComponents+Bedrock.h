//
//  NSDateComponents+Bedrock.h
//  Calendar
//
//  Created by Nick Bolton on 2/2/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateComponents (Bedrock)

+ (NSDateComponents *)components:(NSCalendarUnit)components
                        fromDate:(NSDate *)date;

@end
