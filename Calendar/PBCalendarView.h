//
//  PBCalendarView.h
//  Calendar
//
//  Created by Nick Bolton on 2/8/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBCalendarView;

@protocol PBCalendarViewDelegate <UIScrollViewDelegate>

@optional
- (void)calendarViewSelected:(PBCalendarView *)calendarView
      selectedRangeDidChange:(PBDateRange *)dateRange;

@end

@interface PBCalendarView : UIScrollView

@property (nonatomic, strong) PBDateRange *selectedDateRange;
@property (nonatomic) CGRect visibleBounds;
@property (nonatomic) UIEdgeInsets contentMargins;
@property (nonatomic) BOOL endPointMarkersHidden;

- (void)scrollToMonth:(NSDate *)month;
- (void)scrollToMonth:(NSDate *)month animated:(BOOL)animated;
- (void)centerCurrentMonth;
- (void)scrollToMonthAtPoint:(CGPoint)point;
- (NSDate *)dateAtPoint:(CGPoint)point;
- (NSDate *)nearestDateAtPoint:(CGPoint)point;
- (CGPoint)endPointMarkingInCalendar:(BOOL)isStartDate;
- (CGPoint)centeredContentOffsetAtPoint:(CGPoint)point;
- (NSDate *)monthAtPoint:(CGPoint)point;
- (NSDate *)currentMonth;
- (NSArray *)monthViewsBoundByRect:(CGRect)rect
                            inView:(UIView *)view
                 completelyVisible:(BOOL)completelyVisible;

@end
