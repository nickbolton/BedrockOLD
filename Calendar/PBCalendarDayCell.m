//
//  PBCalendarDayCell.m
//  Calendar
//
//  Created by Nick Bolton on 1/19/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCalendarDayCell.h"
#import "Bedrock.h"

static CGFloat const kPBCalendarDayCellEndPointRadius = 16.0f;

@interface PBCalendarDayCell()

@property (nonatomic, readwrite) UILabel *dayLabel;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UIColor *endPointBackgroundColor;
@property (nonatomic, strong) UIColor *withinRangeBackgroundColor;
@property (nonatomic, strong) CAShapeLayer *startingDayLayerMask;
@property (nonatomic, strong) CAShapeLayer *endingDayLayerMask;

@end

@implementation PBCalendarDayCell

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {

    self.endPointBackgroundColor = [UIColor colorWithRGBHex:0x3060FA];
    self.withinRangeBackgroundColor = [UIColor colorWithRGBHex:0xDAE6FE];
    [self setupCircleView];
    [self setupDayLabel];
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.startingDay = NO;
    self.endingDay = NO;
    self.withinRange = NO;
    self.currentDay = NO;
}

- (void)setupDayLabel {

    self.dayLabel = [[UILabel alloc] init];
    self.dayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dayLabel.textColor = [UIColor blackColor];
    self.dayLabel.textAlignment = NSTextAlignmentCenter;
    self.dayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
//    self.dayLabel.backgroundColor = [UIColor greenColor];

    [self addSubview:self.dayLabel];

    CGFloat diameter = kPBCalendarDayCellEndPointRadius * 2.0f;

    [NSLayoutConstraint addHeightConstraint:diameter toView:self.dayLabel];
    [NSLayoutConstraint addWidthConstraint:diameter toView:self.dayLabel];

    [NSLayoutConstraint alignToTop:self.dayLabel withPadding:-.5f];
    [NSLayoutConstraint
     alignToLeft:self.dayLabel
     withPadding:(CGRectGetWidth(self.layer.bounds) - diameter) / 2.0f];
}

- (void)setupCircleView {

    self.circleView = [[UIView alloc] init];
    self.circleView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.circleView];

    self.circleView.layer.cornerRadius = kPBCalendarDayCellEndPointRadius;

    CGFloat diameter = kPBCalendarDayCellEndPointRadius * 2.0f;

    [NSLayoutConstraint addWidthConstraint:diameter toView:self.circleView];
    [NSLayoutConstraint addHeightConstraint:diameter toView:self.circleView];
    [NSLayoutConstraint horizontallyCenterView:self.circleView padding:-0.5f];
    [NSLayoutConstraint verticallyCenterView:self.circleView];
    self.circleView.backgroundColor = self.endPointBackgroundColor;
    self.circleView.hidden = YES;
}

#pragma mark - Getters and Setters

- (CAShapeLayer *)startingDayLayerMask {

    if (_startingDayLayerMask == nil) {

        _startingDayLayerMask = [[CAShapeLayer alloc] init];

        CGFloat diameter = kPBCalendarDayCellEndPointRadius * 2.0f;

        _startingDayLayerMask.frame = self.layer.bounds;

        CGRect circleRect =
        CGRectMake((CGRectGetWidth(self.layer.bounds) - diameter) / 2.0f,
                   (CGRectGetHeight(self.layer.bounds) - diameter) / 2.0f,
                   diameter,
                   diameter);

        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];

        CGRect halfRect =
        CGRectMake(CGRectGetWidth(self.layer.bounds) / 2.0f,
                   (CGRectGetHeight(self.layer.bounds) - diameter) / 2.0f,
                   diameter + (CGRectGetWidth(self.layer.bounds) - diameter) / 2.0f,
                   diameter);

        UIBezierPath *halfRectPath = [UIBezierPath bezierPathWithRect:halfRect];

        [path appendPath:halfRectPath];

        _startingDayLayerMask.fillColor = [UIColor blackColor].CGColor;
        _startingDayLayerMask.path = path.CGPath;
    }

    return _startingDayLayerMask;
}

- (CAShapeLayer *)endingDayLayerMask {

    if (_endingDayLayerMask == nil) {

        _endingDayLayerMask = [[CAShapeLayer alloc] init];

        CGFloat diameter = kPBCalendarDayCellEndPointRadius * 2.0f;

        _endingDayLayerMask.frame = self.layer.bounds;

        CGRect circleRect =
        CGRectMake((CGRectGetWidth(self.layer.bounds) - diameter) / 2.0f,
                   (CGRectGetHeight(self.layer.bounds) - diameter) / 2.0f,
                   diameter,
                   diameter);

        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];

        CGRect halfRect =
        CGRectMake(0.0f,
                   (CGRectGetHeight(self.layer.bounds) - diameter) / 2.0f,
                   kPBCalendarDayCellEndPointRadius + (CGRectGetWidth(self.layer.bounds) - diameter) / 2.0f,
                   diameter);

        UIBezierPath *halfRectPath = [UIBezierPath bezierPathWithRect:halfRect];

        [path appendPath:halfRectPath];

        _endingDayLayerMask.fillColor = [UIColor blackColor].CGColor;
        _endingDayLayerMask.path = path.CGPath;
    }
    
    return _endingDayLayerMask;
}

- (void)setStartingDay:(BOOL)startingDay {
    _startingDay = startingDay;
    [self updateLayerMask];
    [self updateTextColor];
    [self updateCircleView];
    [self updateBackgroundColor];
}

- (void)setEndingDay:(BOOL)endingDay {
    _endingDay = endingDay;
    [self updateLayerMask];
    [self updateTextColor];
    [self updateCircleView];
    [self updateBackgroundColor];
}

- (void)setWithinRange:(BOOL)withinRange {
    _withinRange = withinRange;
    [self updateTextColor];
    [self updateBackgroundColor];
}

- (void)setCurrentDay:(BOOL)currentDay {
    _currentDay = currentDay;

    if (currentDay) {
        self.dayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    } else {
        self.dayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
    }
}

- (void)setSelectedDateRange:(PBDateRange *)selectedDateRange {
    _selectedDateRange = selectedDateRange;
    [self updateSelectedRangeState];
}

- (void)updateCellWithYear:(NSInteger)year
                     month:(NSInteger)month
                       day:(NSInteger)day
                   realDay:(NSInteger)realDay
         selectedDateRange:(PBDateRange *)selectedDateRange {

    self.day = day;
    self.realDay = realDay;
    self.year = year;
    self.month = month;
    self.selectedDateRange = selectedDateRange;
}

- (void)updateSelectedRangeState {

    NSCalendar *calendar =
    [[PBCalendarManager sharedInstance] calendarForCurrentThread];

    NSDate *monthDate =
    [NSDate
     dateWithYear:self.year
     month:self.month
     day:1];

    NSRange daysInMonth =
    [calendar
     rangeOfUnit:NSCalendarUnitDay
     inUnit:NSCalendarUnitMonth
     forDate:monthDate];

    NSDate *realDate =
    [NSDate
     dateWithYear:self.year
     month:self.month
     day:self.realDay];

    BOOL startingDay =
    [self.selectedDateRange.startDate isEqualToDate:realDate];

    BOOL endingDay =
    [self.selectedDateRange.endDate isEqualToDate:realDate.endOfDay];

    self.startingDay = NO;
    self.endingDay = NO;

    if (self.day == self.realDay) {
        self.startingDay = startingDay;
        self.endingDay = endingDay;
    }

    BOOL withinSelectedDateRange =
    [self.selectedDateRange dateWithinRange:realDate];

    withinSelectedDateRange &= startingDay == NO;
    withinSelectedDateRange &= endingDay == NO;

    if (self.day == 0) {

        if (endingDay) {
            withinSelectedDateRange =
            [self.selectedDateRange.startDate
             isLessThan:self.selectedDateRange.endDate.midnight];
        }

    } else if (self.day > daysInMonth.length) {

        if (startingDay) {
            withinSelectedDateRange =
            [self.selectedDateRange.startDate
             isLessThan:self.selectedDateRange.endDate.midnight];
        }

    } else if (startingDay || endingDay) {

        NSDate *date =
        [NSDate
         dateWithYear:self.year
         month:self.month
         day:self.day];

        withinSelectedDateRange =
        [self.selectedDateRange dateWithinRange:date];
    }

//    NSLog(@"day: %ld", (long)self.day);
//    NSLog(@"realDay: %ld", (long)self.realDay);
//    NSLog(@"realDate: %@", realDate);
//    NSLog(@"startingDay: %d", startingDay);
//    NSLog(@"endingDay: %d", endingDay);
//    NSLog(@"withinSelectedDateRange: %d", withinSelectedDateRange);

    self.withinRange = withinSelectedDateRange;
}

#pragma mark -

- (void)updateLayerMask {

    self.layer.mask = nil;

    if (self.isStartingDay != self.isEndingDay) {
        if (self.isStartingDay) {
            self.layer.mask = self.startingDayLayerMask;
        } else if (self.isEndingDay) {
            self.layer.mask = self.endingDayLayerMask;
        }
    }
}

- (void)updateBackgroundColor {

    if (self.isWithinRange &&
        ((self.isStartingDay == NO && self.isEndingDay == NO) ||
        (self.isStartingDay != self.isEndingDay))) {
        self.backgroundColor = self.withinRangeBackgroundColor;
    } else {
        self.backgroundColor = nil;
    }
}

- (void)updateTextColor {

    if (self.isStartingDay || self.isEndingDay) {
        self.dayLabel.textColor = [UIColor whiteColor];
    } else {
        self.dayLabel.textColor = [UIColor blackColor];
    }
}

- (void)updateCircleView {
    self.circleView.hidden = self.isStartingDay == NO && self.isEndingDay == NO;
}

@end
