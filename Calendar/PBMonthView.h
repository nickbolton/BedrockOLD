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

- (CGFloat)topOffset;
+ (CGFloat)topOffsetForWidth:(CGFloat)width month:(NSDate *)month;
+ (CGFloat)verticalOffsetForWidth:(CGFloat)width month:(NSDate *)month;

- (NSDateComponents *)dayAtPoint:(CGPoint)point;

@end