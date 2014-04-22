//
//  PBMonthView.h
//  Calendar
//
//  Created by Nick Bolton on 1/19/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBCalendarView;

#define TUMonthLabelFont [UIFont boldSystemFontOfSize:16.0]
#define TUMonthBoundaryLineColor [UIColor darkGrayColor]

@interface PBMonthView : UIView

@property (nonatomic, weak) PBCalendarView *calendarView;
@property (nonatomic, strong) NSDate *month;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, readonly) NSDateComponents *monthComponents;
@property (nonatomic) BOOL startPointHidden;
@property (nonatomic) BOOL endPointHidden;
@property (nonatomic) BOOL withinRangeBackgroundHidden;
@property (nonatomic, readonly) NSInteger daysInMonth;
@property (nonatomic, strong) UIColor *separatorColor;

- (CGFloat)topOffset;
+ (CGFloat)topOffsetForWidth:(CGFloat)width month:(NSDate *)month;
+ (CGFloat)verticalOffsetForWidth:(CGFloat)width month:(NSDate *)month;

- (NSDateComponents *)dayAtPoint:(CGPoint)point;
- (NSDateComponents *)nearestDayAtPoint:(CGPoint)point;

- (CGPoint)pointForStartingMarkerView;
- (CGPoint)pointForEndingMarkerView;

@end
