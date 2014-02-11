//
//  TUCalendarViewController.m
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TUCalendarViewController.h"
#import "PBCalendarView.h"
#import "PBMonthView.h"
#import "PBRunningAverageValue.h"

static CGFloat const kPBCalendarSelectionViewControllerNavigationBarHeight = 64.0f;
static CGFloat const kPBCalendarSelectionViewControllerToolbarHeight = 40.0f;
static CGFloat const kPBCalendarSelectionViewCurrentMonthAlpha = .7f;
static CGFloat const kPBCalendarSelectionViewShowCurrentMonthScrollVelocityThreshold = 1.4f;
static CGFloat const kPBCalendarSelectionViewHideCurrentMonthScrollVelocityStartThreshold = 300.0f;

@interface TUCalendarViewController () <UIScrollViewDelegate> {

    BOOL _rangeMode;
    NSTimeInterval _lastScrollTime;
    CGFloat _lastScrollPosition;
    BOOL _decelerating;
    BOOL _animatingCurrentMonth;
    BOOL _animatingCurrentSelection;
    BOOL _monthIndicatorVisible;
    BOOL _monthIndicatorHiding;
    NSTimeInterval _monthIndicatorStopTime;
    NSTimeInterval _lastMonthIndicatorTrigger;
}

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UINavigationBar *navbar;
@property (nonatomic, strong) PBCalendarView *calendarView;
@property (nonatomic, readwrite) BOOL modeSwitchOn;
@property (nonatomic, strong) UIBarButtonItem *rangeToggleItem;
@property (nonatomic, strong) UIBarButtonItem *currentMonthItem;
@property (nonatomic, strong) UIBarButtonItem *currentSelectionItem;
@property (nonatomic, readonly) PBDateRange *selectedDateRange;
@property (nonatomic, strong) PBDateRange *initialSelectedDateRange;
@property (nonatomic, strong) UIView *monthIndicatorContainer;
@property (nonatomic, strong) UILabel *monthIndicatorLabel;
@property (nonatomic, strong) NSDate *currentMonth;
@property (nonatomic, strong) NSArray *visibleMonthViews;
@property (nonatomic) CGRect visibleRect;
@property (nonatomic, strong) PBRunningAverageValue *averageScrollSpeed;

@end

@implementation TUCalendarViewController

- (id)initWithSelectedDate:(NSDate *)date
              modeSwitchOn:(BOOL)modeSwitchOn {

    self = [super init];
    if (self) {
        self.initialSelectedDateRange =
        [PBDateRange dateRangeWithStartDate:date endDate:date];
        self.modeSwitchOn = modeSwitchOn;
        self.averageScrollSpeed = [[PBRunningAverageValue alloc] init];
    }
    return self;
}

- (id)initWithSelectedDateRange:(PBDateRange *)dateRange
                   modeSwitchOn:(BOOL)modeSwitchOn {

    self = [super init];
    if (self) {
        self.initialSelectedDateRange = dateRange;
        self.modeSwitchOn = modeSwitchOn;

        _rangeMode =
        [dateRange.endDate.midnight isGreaterThan:dateRange.startDate];
        self.averageScrollSpeed = [[PBRunningAverageValue alloc] init];
    }
    return self;
}

#pragma mark - Setup

- (void)setupNavigationBar {

    UINavigationItem *navigationItem;

    if (self.navigationController == nil) {

        self.navbar = [[UINavigationBar alloc] init];
        self.navbar.translatesAutoresizingMaskIntoConstraints = NO;
        self.navbar.translucent = YES;
        self.navbar.barTintColor = [UIColor whiteColor];

        navigationItem = [[UINavigationItem alloc] init];

        self.navbar.items = @[navigationItem];

        [self.view addSubview:self.navbar];

        [NSLayoutConstraint
         addHeightConstraint:kPBCalendarSelectionViewControllerNavigationBarHeight
         toView:self.navbar];

        [NSLayoutConstraint expandWidthToSuperview:self.navbar];

        [NSLayoutConstraint alignToTop:self.navbar withPadding:0.0f];

    } else {

        navigationItem = self.navigationItem;
    }

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

    UIBarButtonItem *flexSpacer =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
     target:nil
     action:nil];

    UIBarButtonItem *spacer =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
     target:nil
     action:nil];
    spacer.width = 12.0f;

    self.currentMonthItem =
    [[UIBarButtonItem alloc]
     initWithTitle:PBLoc(@"Today")
     style:UIBarButtonItemStylePlain
     target:self
     action:@selector(showToday:)];

    self.currentSelectionItem =
    [[UIBarButtonItem alloc]
     initWithTitle:PBLoc(@"Selection")
     style:UIBarButtonItemStylePlain
     target:self
     action:@selector(showCurrentSelection:)];

    NSMutableArray *items = [NSMutableArray array];

    if (self.modeSwitchOn) {
        [items addObject:self.rangeToggleItem];
    }
    
    [items addObject:flexSpacer];
    [items addObject:self.currentSelectionItem];
    [items addObject:spacer];
    [items addObject:self.currentMonthItem];

    self.toolbar.items = items;
    [self updateToolbarItems];
}

- (void)setupCalendarView {
	self.calendarView = [[PBCalendarView alloc] initWithFrame:self.view.bounds];
    self.calendarView.delegate = self;
	self.calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_calendarView];

    self.calendarView.selectedDateRange = self.initialSelectedDateRange;
}

- (void)setupmonthIndicatorLabel {

    self.monthIndicatorContainer = [[UIView alloc] init];
    self.monthIndicatorContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.monthIndicatorContainer.alpha = 0.0f;
    _monthIndicatorVisible = NO;

    [self.view addSubview:self.monthIndicatorContainer];

    [NSLayoutConstraint
     alignToTop:self.monthIndicatorContainer
     withPadding:kPBCalendarSelectionViewControllerNavigationBarHeight];

    [NSLayoutConstraint expandWidthToSuperview:self.monthIndicatorContainer];
    [NSLayoutConstraint
     addHeightConstraint:40.0f
     toView:self.monthIndicatorContainer];

    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    backgroundView.backgroundColor = self.view.tintColor;
    backgroundView.alpha = kPBCalendarSelectionViewCurrentMonthAlpha;

    [self.monthIndicatorContainer addSubview:backgroundView];
    [NSLayoutConstraint expandToSuperview:backgroundView];

    self.monthIndicatorLabel = [[UILabel alloc] init];
    self.monthIndicatorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.monthIndicatorLabel.textColor = [UIColor blackColor];
    self.monthIndicatorLabel.textAlignment = NSTextAlignmentCenter;
    self.monthIndicatorLabel.font =
    [UIFont fontWithName:@"HelveticaNeue" size:16.0f];

    [self.monthIndicatorContainer addSubview:self.monthIndicatorLabel];
    [NSLayoutConstraint expandToSuperview:self.monthIndicatorLabel];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupCalendarView];
    [self setupNavigationBar];
    [self setupToolbar];
    [self setupmonthIndicatorLabel];

    CGFloat height =
    CGRectGetHeight(self.view.frame) -
    kPBCalendarSelectionViewControllerNavigationBarHeight -
    kPBCalendarSelectionViewControllerToolbarHeight;

    self.visibleRect =
    CGRectMake(0.0f,
               kPBCalendarSelectionViewControllerNavigationBarHeight,
               CGRectGetWidth(self.view.frame),
               height);

    self.calendarView.visibleBounds = self.visibleRect;

    self.calendarView.contentMargins =
    UIEdgeInsetsMake(kPBCalendarSelectionViewControllerNavigationBarHeight,
                     0.0f,
                     kPBCalendarSelectionViewControllerToolbarHeight,
                     0.0f);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showCurrentSelection:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Getters and Setters

- (PBDateRange *)selectedDateRange {
    return self.calendarView.selectedDateRange;
}

#pragma mark - Actions

- (void)cancelPressed:(id)sender {
    [self.delegate calendarSelectionViewControllerCancelled:self];
}

- (void)donePressed:(id)sender {
    [self.delegate calendarSelectionViewController:self didSelectedRange:self.selectedDateRange];
}

- (void)showToday:(id)sender {

    _animatingCurrentMonth = YES;
//    self.currentMonthItem.enabled = NO;

	[self.calendarView scrollToMonth:[NSDate date] animated:YES];

    NSTimeInterval delayInSeconds = .3f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _animatingCurrentMonth = NO;
    });
}

- (void)showCurrentSelection:(id)sender {

    _animatingCurrentSelection = YES;
    self.currentSelectionItem.enabled = NO;

    [self.calendarView scrollToMonth:self.selectedDateRange.startDate animated:YES];

    NSTimeInterval delayInSeconds = .3f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _animatingCurrentSelection = NO;
    });
}

#pragma mark -

- (void)updateToolbarItems {

    NSString *title;

    if (_rangeMode) {

        title = PBLoc(@"Single Day");
    } else {

        title = PBLoc(@"Date Range");
    }

    self.rangeToggleItem.title = title;

    __block BOOL currentMonthItemEnabled = YES;
    __block BOOL currentSelectionItemEnabled = YES;

    [self.visibleMonthViews enumerateObjectsUsingBlock:^(PBMonthView *monthView, NSUInteger idx, BOOL *stop) {

        NSDateComponents *monthComponents =
        [monthView.month components:NSCalendarUnitYear|NSCalendarUnitMonth];

        NSInteger days =
        [monthView.month
         rangeOfUnit:NSCalendarUnitDay
         inUnit:NSCalendarUnitMonth].length;

        NSDate *endDate =
        [NSDate
         dateWithYear:monthComponents.year
         month:monthComponents.month
         day:days];

        BOOL overlapping =
        [self.selectedDateRange.startDate isLessThanOrEqualTo:endDate] &&
        [self.selectedDateRange.endDate isGreaterThanOrEqualTo:monthView.month];

        if (overlapping) {
            currentSelectionItemEnabled = NO;
        }

        PBDateRange *currentMonthRange =
        [PBDateRange
         dateRangeWithStartDate:monthView.month
         endDate:endDate];

        if ([currentMonthRange dateWithinRange:[NSDate date]]) {
            currentMonthItemEnabled = NO;
        }
    }];

    if (_animatingCurrentMonth == NO) {

        if (self.currentMonthItem.enabled != currentMonthItemEnabled) {
//            self.currentMonthItem.enabled = currentMonthItemEnabled;
        }
    }

    if (_animatingCurrentSelection == NO) {
        self.currentSelectionItem.enabled = currentSelectionItemEnabled;
    }

//    NSDateComponents *monthComponents =
//    [[NSDate date] components:NSCalendarUnitYear|NSCalendarUnitMonth];
//
//    NSDate *currentMonthDate =
//    [NSDate
//     dateWithYear:monthComponents.year
//     month:monthComponents.month
//     day:1];
//
//    [self.visibleMonthViews enumerateObjectsUsingBlock:^(PBMonthView *monthView, NSUInteger idx, BOOL *stop) {
//
//        if ([currentMonthDate isEqualToDate:monthView.month]) {
//        }
//    }];
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

    NSDate *endDate =
    [self.selectedDateRange.startDate dateByAddingDays:6];

//    self.selectedDateRange =
//    [PBDateRange
//     dateRangeWithStartDate:self.selectedDateRange.startDate
//     endDate:endDate];

//    [self updateVisibleCalendarSelection];
}

- (void)switchToSingleSelectionMode {

//    self.selectedDateRange =
//    [PBDateRange
//     dateRangeWithStartDate:self.selectedDateRange.startDate
//     endDate:self.selectedDateRange.startDate];

//    [self updateVisibleCalendarSelection];
}

- (void)showMonthIndicatorContainer {

    self.monthIndicatorContainer.alpha = 0.0f;

    [UIView
     animateWithDuration:.3f
     animations:^{
         self.monthIndicatorContainer.alpha = 1.0f;
     } completion:^(BOOL finished) {
         _monthIndicatorVisible = YES;
     }];
}

- (void)hideMonthIndicatorContainer {

    _monthIndicatorHiding = YES;

    [UIView
     animateWithDuration:.3f
     animations:^{
         self.monthIndicatorContainer.alpha = 0.0f;
     } completion:^(BOOL finished) {
         _monthIndicatorHiding = NO;
         _monthIndicatorVisible = NO;
     }];
}

- (void)updateCurrentMonth {

    CGFloat height =
    CGRectGetHeight(self.view.frame) -
    kPBCalendarSelectionViewControllerNavigationBarHeight -
    kPBCalendarSelectionViewControllerToolbarHeight;

    CGRect rect =
    CGRectMake(0.0f,
               kPBCalendarSelectionViewControllerNavigationBarHeight,
               CGRectGetWidth(self.view.frame),
               height);

    NSArray *visibleMonthViews =
    [self.calendarView
     monthViewsBoundByRect:rect
     inView:self.view
     completelyVisible:YES];

    BOOL visibleMonthsChanged =
    [visibleMonthViews isEqualToArray:self.visibleMonthViews] == NO;

    self.visibleMonthViews = visibleMonthViews;

    NSDate *currentMonth = [self.calendarView currentMonth];

    if ([currentMonth isEqualToDate:self.currentMonth] == NO) {

        NSLocale *locale = [NSLocale currentLocale];

        NSString *dateComponents = @"MMMMy";

        NSString *dateFormat =
        [NSDateFormatter
         dateFormatFromTemplate:dateComponents
         options:0
         locale:locale];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = dateFormat;

        self.monthIndicatorLabel.text = [dateFormatter stringFromDate:currentMonth];

        self.currentMonth = currentMonth;
    }

    if (visibleMonthsChanged) {
        [self updateToolbarItems];
    }
}

#pragma mark - UIScrollViewDelegate Conformance

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    NSTimeInterval beginDraggingTime = [NSDate timeIntervalSinceReferenceDate];

    NSTimeInterval delayInSeconds = .3f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        if (_lastMonthIndicatorTrigger < beginDraggingTime) {
            [self hideMonthIndicatorContainer];
        }
    });
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _decelerating = decelerate;

    if (decelerate) {
        self.currentMonth = nil;
        _lastScrollPosition = scrollView.contentOffset.y;
        _lastScrollTime = [NSDate timeIntervalSinceReferenceDate];
        [self.averageScrollSpeed clearRunningValues];
    } else {
        [self hideMonthIndicatorContainer];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _decelerating = NO;
    [self updateCurrentMonth];
    [self hideMonthIndicatorContainer];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {

    CGPoint point;

    if ((_monthIndicatorVisible == NO || _monthIndicatorHiding) &&
        ABS(velocity.y) > kPBCalendarSelectionViewShowCurrentMonthScrollVelocityThreshold) {

        [self showMonthIndicatorContainer];
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal * 2.0f;

        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];

        _lastMonthIndicatorTrigger = now;
        _monthIndicatorStopTime = (3.0f * .8f) + now;
    }

    if (velocity.y != 0.0f && _monthIndicatorVisible) {
        CGFloat targetY = scrollView.contentOffset.y + velocity.y * 600.0;
        point = CGPointMake(0.0f, targetY);

//        NSLog(@"contentOffset: %@", NSStringFromCGPoint(point));

        // convert content offset to centered point in visible rect

        point.y += kPBCalendarSelectionViewControllerNavigationBarHeight;
        point.y += (CGRectGetHeight(self.visibleRect) / 2.0f);

        *targetContentOffset =
        [self.calendarView centeredContentOffsetAtPoint:point];

//        NSLog(@"targetContentOffset: %@", NSStringFromCGPoint(*targetContentOffset));
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [self updateCurrentMonth];

    if (_decelerating) {

        CGFloat scrollPosition = scrollView.contentOffset.y;
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];

        NSTimeInterval deltaT = now - _lastScrollTime;
        CGFloat deltaY = scrollPosition - _lastScrollPosition;
        CGFloat speed = ABS(deltaY / deltaT);

        if (speed < 50000.0f ) {

            self.averageScrollSpeed.value = speed;


        }

        if (now >= _monthIndicatorStopTime &&
            self.averageScrollSpeed.value < kPBCalendarSelectionViewHideCurrentMonthScrollVelocityStartThreshold) {
            [self hideMonthIndicatorContainer];
        } else {
            _lastMonthIndicatorTrigger = now;
        }

        _lastScrollPosition = scrollPosition;
        _lastScrollTime = now;
    }
}

- (void)calendarViewSelected:(PBCalendarView *)calendarView
      selectedRangeDidChange:(PBDateRange *)dateRange {

    [self updateToolbarItems];
}

@end
