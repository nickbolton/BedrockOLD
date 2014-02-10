//
//  PBCalendarView.m
//  Calendar
//
//  Created by Nick Bolton on 2/8/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCalendarView.h"
#import "PBMonthView.h"

@interface PBCalendarView ()

@property (nonatomic, strong) NSMutableArray *monthViews;
@property (nonatomic, strong) NSMutableSet *monthViewQueue;
@property (nonatomic, strong) UITapGestureRecognizer *selectionRecognizer;

@end

@implementation PBCalendarView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self != nil) {
		self.scrollEnabled = YES;
        self.showsVerticalScrollIndicator = NO;

		self.contentSize = CGSizeMake(self.bounds.size.width, 2000.0);

		self.monthViews = [[NSMutableArray alloc] init];
		self.monthViewQueue = [[NSMutableSet alloc] init];

		PBMonthView *monthView = [self _dequeueMonthView];

		monthView.month = [NSDate date];
		monthView.frame = CGRectMake(0.0,
									 -1.0,
									 self.frame.size.width,
									 monthView.frame.size.height);
		[self insertSubview:monthView atIndex:0];
		[self.monthViews addObject:monthView];

        self.selectionRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_selectionTap:)];
		[self addGestureRecognizer:self.selectionRecognizer];

		dispatch_async(dispatch_get_main_queue(), ^{
			[self scrollToMonth:[NSDate date]];
		});
    }
    
    return self;
}

#pragma mark - Properties

- (void)setSelectedDateRange:(PBDateRange *)selectedDateRange {
    _selectedDateRange = selectedDateRange;

    NSDateComponents *components =
    [selectedDateRange.startDate
     components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay];

    [self setSelectedDay:components animated:NO];
}

- (void)setSelectedDay:(NSDateComponents *)selectedDay animated:(BOOL)animated {

    NSDate *date =
    [NSDate
     dateWithYear:selectedDay.year
     month:selectedDay.month
     day:selectedDay.day];

    _selectedDateRange = [PBDateRange dateRangeWithStartDate:date endDate:date];

	NSTimeInterval duration = 0.0;
	if (animated) {
		duration = 0.25;
	}

	[self.monthViews enumerateObjectsUsingBlock:^(PBMonthView *monthView, NSUInteger idx, BOOL *stop) {

        [UIView
         transitionWithView:monthView
         duration:duration
         options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
         animations:^{
             [monthView setNeedsDisplay];
         }
         completion:nil];
	}];
}

- (NSDate *)currentMonth {

    CGRect frame = self.frame;
    CGPoint midpoint = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));

    midpoint.y += self.contentOffset.y;

    __block PBMonthView *result = nil;

    [self.monthViews enumerateObjectsUsingBlock:^(PBMonthView *monthView, NSUInteger idx, BOOL *stop) {

        if (CGRectContainsPoint(monthView.frame, midpoint)) {

            result = monthView;
            *stop = YES;
        }
    }];

    NSDate *date = nil;

    if (result != nil) {
        date = result.month;
    }

    return date;
}

#pragma mark - Month View Management

- (BOOL)_lastMonthNeeded
{
	PBMonthView *lastMonthView = [self.monthViews lastObject];

	return CGRectGetMaxY(lastMonthView.frame) < CGRectGetMaxY(self.bounds) + 100.0;
}

- (BOOL)_firstMonthNeeded
{
	PBMonthView *lastMonthView = [self.monthViews objectAtIndex:0];

	return CGRectGetMinY(lastMonthView.frame) > self.bounds.origin.y - 100.0;
}

- (PBMonthView *)_dequeueMonthView
{
	PBMonthView *monthView = [self.monthViewQueue anyObject];

	if (monthView  == nil) {
		monthView = [[PBMonthView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 100.0)];
        monthView.calendarView = self;
	} else {
		[self.monthViewQueue removeObject:monthView];
	}

    [monthView setNeedsDisplay];

	return monthView;
}

- (NSArray *)monthViewsBoundByRect:(CGRect)rect inView:(UIView *)view {

    NSMutableArray *result = [NSMutableArray array];

    CGRect rectInScrollView =
    [self
     convertRect:rect
     fromView:view];

    [self.monthViews enumerateObjectsUsingBlock:^(PBMonthView *monthView, NSUInteger idx, BOOL *stop) {

        if (CGRectIntersectsRect(monthView.frame, rectInScrollView)) {
            [result addObject:monthView];
        }
    }];

    return result;
}

#pragma mark - Scroll Adjustments

- (void)_recenterIfNecessary
{
	CGPoint currentOffset = self.contentOffset;
	CGFloat contentHeight = self.contentSize.height;
	CGFloat centerOffsetY = (contentHeight - self.bounds.size.height) / 2.0;
	CGFloat distanceFromCenter = fabs(currentOffset.y - centerOffsetY);

	if (distanceFromCenter > (contentHeight / 4.0)) {
		self.contentOffset = CGPointMake(currentOffset.x, centerOffsetY);

		[self.monthViews enumerateObjectsUsingBlock:^(PBMonthView *monthView, NSUInteger index, BOOL *stop) {
			CGPoint center = monthView.center;
			center.y += (centerOffsetY - currentOffset.y);
			monthView.center = center;
		}];
	}
}

- (void)_updateMonthViews
{
	NSInteger monthOffset = 0;
	CGFloat positionOffset = 0.0;

	while ([self _lastMonthNeeded]) {
		//add month view to the end
		PBMonthView *lastMonthView = [self.monthViews lastObject];

		NSDateComponents *components = [[NSDateComponents alloc] init];
		components.month = 1 + monthOffset;
		NSDate *month = [lastMonthView.month dateByAddingComponents:components];

		CGFloat offset = [PBMonthView verticalOffsetForWidth:self.frame.size.width month:month];
		if (CGRectGetMaxY(lastMonthView.frame) + offset + positionOffset > self.bounds.origin.y - 100.0) {
			PBMonthView *monthView = [self _dequeueMonthView];
			monthView.month = month;
			monthView.frame = CGRectMake(0.0,
										 CGRectGetMaxY(lastMonthView.frame) + positionOffset,
										 self.frame.size.width,
										 monthView.frame.size.height);
			[self insertSubview:monthView atIndex:0];
			[self.monthViews addObject:monthView];

			monthOffset = 0;
			positionOffset = 0.0;
		} else {
			positionOffset += offset;
			monthOffset++;
		}
	}

	monthOffset = 0;
	positionOffset = 0.0;

	while ([self _firstMonthNeeded]) {
		//add month view to the beggining
		PBMonthView *lastMonthView = [self.monthViews objectAtIndex:0];

		NSDateComponents *components = [[NSDateComponents alloc] init];
		components.month = -1 - monthOffset;
		NSDate *month = [[NSCalendar calendarForCurrentThread] dateByAddingComponents:components toDate:lastMonthView.month options:0];

		CGFloat offset = [PBMonthView verticalOffsetForWidth:self.frame.size.width month:month];
		if (CGRectGetMinY(lastMonthView.frame) - offset - positionOffset < CGRectGetMaxY(self.bounds) + 100.0) {
			PBMonthView *monthView = [self _dequeueMonthView];
			monthView.month = month;
			monthView.frame = CGRectMake(0.0,
										 CGRectGetMinY(lastMonthView.frame) - monthView.frame.size.height - positionOffset,
										 self.frame.size.width,
										 monthView.frame.size.height);
			[self insertSubview:monthView atIndex:0];
			[self.monthViews insertObject:monthView atIndex:0];

			monthOffset = 0;
			positionOffset = 0.0;
		} else {
			positionOffset += offset;
			monthOffset++;
		}
	}

	[[self.monthViews copy] enumerateObjectsUsingBlock:^(PBMonthView *monthView, NSUInteger index, BOOL *stop) {
		if (!CGRectIntersectsRect(self.bounds, monthView.frame) && self.monthViews.count > 1) {
			[monthView removeFromSuperview];
			[self.monthViews removeObject:monthView];
			[self.monthViewQueue addObject:monthView];
		}
	}];
}

- (void)layoutSubviews
{
	[self _recenterIfNecessary];
	[self _updateMonthViews];
    [super layoutSubviews];
}


#pragma mark - Scrolling Control

- (void)scrollToMonth:(NSDate *)month
{
	[self scrollToMonth:month animated:NO];
}

- (void)scrollToMonth:(NSDate *)month animated:(BOOL)animated {
	CGPoint offset = self.contentOffset;
	PBMonthView *referenceMonthView = [self.monthViews lastObject];

	offset.y = referenceMonthView.frame.origin.y - referenceMonthView.frame.size.height;

	NSDate *lastMonth = referenceMonthView.month;
	NSComparisonResult comparison;
	while ((comparison = [lastMonth.firstDayOfMonth compare:month.firstDayOfMonth]) != NSOrderedSame) {
		NSDateComponents *monthMovement = [[NSDateComponents alloc] init];
		monthMovement.month = (comparison == NSOrderedAscending) ? 1 : -1;
		NSDate *newMonth = [[NSCalendar calendarForCurrentThread] dateByAddingComponents:monthMovement toDate:lastMonth options:0];

		if (comparison == NSOrderedAscending) {
			offset.y += [PBMonthView verticalOffsetForWidth:self.frame.size.width month:lastMonth];
		} else {
			offset.y -= [PBMonthView verticalOffsetForWidth:self.frame.size.width month:newMonth];
		}

		lastMonth = newMonth;
	}

	offset.y += [PBMonthView topOffsetForWidth:self.frame.size.width month:month] + 1.0;

	[self setContentOffset:offset animated:animated];
}

#pragma mark - Actions

- (IBAction)_selectionTap:(UITapGestureRecognizer *)sender {
    
	[self.monthViews enumerateObjectsUsingBlock:^(PBMonthView *monthView, NSUInteger idx, BOOL *stop) {
		if (CGRectContainsPoint(monthView.frame, [sender locationInView:self])) {
			NSDateComponents *selectedDay = [monthView dayAtPoint:[self convertPoint:[sender locationInView:self] toView:monthView]];

			if (selectedDay != nil) {
				[self setSelectedDay:selectedDay animated:YES];
            
                if ([self.delegate respondsToSelector:@selector(calendarViewSelected:selectedRangeDidChange:)]) {

                    [(id <PBCalendarViewDelegate>)self.delegate
                     calendarViewSelected:self
                     selectedRangeDidChange:self.selectedDateRange];
                }

				*stop = YES;
			}
		}
	}];
}

@end
