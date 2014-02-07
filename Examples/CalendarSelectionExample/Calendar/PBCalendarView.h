//
//  PBCalendarView.h
//  Calendar
//
//  Created by Nick Bolton on 1/19/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBDateRange;

@interface PBCalendarView : UIView

@property (nonatomic, readonly) NSInteger year;
@property (nonatomic, readonly) NSInteger month;
@property (nonatomic, strong) PBDateRange *selectedDateRange;

- (void)setYear:(NSInteger)year month:(NSInteger)month;
- (void)setYearAndMonthFromDate:(NSDate *)date;

- (NSDateComponents *)dateComponentsAtPoint:(CGPoint)point;
- (NSDateComponents *)nearestDateComponentsAtPoint:(CGPoint)point;
- (void)updateView;

@end
