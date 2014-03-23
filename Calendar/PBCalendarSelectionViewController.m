//
//  PBCalendarSelectionViewController.m
//  Bedrock
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "PBCalendarSelectionViewController.h"
#import "PBCalendarView.h"
#import "PBMonthView.h"
#import "PBRunningAverageValue.h"

typedef NS_ENUM(NSInteger, PBCalendarViewMonthIndicatorState) {

    PBCalendarViewMonthIndicatorStateHidden = 0,
    PBCalendarViewMonthIndicatorStateShowing,
    PBCalendarViewMonthIndicatorStateHiding,
    PBCalendarViewMonthIndicatorStateVisible,
};

static CGFloat const kPBCalendarSelectionViewControllerNavigationBarHeight = 64.0f;
static CGFloat const kPBCalendarSelectionViewControllerToolbarHeight = 40.0f;
static CGFloat const kPBCalendarSelectionViewCurrentMonthAlpha = .7f;
static CGFloat const kPBCalendarSelectionViewShowCurrentMonthScrollVelocityThreshold = 1.4f;
static CGFloat const kPBCalendarSelectionViewHideCurrentMonthScrollVelocityStartThreshold = 300.0f;
static CGFloat const kPBCalendarSelectionViewEndPointRadius = 16.0f;
static CGFloat const kPBCalendarSelectionPanningOutOfBoundsAdvancement = 10.0f;
static CGFloat const kPBCalendarSelectionPanningOutOfBoundsThreshold = 22.0f;
static NSTimeInterval const kPBCalendarSelectionOutOfBoundsUpdatePeriod = .3f;

@interface PBCalendarSelectionViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate> {

    BOOL _rangeMode;
    NSTimeInterval _lastScrollTime;
    CGFloat _lastScrollPosition;
    BOOL _decelerating;
    BOOL _isDragging;
    PBCalendarViewMonthIndicatorState _monthIndicatorState;
    NSTimeInterval _monthIndicatorStopTime;
    NSTimeInterval _lastMonthIndicatorTrigger;
    CGPoint _lastPanningLocation;
    NSTimeInterval _lastOutOfBoundsUpdate;
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
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) NSDate *draggingStartDate;
@property (nonatomic, strong) NSDate *draggingEndDate;
@property (nonatomic) CADisplayLink *displayLink;
@property (nonatomic, strong) UIView *endPointMarkerView;
@property (nonatomic, strong) UILabel *endPointLabel;
@property (nonatomic, strong) NSLayoutConstraint *endPointMarkerLeadingSpace;
@property (nonatomic, strong) NSLayoutConstraint *endPointMarkerTopSpace;
@property (nonatomic, strong) NSLayoutConstraint *endPointLabelLeadingSpace;
@property (nonatomic, strong) NSLayoutConstraint *endPointLabelTopSpace;

@end

@implementation PBCalendarSelectionViewController

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

- (void)setupMonthIndicatorLabel {

    self.monthIndicatorContainer = [[UIView alloc] init];
    self.monthIndicatorContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.monthIndicatorContainer.alpha = 0.0f;
    _monthIndicatorState = PBCalendarViewMonthIndicatorStateHidden;

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

- (void)setupGestures {

    self.tapGesture =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(handleTap:)];

    self.tapGesture.delegate = self;

    [self.view addGestureRecognizer:self.tapGesture];

    self.panGesture =
    [[UIPanGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(handlePan:)];

    self.panGesture.delegate = self;

    [self.view addGestureRecognizer:self.panGesture];

    [self.tapGesture requireGestureRecognizerToFail:self.panGesture];
}

- (void)setupDisplayLink {

    self.displayLink =
    [CADisplayLink
     displayLinkWithTarget:self
     selector:@selector(outOfBoundsCheck)];

    [self.displayLink
     addToRunLoop:[NSRunLoop mainRunLoop]
     forMode:NSRunLoopCommonModes];

    self.displayLink.paused = YES;
}

- (void)setupEndPointMarkerView {

    self.endPointMarkerView = [[UIView alloc] init];
    self.endPointMarkerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.endPointMarkerView.alpha = .9f;
    self.endPointMarkerView.clipsToBounds = YES;

    [self.view addSubview:self.endPointMarkerView];

    self.endPointMarkerView.layer.cornerRadius = kPBCalendarSelectionViewEndPointRadius;

    CGFloat diameter = kPBCalendarSelectionViewEndPointRadius * 2.0f;

    [NSLayoutConstraint addWidthConstraint:diameter toView:self.endPointMarkerView];
    [NSLayoutConstraint addHeightConstraint:diameter toView:self.endPointMarkerView];

    self.endPointMarkerTopSpace =
    [NSLayoutConstraint alignToTop:self.endPointMarkerView withPadding:0.0f];

    self.endPointMarkerLeadingSpace =
    [NSLayoutConstraint alignToLeft:self.endPointMarkerView withPadding:0.0f];

    self.endPointMarkerView.backgroundColor = [UIColor colorWithRGBHex:0x3060FA];
    self.endPointMarkerView.hidden = YES;

    self.endPointLabel = [[UILabel alloc] init];
    self.endPointLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.endPointLabel.textAlignment = NSTextAlignmentCenter;
    self.endPointLabel.textColor = [UIColor whiteColor];

    [self.endPointMarkerView addSubview:self.endPointLabel];

    [NSLayoutConstraint addHeightConstraint:diameter toView:self.endPointLabel];
    [NSLayoutConstraint addWidthConstraint:diameter toView:self.endPointLabel];

    self.endPointLabelTopSpace =
    [NSLayoutConstraint alignToTop:self.endPointLabel withPadding:-1.0f];

    self.endPointLabelLeadingSpace =
    [NSLayoutConstraint alignToLeft:self.endPointLabel withPadding:0.0f];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDisplayLink];
    [self setupGestures];
	[self setupCalendarView];
    [self setupNavigationBar];
    [self setupToolbar];
    [self setupMonthIndicatorLabel];
    [self setupEndPointMarkerView];

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
    self.currentMonthItem.enabled = NO;
	[self.calendarView scrollToMonth:[NSDate date] animated:YES];
}

- (void)showCurrentSelection:(id)sender {
    self.currentSelectionItem.enabled = NO;
    [self.calendarView scrollToMonth:self.selectedDateRange.startDate animated:YES];
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

    self.currentMonthItem.enabled = currentMonthItemEnabled;
    self.currentSelectionItem.enabled = currentSelectionItemEnabled;
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

    PBDateRange *dateRange =
    [self dateRangeforDate:self.selectedDateRange.startDate];

    self.calendarView.selectedDateRange = dateRange;
}

- (void)switchToSingleSelectionMode {

    self.calendarView.selectedDateRange =
    [PBDateRange
     dateRangeWithStartDate:self.selectedDateRange.startDate
     endDate:self.selectedDateRange.startDate];
}

- (BOOL)willMonthIndicatorBeVisible {
    return
    _monthIndicatorState == PBCalendarViewMonthIndicatorStateShowing ||
    _monthIndicatorState == PBCalendarViewMonthIndicatorStateVisible;
}

- (BOOL)willMonthIndicatorBeHidden {
    return
    _monthIndicatorState == PBCalendarViewMonthIndicatorStateHiding ||
    _monthIndicatorState == PBCalendarViewMonthIndicatorStateHidden;
}

- (void)showMonthIndicatorContainer {

    self.monthIndicatorContainer.alpha = 0.0f;
    _monthIndicatorState = PBCalendarViewMonthIndicatorStateShowing;

    [UIView
     animateWithDuration:.3f
     animations:^{
         self.monthIndicatorContainer.alpha = 1.0f;
     } completion:^(BOOL finished) {
         _monthIndicatorState = PBCalendarViewMonthIndicatorStateVisible;
     }];
}

- (void)hideMonthIndicatorContainer {

    _monthIndicatorState = PBCalendarViewMonthIndicatorStateHiding;

    [UIView
     animateWithDuration:.3f
     animations:^{
         self.monthIndicatorContainer.alpha = 0.0f;
     } completion:^(BOOL finished) {
         _monthIndicatorState = PBCalendarViewMonthIndicatorStateHidden;
     }];
}

- (void)ensureMonthIndicatorHides {

    if ([self willMonthIndicatorBeVisible]) {

        static CGFloat const epsilon = .0001f;
        static CGFloat const threshold = .3f;

        __weak typeof(self) this = self;

        NSTimeInterval delayInSeconds = threshold;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){

            NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
            NSTimeInterval timeDelta = now - _lastScrollTime;

            if (timeDelta > (threshold-epsilon)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [this hideMonthIndicatorContainer];
                });
            }
        });
    }
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

- (UINavigationBar *)activeNavigationBar {

    if (self.navbar != nil) {
        return self.navbar;
    }
    return self.navigationController.navigationBar;
}

- (BOOL)pointInNavbarOrToolbar:(CGPoint)point {

    CGRect toolbarRect =
    [self.view
     convertRect:self.toolbar.bounds
     fromView:self.toolbar];

    UINavigationBar *navbar = [self activeNavigationBar];

    CGRect navbarRect =
    [self.view
     convertRect:navbar.bounds
     fromView:navbar];

    return
    CGRectContainsPoint(toolbarRect, point) ||
    CGRectContainsPoint(navbarRect, point);
}

#pragma mark - End Point

- (NSDate *)dateAtPoint:(CGPoint)point {

    point = [self.calendarView convertPoint:point fromView:self.view];
    return [self.calendarView dateAtPoint:point];
}

- (NSDate *)nearestDateAtPoint:(CGPoint)point {

    point = [self.calendarView convertPoint:point fromView:self.view];
    return [self.calendarView nearestDateAtPoint:point];
}

- (CGPoint)endPointMarkingInCalendar {

    if (self.draggingStartDate != nil) {
        return [self.calendarView endPointMarkingInCalendar:YES];
    } else if (self.draggingEndDate != nil) {
        return [self.calendarView endPointMarkingInCalendar:NO];
    }

    return CGPointMake(MAXFLOAT, MAXFLOAT);
}

- (void)updateEndPointLabel:(NSDate *)date {

    if ([date.midnight isEqualToDate:[[NSDate date] midnight]]) {
        self.endPointLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
        self.endPointLabelTopSpace.constant = .5f;
    } else {
        self.endPointLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
        self.endPointLabelTopSpace.constant = -1.0f;
    }

    NSDateComponents *day = [date components:NSCalendarUnitDay];

    self.endPointLabel.text = [NSString stringWithFormat:@"%d", day.day];
}

- (void)updateFloatingStartPointMarker:(CGPoint)point forDate:(NSDate *)date {

    CGPoint pointInCalendarView = [self endPointMarkingInCalendar];

    if (pointInCalendarView.y < MAXFLOAT) {

        CGPoint pointInView =
        [self.view convertPoint:pointInCalendarView fromView:self.calendarView];

        self.endPointMarkerView.hidden = NO;

        self.endPointMarkerTopSpace.constant = pointInView.y;

        self.endPointMarkerLeadingSpace.constant =
        point.x - kPBCalendarSelectionViewEndPointRadius;

        self.endPointLabelLeadingSpace.constant =
        pointInView.x - self.endPointMarkerLeadingSpace.constant;

        [self updateEndPointLabel:date];

        [self.endPointMarkerView layoutIfNeeded];
    }
}

- (void)updateFloatingEndPointMarker:(CGPoint)point forDate:(NSDate *)date {

    CGPoint pointInCalendarView = [self endPointMarkingInCalendar];

    if (pointInCalendarView.y < MAXFLOAT) {

        CGPoint pointInView =
        [self.view convertPoint:pointInCalendarView fromView:self.calendarView];

        self.endPointMarkerView.hidden = NO;
        self.endPointMarkerTopSpace.constant = pointInView.y;

        self.endPointMarkerLeadingSpace.constant =
        point.x - kPBCalendarSelectionViewEndPointRadius;

        self.endPointLabelLeadingSpace.constant =
        pointInView.x - self.endPointMarkerLeadingSpace.constant;

        [self updateEndPointLabel:date];

        [self.endPointMarkerView layoutIfNeeded];
    }
}

- (PBDateRange *)dateRangeforDate:(NSDate *)date {

    if (date != nil) {

        NSDateComponents *dateComponents =
        [NSDateComponents
         components:NSCalendarUnitWeekday
         fromDate:date];

        NSInteger distanceStartOfWeek = [NSCalendar firstWeekday] - dateComponents.weekday;

        dateComponents.weekday = 0;

        NSDate *startDate;
        NSDate *endDate;

        if (distanceStartOfWeek <= 0) {

            dateComponents.day = distanceStartOfWeek;
            startDate = [date dateByAddingComponents:dateComponents];

            dateComponents.day = 6;
            endDate = [startDate dateByAddingComponents:dateComponents];

        } else {

            dateComponents.day = distanceStartOfWeek - 1;
            endDate = [date dateByAddingComponents:dateComponents];

            dateComponents.day = -6;
            startDate = [endDate dateByAddingComponents:dateComponents];
        }

        return
        [PBDateRange
         dateRangeWithStartDate:startDate
         endDate:endDate];
    }
    
    return nil;
}

#pragma mark - UIScrollViewDelegate Conformance

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    _isDragging = YES;

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

    _isDragging = NO;

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

    if ([self willMonthIndicatorBeHidden] &&
        ABS(velocity.y) > kPBCalendarSelectionViewShowCurrentMonthScrollVelocityThreshold) {

        [self showMonthIndicatorContainer];
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal * 2.0f;

        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];

        _lastMonthIndicatorTrigger = now;
        _monthIndicatorStopTime = (3.0f * .8f) + now;
    }

//    if (velocity.y != 0.0f && [self willMonthIndicatorBeVisible]) {
//
//        CGPoint point = *targetContentOffset;
//        point.y += kPBCalendarSelectionViewControllerNavigationBarHeight;
//        point.y += (CGRectGetHeight(self.visibleRect) / 2.0f);
//
//        *targetContentOffset =
//        [self.calendarView centeredContentOffsetAtPoint:point];
//
//        NSLog(@"targetContentOffset: %@", NSStringFromCGPoint(*targetContentOffset));
//    }
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

    [self ensureMonthIndicatorHides];
}

- (void)calendarViewSelected:(PBCalendarView *)calendarView
      selectedRangeDidChange:(PBDateRange *)dateRange {

    [self updateToolbarItems];
}

#pragma mark - Gestures

- (void)handleTap:(UITapGestureRecognizer *)gesture {

    if (self.draggingStartDate != nil || self.draggingEndDate != nil || _isDragging) {
        return;
    }

    if (gesture.state == UIGestureRecognizerStateEnded) {

        CGPoint location = [gesture locationInView:self.view];

        if ([self pointInNavbarOrToolbar:location] == NO) {

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

    NSDate *date = [self nearestDateAtPoint:location];

    PBDateRange *dateRange = [self dateRangeforDate:date];

    if (dateRange != nil) {
        self.calendarView.selectedDateRange = dateRange;
    }
}

- (void)handleSingleSelectionTap:(UIGestureRecognizer *)gesture {

    CGPoint location = [gesture locationInView:self.view];

    NSDate *date = [self nearestDateAtPoint:location];

    if (date != nil) {

        self.calendarView.selectedDateRange =
        [PBDateRange
         dateRangeWithStartDate:date
         endDate:date];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    [self handleRangeModePan:gesture];
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

    _lastPanningLocation = [gesture locationInView:self.view];
    _lastOutOfBoundsUpdate = [NSDate timeIntervalSinceReferenceDate];

    if ([self pointInNavbarOrToolbar:_lastPanningLocation] == NO) {

        NSDate *date = [self dateAtPoint:_lastPanningLocation];

        self.draggingStartDate = nil;
        self.draggingEndDate = nil;

        if (date != nil) {

            if ([date isEqualToDate:self.selectedDateRange.startDate]) {
                self.draggingStartDate = date;
            } else if ([date isEqualToDate:self.selectedDateRange.endDate.midnight]) {
                self.draggingEndDate = date;
            }
        }

        if (self.draggingStartDate != nil || self.draggingEndDate != nil) {

            self.calendarView.scrollEnabled = NO;
            self.displayLink.paused = NO;
            self.calendarView.startPointHidden = self.draggingStartDate != nil;

            if (_rangeMode) {
                self.calendarView.endPointHidden = self.draggingEndDate != nil;
            } else {
                self.calendarView.endPointHidden = self.draggingStartDate != nil;
            }

            [self.calendarView updateMonthViews:YES];
        }
    }
}

- (void)handlePanChanged:(UIGestureRecognizer *)gesture {

    if (self.draggingStartDate == nil && self.draggingEndDate == nil) {
        return;
    }

    _lastPanningLocation = [gesture locationInView:self.view];

    NSDate *date = [self nearestDateAtPoint:_lastPanningLocation];

    if (date == nil) return;

    NSDate *startDate = self.selectedDateRange.startDate;
    NSDate *endDate = self.selectedDateRange.endDate.midnight;

    if (_rangeMode) {

        if (self.draggingStartDate != nil) {

            if ([date isLessThan:startDate] || [date isLessThanOrEqualTo:endDate]) {
                startDate = date;
                self.draggingStartDate = date;
            } else if ([date isGreaterThan:endDate]) {

                self.draggingStartDate = nil;
                self.draggingEndDate = date;

                self.calendarView.startPointHidden = self.draggingStartDate != nil;
                self.calendarView.endPointHidden = self.draggingEndDate != nil;
                [self.calendarView updateMonthViews:YES];

                startDate = endDate;
                endDate = date;
            }

            [self updateFloatingStartPointMarker:_lastPanningLocation forDate:date];

        } else {

            if ([date isGreaterThan:endDate] || [date isGreaterThanOrEqualTo:startDate]) {
                endDate = date;
                self.draggingEndDate = date;
            } else if ([date isLessThan:startDate]) {
                endDate = startDate;
                startDate = date;

                self.draggingEndDate = nil;
                self.draggingStartDate = date;

                self.calendarView.startPointHidden = self.draggingStartDate != nil;
                self.calendarView.endPointHidden = self.draggingEndDate != nil;
                [self.calendarView updateMonthViews:YES];
            }

            [self updateFloatingEndPointMarker:_lastPanningLocation forDate:date];
        }

    } else {

        startDate = date;

        [self updateFloatingStartPointMarker:_lastPanningLocation forDate:date];
    }

    if ([startDate isEqualToDate:self.selectedDateRange.startDate] == NO ||
        [endDate isEqualToDate:self.selectedDateRange.endDate.midnight] == NO) {

        if (_rangeMode) {

            self.calendarView.selectedDateRange =
            [PBDateRange
             dateRangeWithStartDate:startDate
             endDate:endDate];

        } else {

            self.calendarView.selectedDateRange =
            [PBDateRange
             dateRangeWithStartDate:startDate
             endDate:startDate];
        }
    }
}

- (void)outOfBoundsCheck {

    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval delta = now - _lastOutOfBoundsUpdate;

    if (delta >= kPBCalendarSelectionOutOfBoundsUpdatePeriod) {

        CGPoint contentOffset = self.calendarView.contentOffset;
        CGFloat speed = 0.0f;
        CGFloat advancement = 0.0f;

        if (_lastPanningLocation.y < CGRectGetMinY(self.visibleRect) + kPBCalendarSelectionPanningOutOfBoundsThreshold) {

            speed =
            CGRectGetMinY(self.visibleRect) + kPBCalendarSelectionPanningOutOfBoundsThreshold - _lastPanningLocation.y;

            advancement = -kPBCalendarSelectionPanningOutOfBoundsAdvancement;

        } else if (_lastPanningLocation.y > CGRectGetMaxY(self.visibleRect) - kPBCalendarSelectionPanningOutOfBoundsThreshold){

            speed =
            _lastPanningLocation.y -
            CGRectGetMaxY(self.visibleRect) +
            kPBCalendarSelectionPanningOutOfBoundsThreshold;

            advancement = kPBCalendarSelectionPanningOutOfBoundsAdvancement;
        }

        contentOffset.y += speed * advancement;
        self.calendarView.contentOffset = contentOffset;

        _lastOutOfBoundsUpdate = now;
    }
}

- (void)handlePanEnded:(UIPanGestureRecognizer *)gesture {

    self.calendarView.scrollEnabled = YES;
    self.displayLink.paused = YES;

    if (self.draggingStartDate == nil && self.draggingEndDate == nil) return;

    CGPoint markerViewFinalPoint = [self endPointMarkingInCalendar];

    markerViewFinalPoint =
    [self.view
     convertPoint:markerViewFinalPoint
     fromView:self.calendarView];

    [self.endPointMarkerView setNeedsLayout];

    [UIView
     animateWithDuration:.3
     animations:^{

         self.endPointMarkerTopSpace.constant = markerViewFinalPoint.y;
         self.endPointMarkerLeadingSpace.constant = markerViewFinalPoint.x;
         self.endPointLabelLeadingSpace.constant = 0.0f;

         [self.endPointMarkerView layoutIfNeeded];

     } completion:^(BOOL finished) {

         self.endPointMarkerView.hidden = YES;

         if (self.draggingStartDate == nil && self.draggingEndDate == nil) {
             return;
         }

         self.calendarView.startPointHidden = NO;
         self.calendarView.endPointHidden = NO;
         [self.calendarView updateMonthViews:NO];

         if (_rangeMode &&
             self.modeSwitchOn &&
             [self.selectedDateRange.startDate isEqualToDate:self.selectedDateRange.endDate.midnight]) {
             [self toggleRangeMode];
         }
     }];
}

#pragma mark - UIGestureRecognizerDelegate Conformance

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [touch.view isDescendantOfView:self.toolbar] == NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return gestureRecognizer != self.tapGesture || otherGestureRecognizer != self.panGesture;
}

@end
