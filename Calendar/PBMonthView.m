//
//  PBMonthView.m
//  Calendar
//
//  Created by Nick Bolton on 1/19/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBMonthView.h"
#import "PBCalendarView.h"

static CGFloat const kPBMonthViewSeparatorLeftInset = 15.0f;
//static CGFloat const kPBMonthViewItemWidth = 44.0f;
static CGFloat const kPBMonthViewItemMargin= .5f;
static CGFloat const kPBMonthViewItemHeight = 36.0f;
static CGFloat const kPBMonthViewTopSpace = 42.0f;
static CGFloat const kPBMonthViewBottomSpace = 7.5f;
static CGFloat const kPBMonthViewEndPointRadius = 16.0f;
static CGFloat const kPBMonthViewDayTextTopSpace = 6.0f;

@interface PBMonthView () {
}

@property (nonatomic, readonly) CGPoint topLeftPoint;
@property (nonatomic, readonly) CGPoint bottomRightPoint;
@property (nonatomic, readonly) NSInteger firstDayOffset;
@property (nonatomic, readonly) NSInteger lastDayOffset;
@property (nonatomic, strong) NSString *monthTitle;
@property (nonatomic) CGRect monthTitleRect;
@property (nonatomic, strong) UIFont *monthTitleFont;
@property (nonatomic, strong) UIFont *dayFont;
@property (nonatomic, strong) UIFont *todayFont;
@property (nonatomic, strong) NSDictionary *monthTitleAttributes;
@property (nonatomic, strong) NSDictionary *weekdayAttributes;
@property (nonatomic, strong) NSDictionary *weekendAttributes;
@property (nonatomic, strong) NSDictionary *todayAttributes;
@property (nonatomic, strong) NSDictionary *selectedDayAttributes;
@property (nonatomic, strong) NSDictionary *selectedTodayAttributes;
@property (nonatomic, strong) UIColor *withinRangeBackgroundColor;
@property (nonatomic, readwrite) NSDateComponents *monthComponents;
@property (nonatomic, readwrite) NSInteger daysInMonth;
@property (nonatomic) CGPoint startingMarkerPoint;
@property (nonatomic) CGPoint endingMarkerPoint;
@property (nonatomic, readonly) CGFloat itemWidth;

@end

@implementation PBMonthView

#pragma mark - Properties

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor {
    
    _weekdayTextColor = weekdayTextColor;
    _monthTitleAttributes = nil;
    _todayAttributes = nil;
    _selectedDayAttributes = nil;
    _selectedTodayAttributes = nil;
    _weekdayAttributes = nil;
}

- (void)setWeekendTextColor:(UIColor *)weekendTextColor {
    _weekendTextColor = weekendTextColor;
    _weekendAttributes = nil;
}

- (void)setMonth:(NSDate *)month {

    self.monthComponents =
    [month components:NSCalendarUnitYear|NSCalendarUnitMonth];
    self.monthComponents.day = 1;

    self.daysInMonth =
    [month
     rangeOfUnit:NSCalendarUnitDay
     inUnit:NSCalendarUnitMonth].length;

	_month =
    [NSDate
     dateWithYear:self.monthComponents.year
     month:self.monthComponents.month
     day:1];

    [self updateMonthTitle];
	_firstDayOffset = -100;
	_lastDayOffset = -100;
	[self sizeToFit];
	[self setNeedsDisplay];
}

- (UIFont *)monthTitleFont {

    if (_monthTitleFont == nil) {
        _monthTitleFont = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    }

    return  _monthTitleFont;
}

- (UIFont *)dayFont {

    if (_dayFont == nil) {
        _dayFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
    }

    return _dayFont;
}

- (UIFont *)todayFont {

    if (_todayFont == nil) {
        _todayFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    }

    return _todayFont;
}

- (NSDictionary *)monthTitleAttributes {

    if (_monthTitleAttributes == nil) {

        _monthTitleAttributes =
        @{
          NSFontAttributeName : self.monthTitleFont,
          NSForegroundColorAttributeName : self.weekdayTextColor,
          };
    }

    return _monthTitleAttributes;
}

- (NSDictionary *)todayAttributes {

    if (_todayAttributes == nil) {

        NSMutableParagraphStyle *paragraphStyle =
        [[NSMutableParagraphStyle alloc] init];

        paragraphStyle.alignment = NSTextAlignmentCenter;

        _todayAttributes =
        @{
          NSFontAttributeName : self.todayFont,
          NSForegroundColorAttributeName : self.weekdayTextColor,
          NSParagraphStyleAttributeName : paragraphStyle,
          };
    }

    return _todayAttributes;
}

- (NSDictionary *)selectedDayAttributes {

    if (_selectedDayAttributes == nil) {

        NSMutableParagraphStyle *paragraphStyle =
        [[NSMutableParagraphStyle alloc] init];

        paragraphStyle.alignment = NSTextAlignmentCenter;

        _selectedDayAttributes =
        @{
          NSFontAttributeName : self.dayFont,
          NSForegroundColorAttributeName : [UIColor whiteColor],
          NSParagraphStyleAttributeName : paragraphStyle,
          };
    }

    return _selectedDayAttributes;
}

- (NSDictionary *)selectedTodayAttributes {

    if (_selectedTodayAttributes == nil) {

        NSMutableParagraphStyle *paragraphStyle =
        [[NSMutableParagraphStyle alloc] init];

        paragraphStyle.alignment = NSTextAlignmentCenter;

        _selectedTodayAttributes =
        @{
          NSFontAttributeName : self.todayFont,
          NSForegroundColorAttributeName : [UIColor whiteColor],
          NSParagraphStyleAttributeName : paragraphStyle,
          };
    }

    return _selectedTodayAttributes;
}

- (NSDictionary *)weekdayAttributes {

    if (_weekdayAttributes == nil) {

        NSMutableParagraphStyle *paragraphStyle =
        [[NSMutableParagraphStyle alloc] init];

        paragraphStyle.alignment = NSTextAlignmentCenter;

        _weekdayAttributes =
        @{
          NSFontAttributeName : self.dayFont,
          NSForegroundColorAttributeName : self.weekdayTextColor,
          NSParagraphStyleAttributeName : paragraphStyle,
          };
    }
    
    return _weekdayAttributes;
}

- (NSDictionary *)weekendAttributes {
    
    if (_weekendAttributes == nil) {
        
        NSMutableParagraphStyle *paragraphStyle =
        [[NSMutableParagraphStyle alloc] init];
        
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        _weekendAttributes =
        @{
          NSFontAttributeName : self.dayFont,
          NSForegroundColorAttributeName : self.weekendTextColor,
          NSParagraphStyleAttributeName : paragraphStyle,
          };
    }
    
    return _weekendAttributes;
}

- (UIColor *)withinRangeBackgroundColor {

    if (_withinRangeBackgroundColor == nil) {
        _withinRangeBackgroundColor = [self.tintColor colorWithAlpha:.3f];
    }

    return _withinRangeBackgroundColor;
}

- (UIColor *)unsaturatedColor:(UIColor *)color {
    
    CGFloat hue;
    CGFloat brightness;
    CGFloat saturation = .3f;
    
    [color
     getHue:&hue
     saturation:NULL
     brightness:&brightness
     alpha:NULL];
    
    color =
    [UIColor
     colorWithHue:hue
     saturation:saturation
     brightness:brightness
     alpha:1.0f];
    
    return color;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self commonInit];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self != nil) {
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    
    self.backgroundColor = [UIColor whiteColor];
    self.weekdayTextColor = [UIColor blackColor];
    self.weekendTextColor = [UIColor grayColor];
    self.opaque = NO;
    self.month = [NSDate date];
}

#pragma mark - Sizing

- (CGFloat)itemWidth {
    return (CGRectGetWidth(self.frame) - (2.0f * kPBMonthViewItemMargin)) / [NSCalendar numberOfDaysInWeek];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];

	_firstDayOffset = -100;
	_lastDayOffset = -100;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	NSInteger weeks =
    [self.month
     rangeOfUnit:NSWeekCalendarUnit
     inUnit:NSMonthCalendarUnit].length;

	size.height = kPBMonthViewItemHeight * weeks + kPBMonthViewTopSpace + kPBMonthViewBottomSpace;

	return size;
}

#pragma mark - Geometry

- (CGFloat)topOffset
{
	return self._topLeftPoint.y;
}

+ (CGFloat)verticalOffsetForWidth:(CGFloat)width month:(NSDate *)month {

	NSInteger weeks =
    [month
     rangeOfUnit:NSWeekCalendarUnit
     inUnit:NSMonthCalendarUnit].length;

	CGFloat offset = kPBMonthViewItemHeight * weeks + kPBMonthViewTopSpace + kPBMonthViewBottomSpace;

	return offset;
}

- (NSInteger)_firstDayOffset
{
	if (_firstDayOffset == -100) {
		_firstDayOffset = self.month.firstDayOfMonth.weekday - [[NSCalendar calendarForCurrentThread] firstWeekday];
	}

	return _firstDayOffset;
}

- (NSInteger)_lastDayOffset
{
	if (_lastDayOffset == -100) {
		_lastDayOffset = self.month.lastDayOfMonth.weekday - [[NSCalendar calendarForCurrentThread] firstWeekday];
	}

	return _lastDayOffset;
}

- (CGPoint)_topLeftPoint
{
	CGPoint point = CGPointMake(kPBMonthViewSeparatorLeftInset, 0.0);
	if ([self _firstDayOffset] != 0) {
		point.y += kPBMonthViewItemHeight;
	}

	return point;
}

- (CGPoint)_bottomRightPoint
{
	CGPoint point = CGPointMake(self.bounds.size.width-kPBMonthViewItemMargin, self.bounds.size.height);
	NSInteger numberOfDays = [NSCalendar numberOfDaysInWeek];
	NSInteger lastDayOffset = [self _lastDayOffset];
	if (lastDayOffset != numberOfDays - 1) {
		point.y -= kPBMonthViewItemHeight;
	}

	return point;
}

- (NSDateComponents *)dayAtPoint:(CGPoint)point {
    return [self dayAtPoint:point endPointsOnly:NO];
}

- (NSDateComponents *)startOrEndPointAtPoint:(CGPoint)point {
    return [self dayAtPoint:point endPointsOnly:YES];
}

- (NSDateComponents *)dayAtPoint:(CGPoint)point endPointsOnly:(BOOL)endPointsOnly {

    static CGFloat const touchPadding = 20.0f;
    
	__block NSDateComponents *dayComponents = nil;
    __block CGFloat distanceToNearestDay = MAXFLOAT;

	[self _enumerateDays:^(NSDateComponents *day, CGRect dayRect, BOOL *stop) {
        
        CGRect expandedRect = dayRect;
        expandedRect.origin.x -= touchPadding;
        expandedRect.origin.y -= touchPadding;
        expandedRect.size.width += 2.0f * touchPadding;
        expandedRect.size.height += 2.0f * touchPadding;
        
        BOOL endPointCriteria =
        endPointsOnly == NO ||
        [self isStartingDay:day] ||
        [self isEndingDay:day];
        
		if (CGRectContainsPoint(expandedRect, point) &&
            endPointCriteria) {
            
            CGPoint midPoint =
            CGPointMake(CGRectGetMidX(dayRect), CGRectGetMidY(dayRect));
            
            CGFloat xDelta = midPoint.x - point.x;
            CGFloat yDelta = midPoint.y - point.y;
            
            CGFloat distanceSquared =
            (xDelta * xDelta) + (yDelta * yDelta);
            
            if (dayComponents == nil ||
                distanceSquared < distanceToNearestDay) {
                
                dayComponents = [day copy];
                distanceToNearestDay = distanceSquared;
            }
		}
	}];

	return dayComponents;
}

- (CGPoint)midpointOfRect:(CGRect)rect {

    CGPoint midpoint;
    midpoint.x = CGRectGetMidX(rect);
    midpoint.y = CGRectGetMidY(rect);
    return midpoint;
}

- (NSDateComponents *)nearestDayAtPoint:(CGPoint)point {

    static CGFloat const padding = 5.0f;

    NSMutableArray *days = [NSMutableArray array];
    NSMutableArray *dayRects = [NSMutableArray array];

    __block NSDateComponents *firstDay = nil;
    __block NSDateComponents *lastDay = nil;
    __block CGRect firstDayRect;
    __block CGRect lastDayRect;

	[self _enumerateDays:^(NSDateComponents *day, CGRect dayRect, BOOL *stop) {

        if (firstDay == nil) {
            firstDay = [day copy];
            firstDayRect = dayRect;
        }

        lastDay = [day copy];
        lastDayRect = dayRect;

        CGFloat xMargins = kPBMonthViewItemMargin;
        CGFloat yMargins = padding + (kPBMonthViewItemHeight - CGRectGetHeight(dayRect)) / 2.0f;

        CGFloat widthDelta = self.itemWidth - CGRectGetWidth(dayRect);

        CGRect expandedRect = dayRect;
        expandedRect.origin.x -= xMargins + widthDelta / 2.0f;
        expandedRect.size.width = self.itemWidth;
        expandedRect.origin.y -= yMargins;
        expandedRect.size.height += yMargins * 2.0f;

		if (CGRectContainsPoint(expandedRect, point)) {

            [days addObject:[day copy]];
            [dayRects addObject:[NSValue valueWithCGRect:dayRect]];
		}
	}];

    NSDateComponents *dayComponents = nil;

    CGFloat minDistance = MAXFLOAT;

    NSInteger index = 0;

    for (NSValue *rectValue in dayRects) {

        CGRect rect = rectValue.CGRectValue;
        CGPoint midpoint = [self midpointOfRect:rect];

        CGFloat xDelta = point.x - midpoint.x;
        CGFloat yDelta = point.y - midpoint.y;

        CGFloat distanceSquared = (xDelta * xDelta) + (yDelta * yDelta);

        if (distanceSquared < minDistance) {
            minDistance = distanceSquared;
            dayComponents = days[index];
        }

        index++;
    }

    if (dayComponents == nil) {

        CGPoint midpoint = [self midpointOfRect:firstDayRect];

        CGFloat xDelta = point.x - midpoint.x;
        CGFloat yDelta = point.y - midpoint.y;
        
        CGFloat distanceToFirstDay = fabs(yDelta);

        midpoint = [self midpointOfRect:lastDayRect];

        xDelta = point.x - midpoint.x;
        yDelta = point.y - midpoint.y;

        CGFloat distanceToLastDay = fabs(yDelta);

        if (distanceToFirstDay <= distanceToLastDay) {

            dayComponents = firstDay;

        } else {

            dayComponents = lastDay;
        }
    }

	return dayComponents;
}

#pragma mark - End Points

- (CGPoint)pointForStartingMarkerView {
    return self.startingMarkerPoint;
}

- (CGPoint)pointForEndingMarkerView {
    return self.endingMarkerPoint;
}

- (BOOL)isWeekday:(NSDateComponents *)day {
    
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:day];
    
    NSInteger weekday = date.weekday;
    
    return weekday > 1 && weekday < 7;
}

- (BOOL)isStartingDay:(NSDateComponents *)day {

    NSDateComponents *components =
    [self.calendarView.selectedDateRange.startDate
     components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay];
    return [components isEqual:day];
}

- (BOOL)isEndingDay:(NSDateComponents *)day {

    NSDateComponents *components =
    [self.calendarView.selectedDateRange.endDate
     components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay];
    return [components isEqual:day];
}

#pragma mark -

- (void)updateMonthTitle {

    NSLocale *locale = [NSLocale currentLocale];

    NSString *dateComponents = @"MMMMy";

    NSString *dateFormat =
    [NSDateFormatter
     dateFormatFromTemplate:dateComponents
     options:0
     locale:locale];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    dateFormatter.locale = locale;

    self.monthTitle = [dateFormatter stringFromDate:self.month];

    CGRect rect =
    [self.monthTitle
     boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT)
     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
     attributes:self.monthTitleAttributes
     context:nil];

    self.monthTitleRect = CGRectOffset(rect, 15.0f, 16.0f);
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
//    [self _drawBackground];
    [self _drawDivider];
    [self _drawMonthTitle];
	[self _drawDays];
}

- (BOOL)isPoint:(CGPoint)point inColumn:(NSInteger)column {

    CGFloat diameter = kPBMonthViewEndPointRadius * 2.0f;
    CGFloat leftSpace = (self.itemWidth - diameter) / 2.0f;

    CGRect dayRect;
	dayRect.origin.x = kPBMonthViewItemMargin + (column * self.itemWidth) + leftSpace;
	dayRect.size = CGSizeMake(self.itemWidth, diameter);

    return point.x >= CGRectGetMinX(dayRect) && point.x <= CGRectGetMaxX(dayRect);
}

- (void)_enumerateDays:(void(^)(NSDateComponents *day, CGRect dayRect, BOOL *stop))dayBlock
{

    CGFloat diameter = kPBMonthViewEndPointRadius * 2.0f;

    CGFloat topSpace = (kPBMonthViewItemHeight - diameter) / 2.0f;
    CGFloat leftSpace = (self.itemWidth - diameter) / 2.0f;

	NSRange weeks = [[NSCalendar calendarForCurrentThread] rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.month];
	NSRange days = [[NSCalendar calendarForCurrentThread] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.month];
    
	NSDateComponents *day = [[NSCalendar calendarForCurrentThread] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self.month];
	day.day = days.location;
	CGRect dayRect;
    
    NSInteger firstDayOffset = [self _firstDayOffset];
    
    if (firstDayOffset < 0) {
        weeks = NSMakeRange(weeks.location-1, weeks.length+1);
        firstDayOffset = 7 + firstDayOffset;
    }
	dayRect.origin.x = kPBMonthViewItemMargin + (firstDayOffset * self.itemWidth) + leftSpace;
	dayRect.size = CGSizeMake(diameter, diameter);
	BOOL stop = NO;
    
    NSInteger column = firstDayOffset;

	for (NSInteger week = 0; week < weeks.length && !stop; week++) {
		dayRect.origin.y = week * kPBMonthViewItemHeight + kPBMonthViewTopSpace + topSpace;

		while (column < [NSCalendar numberOfDaysInWeek] && day.day < days.location + days.length && !stop) {
			dayBlock(day, dayRect, &stop);
			dayRect.origin.x += self.itemWidth;
			day.day++;
            column++;
		}

		dayRect.origin.x = kPBMonthViewItemMargin + leftSpace;
        column = 0.0f;
	}
}

- (void)_drawBackground {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [self.backgroundColor setFill];
    
    UIRectFill(self.bounds);
    
    CGContextRestoreGState(context);
}

- (void)_drawDivider {

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    UIColor *lineColor = self.separatorColor;
    [lineColor setFill];

    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat height = 1.0f / scale;

    CGRect rect =
    CGRectMake(kPBMonthViewSeparatorLeftInset,
               0.0f,
               CGRectGetWidth(self.frame) - kPBMonthViewSeparatorLeftInset,
               height);

    UIRectFill(rect);

    CGContextRestoreGState(context);
}

- (void)_drawMonthTitle {

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    [self.monthTitle drawInRect:self.monthTitleRect withAttributes:self.monthTitleAttributes];

    CGContextRestoreGState(context);
}

- (void)_drawDays
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	NSDateComponents *today = [[NSCalendar calendarForCurrentThread] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
	NSDateComponents *month = [[NSCalendar calendarForCurrentThread] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self.month];

    self.startingMarkerPoint = CGPointZero;
    self.endingMarkerPoint = CGPointZero;

	[self _enumerateDays:^(NSDateComponents *day, CGRect dayRect, BOOL *stop) {
		CGContextSaveGState(context);

		NSString *dayString = [NSString stringWithFormat:@"%d", day.day];
        NSDictionary *textAttributes;

		BOOL isToday = month.year == today.year && month.month == today.month && day.day == today.day;
        BOOL isStartingDay = [self isStartingDay:day];
        BOOL isEndingDay = [self isEndingDay:day];

        CGPoint endPointOrigin = dayRect.origin;
        endPointOrigin.x -= CGRectGetWidth(dayRect) / 2.0f;
        endPointOrigin.y -= CGRectGetHeight(dayRect) / 2.0f;

        if (isStartingDay) {
            self.startingMarkerPoint = endPointOrigin;
        }

        if (isEndingDay) {
            self.endingMarkerPoint = endPointOrigin;
        }

        BOOL showEndPoint =
        (isStartingDay && self.startPointHidden == NO) ||
        (isEndingDay && self.endPointHidden == NO);

        BOOL withinRange =
        self.withinRangeBackgroundHidden == NO &&
        [self.calendarView.selectedDateRange componentsWithinRange:day];

		if (isToday) {
            if (showEndPoint) {
                textAttributes = self.selectedTodayAttributes;
            } else {
                textAttributes = self.todayAttributes;
            }
        } else {
            if (showEndPoint) {
                textAttributes = self.selectedDayAttributes;
            } else {
                if ([self isWeekday:day]) {
                    textAttributes = self.weekdayAttributes;
                } else {
                    textAttributes = self.weekendAttributes;
                }
            }
        }

        if (withinRange &&
            ((isStartingDay == NO && isEndingDay == NO) ||
             (isStartingDay != isEndingDay))) {

            UIBezierPath *bezierPath = nil;
            CGRect fillRect = dayRect;

            CGFloat margins =
            (self.itemWidth - CGRectGetWidth(dayRect)) / 2.0f;

            CGPoint dayRectMidpoint = [self midpointOfRect:dayRect];

            if (isStartingDay && isEndingDay) {

                bezierPath = [UIBezierPath bezierPathWithOvalInRect:dayRect];

            } else if (isStartingDay) {

                fillRect.origin.x += CGRectGetWidth(fillRect) / 2.0f;
                fillRect.size.width = CGRectGetWidth(fillRect) / 2.0f;
                fillRect.size.width += margins;

                if (day.day == self.daysInMonth || [self isPoint:dayRectMidpoint inColumn:[NSCalendar numberOfDaysInWeek]-1]) {
                    fillRect.size.width = CGRectGetMaxX(self.frame) - CGRectGetMinX(fillRect);
                }

                bezierPath = [UIBezierPath bezierPathWithRect:fillRect];

                UIBezierPath *rectPath = [UIBezierPath bezierPathWithOvalInRect:dayRect];
                [bezierPath appendPath:rectPath];

            } else if (isEndingDay) {

                fillRect.origin.x -= margins;
                fillRect.size.width = CGRectGetWidth(dayRect) / 2.0f;
                fillRect.size.width += margins;

                if (day.day == 1 || [self isPoint:dayRectMidpoint inColumn:0]) {

                    CGFloat minX = CGRectGetMinX(fillRect);
                    fillRect.origin.x = 0.0f;
                    fillRect.size.width += minX;
                }

                bezierPath = [UIBezierPath bezierPathWithRect:fillRect];

                UIBezierPath *rectPath = [UIBezierPath bezierPathWithOvalInRect:dayRect];
                [bezierPath appendPath:rectPath];

            } else {

                fillRect.origin.x -= margins;
                fillRect.size.width += margins * 2.0f;
                
                if (day.day == 1) {

                    CGFloat minX = CGRectGetMinX(fillRect);
                    fillRect.origin.x = 0.0f;
                    fillRect.size.width += minX;

                    if ([self isPoint:dayRectMidpoint inColumn:[NSCalendar numberOfDaysInWeek]-1]) {
                        fillRect.size.width = CGRectGetMaxX(self.frame) - CGRectGetMinX(fillRect);
                    }

                } else if ([self isPoint:dayRectMidpoint inColumn:[NSCalendar numberOfDaysInWeek]-1]) {

                    fillRect.size.width = CGRectGetMaxX(self.frame) - CGRectGetMinX(fillRect);
                    
                } else if (day.day == self.daysInMonth) {
                    
                    fillRect.size.width = CGRectGetMaxX(self.frame) - CGRectGetMinX(fillRect);
                }
                
                if ([self isPoint:dayRectMidpoint inColumn:0] && day.day != 1) {
                    
                    fillRect.origin.x = 0.0f;
                    fillRect.size.width += kPBMonthViewItemMargin;
                }
            }

            if (bezierPath != nil) {
                CGContextAddPath(context, bezierPath.CGPath);
                CGContextClip(context);
            }

            [self.withinRangeBackgroundColor setFill];
            CGContextFillRect(context, fillRect);
        }

        if (isStartingDay || isEndingDay) {

            UIColor *fillColor = [self.tintColor colorWithAlpha:.7f];
            BOOL doFill = YES;

            if ((isStartingDay && self.startPointHidden) ||
                (isEndingDay && self.endPointHidden)) {
                
                fillColor = self.withinRangeBackgroundColor;
                doFill = self.withinRangeBackgroundHidden == NO;
            }

            if (doFill) {
                CGPathRef path = CGPathCreateWithEllipseInRect(dayRect, NULL);
                CGContextAddPath(context, path);
                CGContextClip(context);
                
                CGContextSaveGState(context);
                CGContextSetBlendMode(context, kCGBlendModeCopy);
                [self.backgroundColor setFill];
                CGContextFillRect(context, dayRect);
                CGContextRestoreGState(context);
                
                [fillColor setFill];
                CGContextFillRect(context, dayRect);
            }
        }

        dayRect.origin.y += kPBMonthViewDayTextTopSpace;

        [dayString
         drawInRect:dayRect
         withAttributes:textAttributes];

		CGContextRestoreGState(context);
	}];
}

@end
