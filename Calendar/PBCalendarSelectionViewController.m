//
//  PBCalendarSelectionViewController.m
//  Calendar
//
//  Created by Nick Bolton on 1/19/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCalendarSelectionViewController.h"
#import "Bedrock.h"
#import "PBCalendarView.h"
#import "NSCalendar+Bedrock.h"

static NSInteger const kPBCalendarSelectionViewControllerVisibleMonths = 5;
static CGFloat kPBCalendarSelectionViewControllerItemHeight = 264.0f;
static CGFloat kPBCalendarSelectionViewControllerNavigationBarHeight = 64.0f;
static CGFloat kPBCalendarSelectionViewControllerToolbarHeight = 40.0f;
static NSInteger const kPBCalendarSelectionViewControllerCalendarTag = 999;

@interface PBCalendarSelectionViewController () <UIGestureRecognizerDelegate> {

    BOOL _rangeMode;
    BOOL _infiniteDisabled;
    BOOL _scrollAdvancing;
    NSInteger _scrollAdvancingMonthDirection;
}

@property (nonatomic, strong) PBDateRange *selectedDateRange;
@property (nonatomic, strong) NSDate *currentStartDate;
@property (nonatomic, strong) UIBarButtonItem *rangeToggleItem;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UINavigationBar *navbar;
@property (nonatomic, strong) NSMutableDictionary *calendarViews;
@property (nonatomic, strong) NSDate *draggingStartDate;
@property (nonatomic, strong) NSDate *draggingEndDate;
@property (nonatomic, readwrite) BOOL modeSwitchOn;

@end

@implementation PBCalendarSelectionViewController

+ (void)presentCalendarSelectionViewController:(UIViewController *)presentingViewController
                                      delegate:(id <PBCalendarSelectionDelegate>)delegate
                                  modeSwitchOn:(BOOL)modeSwitchOn
                         withSelectedDateRange:(PBDateRange *)dateRange
                                    completion:(void(^)(void))completionBlock {

    PBCalendarSelectionViewController *viewController =
    [[PBCalendarSelectionViewController alloc]
     initWithSelectedDateRange:dateRange
     modeSwitchOn:modeSwitchOn];

    viewController.delegate = delegate;

    [UINavigationController
     presentViewController:viewController
     fromViewController:presentingViewController
     completion:completionBlock];
}

+ (void)presentCalendarSelectionViewController:(UIViewController *)presentingViewController
                                      delegate:(id <PBCalendarSelectionDelegate>)delegate
                                  modeSwitchOn:(BOOL)modeSwitchOn
                              withSelectedDate:(NSDate *)date
                                    completion:(void(^)(void))completionBlock {

    PBCalendarSelectionViewController *viewController =
    [[PBCalendarSelectionViewController alloc]
     initWithSelectedDate:date
     modeSwitchOn:modeSwitchOn];

    viewController.delegate = delegate;

    [UINavigationController
     presentViewController:viewController
     fromViewController:presentingViewController
     completion:completionBlock];
}

- (id)initWithSelectedDate:(NSDate *)date
              modeSwitchOn:(BOOL)modeSwitchOn {

    self = [super init];
    if (self) {
        self.currentStartDate = date;
        self.modeSwitchOn = modeSwitchOn;
        [self _commonInit];
    }
    return self;
}

- (id)initWithSelectedDateRange:(PBDateRange *)dateRange
                   modeSwitchOn:(BOOL)modeSwitchOn {

    self = [super init];
    if (self) {
        self.selectedDateRange = dateRange;
        self.currentStartDate = dateRange.startDate;
        self.modeSwitchOn = modeSwitchOn;
        [self _commonInit];

        _rangeMode =
        [dateRange.endDate.midnight isGreaterThan:dateRange.startDate];
    }
    return self;
}

- (void)_commonInit {
    self.calendarViews = [NSMutableDictionary dictionary];
}

#pragma mark - Setup

- (void)setupNavigationBar {

    self.navbar = [[UINavigationBar alloc] init];
    self.navbar.translatesAutoresizingMaskIntoConstraints = NO;
    self.navbar.translucent = YES;
    self.navbar.barTintColor = [UIColor whiteColor];

    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];

    self.navbar.items = @[navigationItem];

    [self.view addSubview:self.navbar];

    [NSLayoutConstraint
     addHeightConstraint:kPBCalendarSelectionViewControllerNavigationBarHeight
     toView:self.navbar];

    [NSLayoutConstraint expandWidthToSuperview:self.navbar];

    [NSLayoutConstraint alignToTop:self.navbar withPadding:0.0f];

    UIBarButtonItem *cancelItem =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
     target:self
     action:@selector(cancelPressed:)];

    UIBarButtonItem *doneItem =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
     target:self
     action:@selector(donePressed:)];

    navigationItem.leftBarButtonItem = cancelItem;
    navigationItem.rightBarButtonItem = doneItem;

    if (self.modeSwitchOn) {

        navigationItem.title = PBLoc(@"Select Day or Range");

    } else {

        if (_rangeMode) {

            navigationItem.title = PBLoc(@"Select Range");

        } else {

            navigationItem.title = PBLoc(@"Select Day");
        }
    }
}

- (void)setupToolbar {

    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    self.toolbar.translucent = YES;
    self.toolbar.barTintColor = [UIColor whiteColor];

    [self.view addSubview:self.toolbar];

    [NSLayoutConstraint
     addHeightConstraint:kPBCalendarSelectionViewControllerToolbarHeight
     toView:self.toolbar];

    [NSLayoutConstraint expandWidthToSuperview:self.toolbar];

    [NSLayoutConstraint alignToBottom:self.toolbar withPadding:0.0f];

    self.rangeToggleItem =
    [[UIBarButtonItem alloc]
     initWithTitle:@""
     style:UIBarButtonItemStylePlain
     target:self
     action:@selector(toggleRangeMode)];

    UIBarButtonItem *spacer =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
     target:nil
     action:nil];

    UIBarButtonItem *currentMonthItem =
    [[UIBarButtonItem alloc]
     initWithTitle:PBLoc(@"Jump to Today")
     style:UIBarButtonItemStylePlain
     target:self
     action:@selector(jumpToCurrentMonth)];

    NSMutableArray *items = [NSMutableArray array];

    if (self.modeSwitchOn) {
        [items addObject:self.rangeToggleItem];
    }

    [items addObject:spacer];
    [items addObject:currentMonthItem];

    self.toolbar.items = items;
    [self updateToolbarItems];
}

- (void)setupGestures {

    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(handleTap:)];

    tapGesture.delegate = self;

    [self.view addGestureRecognizer:tapGesture];

    UIPanGestureRecognizer *panGesture =
    [[UIPanGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(handlePan:)];

    [tapGesture requireGestureRecognizerToFail:panGesture];

    panGesture.delegate = self;

    [self.view addGestureRecognizer:panGesture];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGestures];
    [self setupToolbar];
    self.tableView.contentOffset = [self zeroContentOffset];
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Data Source

- (void)pruneCalendarViews {
}

- (PBListItem *)itemForMonthDate:(NSDate *)monthDate {

    PBListItem *item =
    [PBListItem
     customClassItemWithUserContext:monthDate
     cellID:@"cell-id"
     cellClass:[PBListCell class]
     configure:^(id viewController, PBListItem *item, PBListCell *cell) {

         NSDate *monthDate = item.userContext;

         PBCalendarView *calendarView =
         self.calendarViews[monthDate];

         NSAssert(calendarView != nil,
                  @"no calendarView for monthDate: %@", monthDate);

         [calendarView removeFromSuperview];

         [cell.contentView addSubview:calendarView];

         [NSLayoutConstraint expandToSuperview:calendarView];

     } binding:^(id viewController, NSIndexPath *indexPath, PBListItem *item, PBListCell *cell) {

         NSDate *monthDate = item.userContext;

         PBCalendarView *calendarView =
         (id)[cell.contentView viewWithTag:kPBCalendarSelectionViewControllerCalendarTag];

         calendarView.selectedDateRange = self.selectedDateRange;

         NSCalendar *calendar =
         [[PBCalendarManager sharedInstance] calendarForCurrentThread];

         NSDateComponents *dateComponents =
         [calendar
          components:NSCalendarUnitYear|NSCalendarUnitMonth
          fromDate:monthDate];

         [calendarView
          setYear:dateComponents.year
          month:dateComponents.month];

     } selectAction:nil
     deleteAction:nil];

    item.rowHeight = kPBCalendarSelectionViewControllerItemHeight;
    item.separatorInsets = self.separatorInsets;

    return item;
}

- (NSArray *)buildDataSource {

    NSArray *items;

    if (_scrollAdvancing) {

        PBSectionItem *sectionItem = self.dataSource.firstObject;

        NSMutableArray *updatedDataSource =
        [sectionItem.items mutableCopy];

        NSDate *monthDate = self.currentStartDate;
        NSCalendar *calendar =
        [[PBCalendarManager sharedInstance] calendarForCurrentThread];

        if (_scrollAdvancingMonthDirection < 0) {

            [updatedDataSource removeLastObject];

            NSDateComponents *monthComponents = [[NSDateComponents alloc] init];
            monthComponents.month = -2;

            monthDate =
            [calendar
             dateByAddingComponents:monthComponents
             toDate:monthDate
             options:0];

            PBListItem *addedItem =
            [self itemForMonthDate:monthDate];

            [updatedDataSource insertObject:addedItem atIndex:0];

        } else {

            [updatedDataSource removeObjectAtIndex:0];

            NSDateComponents *monthComponents = [[NSDateComponents alloc] init];
            monthComponents.month = 2;

            monthDate =
            [calendar
             dateByAddingComponents:monthComponents
             toDate:monthDate
             options:0];

            PBListItem *addedItem =
            [self itemForMonthDate:monthDate];

            [updatedDataSource addObject:addedItem];
        }

        items = updatedDataSource;

    } else {

        items = [self buildFullDataSource];
    }

    return items;
}

- (NSArray *)buildFullDataSource {

    NSMutableArray *items = [NSMutableArray array];

    NSDate *monthDate = self.currentStartDate;
    NSCalendar *calendar =
    [[PBCalendarManager sharedInstance] calendarForCurrentThread];

    NSDateComponents *monthComponents = [[NSDateComponents alloc] init];

    monthComponents.month = -3;

    monthDate =
    [calendar
     dateByAddingComponents:monthComponents
     toDate:monthDate
     options:0];

    monthComponents.month = 1;

    NSMutableDictionary *calendarViews = [NSMutableDictionary dictionary];

    for (NSInteger i = -1; i < kPBCalendarSelectionViewControllerVisibleMonths + 1; i++) {

        PBCalendarView *calendarView = self.calendarViews[monthDate];

        if (calendarView == nil) {

            calendarView = [[PBCalendarView alloc] init];
            calendarView.translatesAutoresizingMaskIntoConstraints = NO;
            calendarView.tag = kPBCalendarSelectionViewControllerCalendarTag;

            NSDateComponents *dateComponents =
            [calendar
             components:NSCalendarUnitYear|NSCalendarUnitMonth
             fromDate:monthDate];

            [calendarView
             setYear:dateComponents.year
             month:dateComponents.month];
        }

        calendarViews[monthDate] = calendarView;

        monthDate =
        [calendar
         dateByAddingComponents:monthComponents
         toDate:monthDate
         options:0];
    }

    self.calendarViews = calendarViews;

    monthComponents.month = -2;

    monthDate =
    [calendar
     dateByAddingComponents:monthComponents
     toDate:self.currentStartDate
     options:0];

    monthComponents.month = 1;

    for (NSInteger i = 0; i < kPBCalendarSelectionViewControllerVisibleMonths; i++) {

        PBListItem *item = [self itemForMonthDate:monthDate];

        [items addObject:item];

        monthDate =
        [calendar
         dateByAddingComponents:monthComponents
         toDate:monthDate
         options:0];
    }

    return items;
}

#pragma mark - Actions

- (void)cancelPressed:(id)sender {
    [self.delegate calendarSelectionViewControllerCancelled:self];
}

- (void)donePressed:(id)sender {
    [self.delegate calendarSelectionViewController:self didSelectedRange:self.selectedDateRange];
}

#pragma mark - Getters and Setters

- (void)setCurrentStartDate:(NSDate *)currentStartDate {

    NSCalendar *calendar =
    [[PBCalendarManager sharedInstance] calendarForCurrentThread];

    NSDateComponents *dateComponents =
    [calendar
     components:NSCalendarUnitYear|NSCalendarUnitMonth
     fromDate:currentStartDate];

    _currentStartDate =
    [NSDate
     dateWithYear:dateComponents.year
     month:dateComponents.month
     day:1];
}

#pragma mark - UITableViewDelegate Conformance

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

//    NSLog(@"co: %@", NSStringFromCGPoint(scrollView.contentOffset));

    CGPoint location = [scrollView.panGestureRecognizer locationInView:self.view];

    NSDate *date = [self dateAtPoint:location];

    if (date != nil) {

        if ([date isEqualToDate:self.selectedDateRange.startDate]) {
            self.tableView.scrollEnabled = NO;
            return;
        } else if ([date isEqualToDate:self.selectedDateRange.endDate.midnight]) {
            self.tableView.scrollEnabled = NO;
            return;
        }
    }

    if (_infiniteDisabled) return;

    CGFloat backThreshold =
    kPBCalendarSelectionViewControllerItemHeight * (kPBCalendarSelectionViewControllerVisibleMonths - 2.5);
    CGFloat frontThreshold =
    kPBCalendarSelectionViewControllerItemHeight * 1.5;

    CGPoint currentOffset = scrollView.contentOffset;
    if (currentOffset.y < frontThreshold) {

        CGFloat distanceFromThreshold =
        currentOffset.y - kPBCalendarSelectionViewControllerItemHeight/2.0f;

        CGFloat offset =
        kPBCalendarSelectionViewControllerItemHeight +
        kPBCalendarSelectionViewControllerItemHeight/2.0f +
        distanceFromThreshold;

        _infiniteDisabled = YES;
        [self addCalendarMonthDirection:-1 offset:offset];
        _infiniteDisabled = NO;

    } else if (currentOffset.y >= backThreshold) {

        CGFloat distanceFromThreshold =
        currentOffset.y - kPBCalendarSelectionViewControllerItemHeight/2.0f;

        CGFloat offset =
        backThreshold +
        kPBCalendarSelectionViewControllerItemHeight -
        distanceFromThreshold;

        _infiniteDisabled = YES;
        [self addCalendarMonthDirection:1 offset:offset];
        _infiniteDisabled = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark -

- (CGPoint)zeroContentOffset {

    CGFloat topSpaceInView =
    kPBCalendarSelectionViewControllerItemHeight -
    (CGRectGetHeight(self.view.frame) -
     kPBCalendarSelectionViewControllerItemHeight) / 2.0f;

    return
    CGPointMake(0.0f, kPBCalendarSelectionViewControllerItemHeight + topSpaceInView);
}

- (void)updateToolbarItems {

    NSString *title;

    if (_rangeMode) {

        title = PBLoc(@"Single Day");
    } else {

        title = PBLoc(@"Date Range");
    }

    self.rangeToggleItem.title = title;
}

- (void)toggleRangeMode {

    self.toolbar.userInteractionEnabled = NO;

    _rangeMode = _rangeMode == NO;

    if (_rangeMode) {
        [self switchToRangeMode];
    } else {
        [self switchToSingleSelectionMode];
    }

    [self updateToolbarItems];

    self.toolbar.userInteractionEnabled = YES;
}

- (void)switchToRangeMode {

    NSCalendar *calendar =
    [[PBCalendarManager sharedInstance] calendarForCurrentThread];

    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = 6;

    NSDate *endDate =
    [calendar
     dateByAddingComponents:dateComponents
     toDate:self.selectedDateRange.startDate
     options:0];

    self.selectedDateRange =
    [PBDateRange
     dateRangeWithStartDate:self.selectedDateRange.startDate
     endDate:endDate];

    [self updateVisibleCalendarSelection];
}

- (void)switchToSingleSelectionMode {

    self.selectedDateRange =
    [PBDateRange
     dateRangeWithStartDate:self.selectedDateRange.startDate
     endDate:self.selectedDateRange.startDate];

    [self updateVisibleCalendarSelection];
}

- (void)jumpToCurrentMonth {

    self.view.userInteractionEnabled = NO;
    _infiniteDisabled = YES;

    NSCalendar *calendar =
    [[PBCalendarManager sharedInstance] calendarForCurrentThread];

    NSDateComponents *dateComponents =
    [calendar
     components:NSCalendarUnitYear|NSCalendarUnitMonth
     fromDate:[NSDate date]];

    NSDate *date =
    [NSDate
     dateWithYear:dateComponents.year
     month:dateComponents.month
     day:1];

    NSDateComponents *monthComponents =
    [calendar
     components:NSCalendarUnitMonth
     fromDate:self.currentStartDate
     toDate:date
     options:0];

    if (monthComponents.month == 1) {

        CGPoint contentOffset = self.tableView.contentOffset;
        contentOffset.y -= kPBCalendarSelectionViewControllerItemHeight;

        NSLog(@"setting date: %@", date);

        self.currentStartDate = date;
        [self reloadData];
        self.tableView.contentOffset = contentOffset;

    } else if (monthComponents.month == -1) {

        CGPoint contentOffset = self.tableView.contentOffset;
        contentOffset.y += kPBCalendarSelectionViewControllerItemHeight;

        self.currentStartDate = date;
        [self reloadData];
        self.tableView.contentOffset = contentOffset;

    } else if (monthComponents.month != 0) {

        self.currentStartDate = date;
        [self reloadData];
    }

    [UIView
     animateWithDuration:.3f
     animations:^{

         self.tableView.contentOffset =
         [self zeroContentOffset];

     } completion:^(BOOL finished) {

         self.view.userInteractionEnabled = YES;
         _infiniteDisabled = NO;
     }];
}

- (void)addCalendarMonthDirection:(NSInteger)month offset:(CGFloat)offset {

    if (_scrollAdvancing) return;
    _scrollAdvancing = YES;
    _scrollAdvancingMonthDirection = month;

    NSCalendar *calendar =
    [[PBCalendarManager sharedInstance] calendarForCurrentThread];

    NSDateComponents *monthComponents =
    [[NSDateComponents alloc] init];
    monthComponents.month = month;

    self.currentStartDate =
    [calendar
     dateByAddingComponents:monthComponents
     toDate:self.currentStartDate
     options:0];

    [self reloadData];

    self.tableView.contentOffset =
    CGPointMake(self.tableView.contentOffset.x, offset);

    _scrollAdvancing = NO;
}

- (PBCalendarView *)calendarViewAtPoint:(CGPoint)point {

    __block PBCalendarView *result = nil;

    [self enumerateCalendarViews:^(PBCalendarView *calendarView, NSInteger index, BOOL *stop) {

        CGRect rectInContainer =
        [self.view
         convertRect:calendarView.bounds
         fromView:calendarView];

        if (CGRectContainsPoint(rectInContainer, point)) {
            result = calendarView;
            *stop = YES;
        }
    }];

    return result;
}

- (NSDate *)nearestDateAtPoint:(CGPoint)point {

    PBCalendarView *calendarView = [self calendarViewAtPoint:point];

    CGPoint pointInCalendarView =
    [calendarView
     convertPoint:point
     fromView:self.view];

    NSDateComponents *dateComponents =
    [calendarView nearestDateComponentsAtPoint:pointInCalendarView];

    if (dateComponents != nil) {

        return
        [NSDate
         dateWithYear:dateComponents.year
         month:dateComponents.month
         day:dateComponents.day];
    }
    
    return nil;
}

- (NSDate *)dateAtPoint:(CGPoint)point {

    PBCalendarView *calendarView = [self calendarViewAtPoint:point];

    CGPoint pointInCalendarView =
    [calendarView
     convertPoint:point
     fromView:self.view];

    NSDateComponents *dateComponents =
    [calendarView dateComponentsAtPoint:pointInCalendarView];

    if (dateComponents != nil) {

        return
        [NSDate
         dateWithYear:dateComponents.year
         month:dateComponents.month
         day:dateComponents.day];
    }

    return nil;
}

- (void)enumerateCalendarViews:(void(^)(PBCalendarView *calendarView, NSInteger index, BOOL *stop))block {

    if (block == nil) return;

    NSInteger index = 0;

    for (UIView *cell in self.tableView.visibleCells) {

        PBCalendarView *calendarView =
        (id)[cell viewWithTag:kPBCalendarSelectionViewControllerCalendarTag];

        if (calendarView != nil) {

            BOOL stop = NO;
            block(calendarView, index, &stop);

            if (stop) {
                break;
            }
        }

        index++;
    }
}

- (void)updateVisibleCalendarSelection {

    [self enumerateCalendarViews:^(PBCalendarView *calendarView, NSInteger index, BOOL *stop) {
        calendarView.selectedDateRange = self.selectedDateRange;
        [calendarView updateView];
    }];
}

#pragma mark - Gestures

- (void)handleTap:(UITapGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateEnded) {

        CGPoint location = [gesture locationInView:self.view];

        CGRect toolbarRect =
        [self.view
         convertRect:self.toolbar.bounds
         fromView:self.toolbar];

        if (CGRectContainsPoint(toolbarRect, location) == NO) {

            if (_rangeMode) {
                [self handleRangeModeTap:gesture];
            } else {
                [self handleSingleSelectionTap:gesture];
            }
        }
    }
}

- (void)handleRangeModeTap:(UIGestureRecognizer *)gesture {

    CGPoint location = [gesture locationInView:self.view];

    NSDate *date = [self dateAtPoint:location];

    if (date != nil) {

        NSCalendar *calendar =
        [[PBCalendarManager sharedInstance] calendarForCurrentThread];

        NSInteger distanceToStartDate =
        [calendar
         daysWithinEraFromDate:self.selectedDateRange.startDate
         toDate:date];

        distanceToStartDate = ABS(distanceToStartDate);

        NSInteger distanceToEndDate =
        [calendar
         daysWithinEraFromDate:self.selectedDateRange.endDate.midnight
         toDate:date];

        distanceToEndDate = ABS(distanceToEndDate);

        if (distanceToStartDate <= distanceToEndDate) {

            self.selectedDateRange =
            [PBDateRange
             dateRangeWithStartDate:date
             endDate:self.selectedDateRange.endDate];

        } else {

            self.selectedDateRange =
            [PBDateRange
             dateRangeWithStartDate:self.selectedDateRange.startDate
             endDate:date];
        }

        [self updateVisibleCalendarSelection];
    }
}

- (void)handleSingleSelectionTap:(UIGestureRecognizer *)gesture {

    CGPoint location = [gesture locationInView:self.view];

    NSDate *date = [self dateAtPoint:location];

    if (date != nil) {
        self.selectedDateRange =
        [PBDateRange
         dateRangeWithStartDate:date
         endDate:date];

        [self updateVisibleCalendarSelection];

        NSLog(@"selectedDateRange: %@", self.selectedDateRange);
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {

    if (_rangeMode) {
        [self handleRangeModePan:gesture];
    }
}

- (void)handleRangeModePan:(UIPanGestureRecognizer *)gesture {

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self handlePanBegan:gesture];
            break;

        case UIGestureRecognizerStateChanged:
            [self handlePanChanged:gesture];
            break;

        default:
            [self handlePanEnded:gesture];
            break;
    }
}

- (void)handlePanBegan:(UIGestureRecognizer *)gesture {

    CGRect toolbarRect =
    [self.view
     convertRect:self.toolbar.bounds
     fromView:self.toolbar];

    CGPoint location = [gesture locationInView:self.view];

    if (CGRectContainsPoint(toolbarRect, location) == NO) {

        NSDate *date = [self dateAtPoint:location];

        self.draggingStartDate = nil;
        self.draggingEndDate = nil;

        if (date != nil) {

            if ([date isEqualToDate:self.selectedDateRange.startDate]) {
                self.draggingStartDate = date;
                self.tableView.scrollEnabled = NO;
            } else if ([date isEqualToDate:self.selectedDateRange.endDate.midnight]) {
                self.draggingEndDate = date;
                self.tableView.scrollEnabled = NO;
            }
        }
    }
}

- (void)handlePanChanged:(UIGestureRecognizer *)gesture {

    if (self.draggingStartDate == nil && self.draggingEndDate == nil) {
        return;
    }

    CGPoint location = [gesture locationInView:self.view];

    PBCalendarView *calendarView = [self calendarViewAtPoint:location];

    NSDate *date = [self nearestDateAtPoint:location];

    if (date == nil) return;

    NSDate *startDate = self.selectedDateRange.startDate;
    NSDate *endDate = self.selectedDateRange.endDate.midnight;

    if (self.draggingStartDate != nil) {

        if ([date isLessThan:startDate] || [date isLessThanOrEqualTo:endDate]) {
            startDate = date;
            self.draggingStartDate = date;
        } else if ([date isGreaterThan:endDate]) {
            self.draggingStartDate = nil;
            self.draggingEndDate = date;

            startDate = endDate;
            endDate = date;
        }

    } else {

        if ([date isGreaterThan:endDate] || [date isGreaterThanOrEqualTo:startDate]) {
            endDate = date;
            self.draggingEndDate = date;
        } else if ([date isLessThan:startDate]) {
            endDate = startDate;
            startDate = date;
            self.draggingEndDate = nil;
            self.draggingStartDate = date;
        }
    }

    self.selectedDateRange =
    [PBDateRange
     dateRangeWithStartDate:startDate
     endDate:endDate];

    calendarView.selectedDateRange = self.selectedDateRange;
    [self reloadData];
}

- (void)handlePanEnded:(UIGestureRecognizer *)gesture {

    if (self.draggingStartDate == nil && self.draggingEndDate == nil) {
        return;
    }

    if (self.modeSwitchOn &&
        [self.selectedDateRange.startDate isEqualToDate:self.selectedDateRange.endDate.midnight]) {
        [self toggleRangeMode];
    }

    self.tableView.scrollEnabled = YES;
    NSLog(@"selectedDateRange: %@", self.selectedDateRange);
}

#pragma mark - UIGestureRecognizerDelegate Conformance

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [touch.view isDescendantOfView:self.toolbar] == NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
