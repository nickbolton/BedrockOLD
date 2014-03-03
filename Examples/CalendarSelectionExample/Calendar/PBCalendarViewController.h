//
//  PBCalendarViewController.h
//  Calendar
//
//  Created by Nick Bolton on 1/19/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "Emitter.h"

@class PBDateRange;

@interface PBCalendarViewController : PBListViewController

- (id)initWithSelectedDateRange:(PBDateRange *)dateRange;
- (id)initWithCurrentStartDate:(NSDate *)date;

@property (nonatomic) UIEdgeInsets separatorInsets;

@end
