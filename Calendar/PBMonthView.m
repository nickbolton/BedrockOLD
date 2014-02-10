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
static CGFloat const kPBMonthViewItemWidth = 44.0f;
static CGFloat const kPBMonthViewItemHeight = 36.0f;
static CGFloat const kPBMonthViewTopSpace = 42.0f;
static CGFloat const kPBMonthViewBottomSpace = -3.0f;
static CGFloat const kPBMonthViewWidthLeadingPadding = 2.5f;
static CGFloat const kPBMonthViewWidthTrailingPadding = 2.5f;
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
@property (nonatomic, strong) NSDictionary *dayAttributes;
@property (nonatomic, strong) NSDictionary *todayAttributes;
@property (nonatomic, strong) NSDictionary *selectedDayAttributes;
@property (nonatomic, strong) NSDictionary *selectedTodayAttributes;
@property (nonatomic, strong) UIColor *endPointBackgroundColor;
@property (nonatomic, strong) UIColor *withinRangeBackgroundColor;

@end

@implementation PBMonthView

#pragma mark - Properties

- (void)setMonth:(NSDate *)month {

    NSDateComponents *components =
    [month components:NSCalendarUnitYear|NSCalendarUnitMonth];

	_month =
    [NSDate
     dateWithYear:components.year
     month:components.month
     day:1];

    [self updateMonthTitle];
	_firstDayOffset = -1;
	_lastDayOffset = -1;
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
          NSForegroundColorAttributeName : [UIColor blackColor],
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
          NSForegroundColorAttributeName : [UIColor blackColor],
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

- (NSDictionary *)dayAttributes {

    if (_dayAttributes == nil) {

        NSMutableParagraphStyle *paragraphStyle =
        [[NSMutableParagraphStyle alloc] init];

        paragraphStyle.alignment = NSTextAlignmentCenter;

        _dayAttributes =
        @{
          NSFontAttributeName : self.dayFont,
          NSForegroundColorAttributeName : [UIColor blackColor],
          NSParagraphStyleAttributeName : paragraphStyle,
          };
    }
    
    return _dayAttributes;
}

- (UIColor *)endPointBackgroundColor {

    if (_endPointBackgroundColor == nil) {
        _endPointBackgroundColor = [UIColor colorWithRGBHex:0x3060FA];
    }

    return _endPointBackgroundColor;
}

- (UIColor *)withinRangeBackgroundColor {

    if (_withinRangeBackgroundColor == nil) {
        _withinRangeBackgroundColor = [UIColor colorWithRGBHex:0xDAE6FE];
    }

    return _withinRangeBackgroundColor;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.opaque = NO;

		self.month = [NSDate date];
        self.backgroundColor = [UIColor whiteColor];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self != nil) {
        self.opaque = NO;

		self.month = [NSDate date];
        self.backgroundColor = [UIColor whiteColor];
    }

    return self;
}


#pragma mark - Sizing

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];

	_firstDayOffset = -1;
	_lastDayOffset = -1;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	CGFloat dayHeight = roundf((size.width - kPBMonthViewItemWidth) / [NSCalendar numberOfDaysInWeek]);
	NSInteger weeks =
    [self.month
     rangeOfUnit:NSWeekCalendarUnit
     inUnit:NSMonthCalendarUnit].length;

	size.height = dayHeight * weeks + kPBMonthViewTopSpace + kPBMonthViewBottomSpace;

	return size;
}


#pragma mark - Geometry

- (CGFloat)topOffset
{
	return self._topLeftPoint.y;
}

+ (CGFloat)topOffsetForWidth:(CGFloat)width month:(NSDate *)month
{
	CGFloat offset = 0.0;

	CGFloat dayHeight = roundf((width - kPBMonthViewItemWidth) / [NSCalendar numberOfDaysInWeek]);

	NSInteger firstDayOffset = month.firstDayOfMonth.weekday - [[NSCalendar calendarForCurrentThread] firstWeekday];
	if (firstDayOffset != 0) {
		offset -= dayHeight;
	}

	return offset;
}

+ (CGFloat)verticalOffsetForWidth:(CGFloat)width month:(NSDate *)month
{
	CGFloat offset = 0.0;


	CGFloat dayHeight = roundf((width - kPBMonthViewItemWidth) / [NSCalendar numberOfDaysInWeek]);
	NSInteger weeks = [[NSCalendar calendarForCurrentThread] rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:month].length;
	offset = dayHeight * weeks + kPBMonthViewTopSpace + kPBMonthViewBottomSpace;

	NSInteger firstDayOffset = month.firstDayOfMonth.weekday - [[NSCalendar calendarForCurrentThread] firstWeekday];
	if (firstDayOffset != 0) {
		offset -= dayHeight;
	}


	return offset;
}

- (NSInteger)_firstDayOffset
{
	if (_firstDayOffset == -1) {
		_firstDayOffset = self.month.firstDayOfMonth.weekday - [[NSCalendar calendarForCurrentThread] firstWeekday];
	}

	return _firstDayOffset;
}

- (NSInteger)_lastDayOffset
{
	if (_lastDayOffset == -1) {
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
	CGPoint point = CGPointMake(self.bounds.size.width-kPBMonthViewWidthTrailingPadding, self.bounds.size.height);
	NSInteger numberOfDays = [NSCalendar numberOfDaysInWeek];
	NSInteger lastDayOffset = [self _lastDayOffset];
	if (lastDayOffset != numberOfDays - 1) {
		point.y -= kPBMonthViewItemHeight;
	}

	return point;
}

- (NSDateComponents *)dayAtPoint:(CGPoint)point
{
	__block NSDateComponents *dayComponents = nil;

	[self _enumerateDays:^(NSDateComponents *day, CGRect dayRect, BOOL *stop) {
		if (CGRectContainsPoint(dayRect, point)) {
			dayComponents = [day copy];

			*stop = YES;
		}
	}];

	return dayComponents;
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
    [self _drawDivider];
    [self _drawMonthTitle];
	[self _drawDays];
}

- (void)_enumerateDays:(void(^)(NSDateComponents *day, CGRect dayRect, BOOL *stop))dayBlock
{

    CGFloat diameter = kPBMonthViewEndPointRadius * 2.0f;

    CGFloat topSpace = (kPBMonthViewItemHeight - diameter) / 2.0f;
    CGFloat leftSpace = (kPBMonthViewItemWidth - diameter) / 2.0f;

	NSRange weeks = [[NSCalendar calendarForCurrentThread] rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.month];
	NSRange days = [[NSCalendar calendarForCurrentThread] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.month];
	NSDateComponents *day = [[NSCalendar calendarForCurrentThread] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self.month];
	day.day = days.location;
	CGRect dayRect;
	dayRect.origin.x = [self _firstDayOffset] * kPBMonthViewItemWidth + kPBMonthViewWidthLeadingPadding + leftSpace;
	dayRect.size = CGSizeMake(diameter, diameter);
	BOOL stop = NO;

    CGFloat lastDayOfWeekXPos =
    ([NSCalendar numberOfDaysInWeek]-1) * kPBMonthViewItemWidth + kPBMonthViewWidthLeadingPadding + leftSpace;

	for (NSInteger week = 0; week < weeks.length && !stop; week++) {
		dayRect.origin.y = week * kPBMonthViewItemHeight + kPBMonthViewTopSpace + topSpace;

		while (dayRect.origin.x <= lastDayOfWeekXPos && day.day < days.location + days.length && !stop) {
			dayBlock(day, dayRect, &stop);
			dayRect.origin.x += kPBMonthViewItemWidth;
			day.day++;
		}

		dayRect.origin.x = kPBMonthViewWidthLeadingPadding + leftSpace;
	}
}

- (void)_drawDivider {

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    UIColor *lineColor = [UIColor colorWithRGBHex:0xe0e0e0];
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

	[self _enumerateDays:^(NSDateComponents *day, CGRect dayRect, BOOL *stop) {
		CGContextSaveGState(context);

		NSString *dayString = [NSString stringWithFormat:@"%d", day.day];
        NSDictionary *textAttributes;

		BOOL isToday = month.year == today.year && month.month == today.month && day.day == today.day;

        NSDateComponents *selectedDayComponents =
        [self.calendarView.selectedDateRange.startDate
         components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay];

		BOOL isSelected = [selectedDayComponents isEqual:day];

		if (isToday) {
            if (isSelected) {
                textAttributes = self.selectedTodayAttributes;
            } else {
                textAttributes = self.todayAttributes;
            }
        } else {
            if (isSelected) {
                textAttributes = self.selectedDayAttributes;
            } else {
                textAttributes = self.dayAttributes;
            }
        }

        if (isSelected) {

            CGPathRef path = CGPathCreateWithEllipseInRect(dayRect, NULL);
            CGContextAddPath(context, path);
            CGContextClip(context);
            [self.endPointBackgroundColor setFill];
            CGContextFillRect(context, dayRect);
        }

        dayRect.origin.y += kPBMonthViewDayTextTopSpace;

        [dayString
         drawInRect:dayRect
         withAttributes:textAttributes];

		CGContextRestoreGState(context);
	}];
}

@end
