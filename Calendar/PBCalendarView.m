//
//  PBCalendarView.m
//  Calendar
//
//  Created by Nick Bolton on 1/19/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCalendarView.h"
#import "Emitter.h"
#import "Bedrock.h"
#import "PBCalendarDayCell.h"

static CGFloat const kPBCalendarViewItemHeight = 32.0f;
static CGFloat const kPBCalendarViewItemHeightPadding = 4.0f;
static CGFloat const kPBCalendarViewWidthLeadingPadding = 16.0f;
static CGFloat const kPBCalendarViewWidthTrailingPadding = 17.0f;

@interface PBCalendarView() {

    BOOL _dataSourceDirty;
}

@property (nonatomic, readwrite) NSInteger year;
@property (nonatomic, readwrite) NSInteger month;
@property PBCollectionViewController *collectionViewController;
@property (nonatomic, strong) UILabel *monthTitle;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation PBCalendarView

#pragma mark - Public

- (void)setYear:(NSInteger)year month:(NSInteger)month {

    _dataSourceDirty |= self.year != year || self.month != month;

    self.year = year;
    self.month = month;

    [self updateView];
}

- (void)setSelectedDateRange:(PBDateRange *)selectedDateRange {
    _selectedDateRange = selectedDateRange;

    [self updateCellsSelectedDateRange];
}

- (void)setYearAndMonthFromDate:(NSDate *)date {

    NSCalendar *calendar =
    [[PBCalendarManager sharedInstance] calendarForCurrentThread];

    NSDateComponents *dateComponents =
    [calendar
     components:NSCalendarUnitYear|NSCalendarUnitMonth
     fromDate:date];

    [self setYear:dateComponents.year month:dateComponents.month];
}

- (NSDateComponents *)dateComponentsAtPoint:(CGPoint)point {

    UICollectionView *collectionView =
    self.collectionViewController.collectionView;

    CGPoint pointInCollectionView =
    [collectionView
     convertPoint:point
     fromView:self];

    NSIndexPath *indexPath =
    [collectionView indexPathForItemAtPoint:pointInCollectionView];

    NSDateComponents *result = nil;

    if (indexPath.item < self.dataSource.count) {

        PBCollectionItem *item = self.dataSource[indexPath.item];

        NSDateComponents *dateComponents = item.userContext;

        if ([dateComponents isKindOfClass:[NSDateComponents class]]) {
            result = dateComponents;
        }
    }

    return result;
}

- (NSDateComponents *)nearestDateComponentsAtPoint:(CGPoint)point {

    NSDateComponents *result = [self dateComponentsAtPoint:point];

    if (result == nil) {

        UICollectionView *collectionView =
        self.collectionViewController.collectionView;

        CGPoint pointInCollectionView =
        [collectionView
         convertPoint:point
         fromView:self];

        NSMutableArray *calendarCells = [NSMutableArray array];

        for (PBCalendarDayCell *cell in collectionView.visibleCells) {

            if ([cell isKindOfClass:[PBCalendarDayCell class]]) {
                [calendarCells addObject:cell];
            }
        }

        NSArray *sortedCells =
        [calendarCells sortedArrayUsingComparator:^NSComparisonResult(PBCalendarDayCell *cell1, PBCalendarDayCell *cell2) {
            return [@(cell1.indexPath.item) compare:@(cell2.indexPath.item)];
        }];

        UICollectionViewCell *firstCell = sortedCells.firstObject;

        CGRect firstCellRectInCollectionView =
        [collectionView
         convertRect:firstCell.bounds
         fromView:firstCell];

        UICollectionViewCell *lastCell = sortedCells.lastObject;

        CGRect lastCellRectInCollectionView =
        [collectionView
         convertRect:lastCell.bounds
         fromView:lastCell];

        NSIndexPath *indexPath;

        if (pointInCollectionView.y <= CGRectGetMaxY(firstCellRectInCollectionView)) {

            indexPath = [collectionView indexPathForCell:firstCell];

            if (indexPath != nil) {

                PBCollectionItem *item = self.dataSource[indexPath.item];

                NSDateComponents *dateComponents = item.userContext;

                if ([dateComponents isKindOfClass:[NSDictionary class]]) {

                    item = self.dataSource[indexPath.item+1];
                    dateComponents = item.userContext;
                }

                if ([dateComponents isKindOfClass:[NSDateComponents class]]) {
                    result = dateComponents;
                }
            }

        } else if (pointInCollectionView.y >= CGRectGetMinY(lastCellRectInCollectionView)) {

            indexPath = [collectionView indexPathForCell:lastCell];

            if (indexPath != nil) {

                PBCollectionItem *item = self.dataSource[indexPath.item];

                NSDateComponents *dateComponents = item.userContext;

                if ([dateComponents isKindOfClass:[NSDictionary class]]) {

                    item = self.dataSource[indexPath.item-1];
                    dateComponents = item.userContext;
                }

                if ([dateComponents isKindOfClass:[NSDateComponents class]]) {
                    result = dateComponents;
                }
            }
        }
    }

    return result;
}

#pragma mark - Setup

- (void)setupCollectionViewController {

    static CGFloat const calendarTopSpace = 38.5f;

    if (_dataSourceDirty) {
        self.collectionViewController.providedDataSource = [self buildItems];
    }

    self.collectionViewController = [[PBCollectionViewController alloc] initWithItems:self.dataSource];
    self.collectionViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionViewController.collectionView.scrollEnabled = NO;
//    self.collectionViewController.view.backgroundColor = [UIColor redColor];
//    self.backgroundColor = [UIColor yellowColor];

    CGFloat width = CGRectGetWidth(self.collectionViewController.view.frame);

    CGFloat height = (kPBCalendarViewItemHeightPadding + kPBCalendarViewItemHeight) * 6;

    self.collectionViewController.collectionLayout.minContentSize =
    CGSizeMake(width, height);

    [self addSubview:self.collectionViewController.view];

    [NSLayoutConstraint
     alignToTop:self.collectionViewController.view
     withPadding:calendarTopSpace];

    [NSLayoutConstraint
     expandWidthToSuperview:self.collectionViewController.view];

    [NSLayoutConstraint
     addHeightConstraint:height
     toView:self.collectionViewController.view];

    [self updateView];
}

- (void)setupMonthTitle {

    self.monthTitle = [[UILabel alloc] init];
    self.monthTitle.translatesAutoresizingMaskIntoConstraints = NO;
    self.monthTitle.textColor = [UIColor blackColor];
    self.monthTitle.font =
    [UIFont fontWithName:@"HelveticaNeue" size:16.0f];

    [self addSubview:self.monthTitle];

    [NSLayoutConstraint alignToTop:self.monthTitle withPadding:8.0f];
    [NSLayoutConstraint alignToLeft:self.monthTitle withPadding:15.0f];
}

#pragma mark - 

- (void)updateCellsSelectedDateRange {

    for (PBCalendarDayCell *cell in self.collectionViewController.collectionView.visibleCells) {
        cell.selectedDateRange = self.selectedDateRange;
    }
}

- (PBCollectionItem *)spacerItem:(NSNumber *)day realDay:(NSNumber *)realDay {

    static NSString * const dayKey = @"day";
    static NSString * const realDayKey = @"real-day";

    NSDictionary *userContext =
    @{
      dayKey : day,
      realDayKey : realDay,
      };

    PBCollectionItem *item =
    [PBCollectionItem
     customClassItemWithUserContext:userContext
     reuseIdentifier:@"day-spacer"
     cellClass:[PBCalendarDayCell class]
     configure:^(PBCollectionViewController *viewController, PBCollectionItem *item, PBCalendarDayCell *cell) {

     } binding:^(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, PBCalendarDayCell *cell) {

         NSNumber *day = item.userContext[dayKey];
         NSNumber *realDay = item.userContext[realDayKey];

         [cell
          updateCellWithYear:self.year
          month:self.month
          day:day.integerValue
          realDay:realDay.integerValue
          selectedDateRange:self.selectedDateRange];
         
     } selectAction:^(PBCollectionViewController *viewController) {

     } deleteAction:nil];

    return item;
}

- (NSArray *)buildItems {

    static NSInteger const daysInWeek = 7;

    NSMutableArray *items = [NSMutableArray array];

    NSCalendar *calendar =
    [[PBCalendarManager sharedInstance] calendarForCurrentThread];

    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents =
    [calendar
     components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
     fromDate:now];

    NSDate *date =
    [NSDate dateWithYear:self.year month:self.month day:1];

    NSRange days =
    [calendar
     rangeOfUnit:NSCalendarUnitDay
     inUnit:NSCalendarUnitMonth
     forDate:date];

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat collectionViewWidth =
    MIN(CGRectGetWidth(screenBounds),
        CGRectGetHeight(screenBounds)) -
        kPBCalendarViewWidthLeadingPadding -
        kPBCalendarViewWidthTrailingPadding;

    CGFloat itemWidth = collectionViewWidth / 7;

    NSDateComponents *firstDayOfTheWeekComponents =
    [calendar
     components:NSCalendarUnitWeekday
     fromDate:date];

    NSInteger firstDayOfTheWeek = firstDayOfTheWeekComponents.weekday;
    NSInteger distanceFromSunday = firstDayOfTheWeek-2;

    CGFloat xPos = 0.0f;
    CGFloat yPos = 0.0f;

    for (NSInteger day = 1; day <= days.length;) {

        NSInteger dayPosition = (day+distanceFromSunday) % daysInWeek;
        CGFloat spacerWidth = 0.0f;

        if (dayPosition == 0) {

            xPos = 0.0f;

            if (day > 1) {
                yPos += kPBCalendarViewItemHeight + kPBCalendarViewItemHeightPadding;
            }

            spacerWidth = kPBCalendarViewWidthLeadingPadding;

        } else if (day == 1) {

            spacerWidth =
            kPBCalendarViewWidthLeadingPadding + ((firstDayOfTheWeek - 1) * itemWidth);
        }

        if (spacerWidth > 0.0f) {

            PBCollectionItem *spacerItem = [self spacerItem:@(day-1) realDay:@(day)];
            spacerItem.point = CGPointMake(xPos, yPos);
            spacerItem.size =
            CGSizeMake(spacerWidth, kPBCalendarViewItemHeight);

            [items addObject:spacerItem];

            xPos += spacerWidth;
        }

        NSDateComponents *dayComponents = [[NSDateComponents alloc] init];
        dayComponents.year = self.year;
        dayComponents.month = self.month;
        dayComponents.day = day;

        PBCollectionItem *item =
        [PBCollectionItem
         customClassItemWithUserContext:dayComponents
         reuseIdentifier:[NSString stringWithFormat:@"day-%ld", (long)day]
         cellClass:[PBCalendarDayCell class]
         configure:^(PBCollectionViewController *viewController, PBCollectionItem *item, PBCalendarDayCell *cell) {

         } binding:^(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item2, PBCalendarDayCell *cell) {

             NSDateComponents *dayComponents = item2.userContext;
             cell.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)dayComponents.day];

             cell.year = dayComponents.year;
             cell.month = dayComponents.month;
             cell.day = dayComponents.day;
             cell.realDay = dayComponents.day;
             cell.selectedDateRange = self.selectedDateRange;

             cell.currentDay =
             dayComponents.day == nowComponents.day &&
             dayComponents.year == nowComponents.year &&
             dayComponents.month == nowComponents.month;

         } selectAction:^(PBCollectionViewController *viewController) {

         } deleteAction:nil];

        item.size = CGSizeMake(itemWidth, kPBCalendarViewItemHeight);
        item.point = CGPointMake(xPos, yPos);

        [items addObject:item];

        xPos += itemWidth;

        spacerWidth = 0.0f;

        if (dayPosition == (daysInWeek - 1)) {
            spacerWidth = kPBCalendarViewWidthTrailingPadding;
        } else if (day == days.length) {
            spacerWidth = kPBCalendarViewWidthTrailingPadding + (daysInWeek - dayPosition) * itemWidth;
        }

        if (spacerWidth > 0.0f) {
            PBCollectionItem *spacerItem = [self spacerItem:@(day+1) realDay:@(day)];
            spacerItem.point = CGPointMake(xPos, yPos);

            spacerItem.size =
            CGSizeMake(spacerWidth, kPBCalendarViewItemHeight);
            [items addObject:spacerItem];
        }

        day++;
    }

    return items;
}

- (void)updateMonthTitle {

    NSDate *date =
    [NSDate dateWithYear:self.year month:self.month day:1];

    NSLocale *locale = [NSLocale currentLocale];

    NSString *dateComponents = @"MMMMy";

    NSString *dateFormat =
    [NSDateFormatter
     dateFormatFromTemplate:dateComponents
     options:0
     locale:locale];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;

    self.monthTitle.text = [dateFormatter stringFromDate:date];
    [self.monthTitle sizeToFit];
}

- (void)updateCollectionView {

    if (_dataSourceDirty) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

            self.dataSource = [self buildItems];
            self.collectionViewController.providedDataSource = self.dataSource;

            dispatch_async(dispatch_get_main_queue(), ^{

                [self.collectionViewController reloadData];
                _dataSourceDirty = NO;
            });
	    });
    } else {
        [self.collectionViewController reloadData];
    }
}

- (void)updateView {
    [self updateMonthTitle];
    [self updateCollectionView];
}

#pragma mark - UIView

- (void)layoutSubviews {

    if (self.collectionViewController == nil) {

        [self setupMonthTitle];
        if (self.year == 0) {
            [self setYearAndMonthFromDate:[NSDate date]];
        }
        [self setupCollectionViewController];
    }

    [super layoutSubviews];
}

@end
