//
//  PBCalendarSelectionViewController.m
//  Calendar
//
//  Created by Nick Bolton on 1/19/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCalendarSelectionViewController.h"
#import "Bedrock.h"
#import "PBMonthView.h"
#import "NSCalendar+Bedrock.h"

static NSInteger const kPBCalendarSelectionViewControllerVisibleMonths = 5;
static CGFloat kPBCalendarSelectionViewControllerItemHeightPerWeek = 36.0f;
static CGFloat kPBCalendarSelectionViewControllerItemMonthLabelHeight = 38.5f;
static CGFloat kPBCalendarSelectionViewControllerNavigationBarHeight = 64.0f;
static CGFloat kPBCalendarSelectionViewControllerToolbarHeight = 40.0f;
static NSInteger const kPBCalendarSelectionViewControllerCalendarTag = 999;
static CGFloat const kPBCalendarSelectionViewEndPointRadius = 16.0f;
static CGFloat const kPBCalendarSelectionPanningOutOfBoundsAdvancement = 10.0f;
static CGFloat const kPBCalendarSelectionPanningOutOfBoundsThreshold = 22.0f;
static NSTimeInterval const kPBCalendarSelectionOutOfBoundsUpdatePeriod = .3f;

@interface PBCalendarSelectionViewController () <UIGestureRecognizerDelegate> {

    BOOL _rangeMode;
    CGPoint _lastPanningLocation;
    NSTimeInterval _lastOutOfBoundsUpdate;
}

@property (nonatomic, strong) PBDateRange *selectedDateRange;
@property (nonatomic, strong) NSDate *currentStartDate;
@property (nonatomic, strong) UIBarButtonItem *rangeToggleItem;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UINavigationBar *navbar;
@property (nonatomic, strong) NSDate *draggingStartDate;
@property (nonatomic, strong) NSDate *draggingEndDate;
@property (nonatomic, readwrite) BOOL modeSwitchOn;
@property (nonatomic) BOOL hideEndPointMarkers;
@property (nonatomic, strong) UIView *endPointMarkerView;
@property (nonatomic, strong) NSLayoutConstraint *endPointMarkerLeadingSpace;
@property (nonatomic, strong) NSLayoutConstraint *endPointMarkerTopSpace;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic) CGRect visibleRect;
@property (nonatomic) CADisplayLink *displayLink;

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

    viewController.calendarDelegate = delegate;

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

    viewController.calendarDelegate = delegate;

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

    UIBarButtonItem *spacer =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
     target:nil
     action:nil];

    UIBarButtonItem *currentMonthItem =
    [[UIBarButtonItem alloc]
     initWithTitle:PBLoc(@"Today")
     style:UIBarButtonItemStylePlain
     target:self
     action:@selector(jumpToCurrentMonth)];

    UIBarButtonItem *currentSelectionItem =
    [[UIBarButtonItem alloc]
     initWithTitle:PBLoc(@"Selection")
     style:UIBarButtonItemStylePlain
     target:self
     action:@selector(jumpToCurrentSelection)];

    NSMutableArray *items = [NSMutableArray array];

    if (self.modeSwitchOn) {
        [items addObject:self.rangeToggleItem];
    }

    [items addObject:spacer];
    [items addObject:currentMonthItem];
    [items addObject:currentSelectionItem];

    self.toolbar.items = items;
    [self updateToolbarItems];
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

- (void)setupEndPointMarkerView {

    self.endPointMarkerView = [[UIView alloc] init];
    self.endPointMarkerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.endPointMarkerView.alpha = .5f;

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
}

- (void)updateVisibleRect {
    self.visibleRect = [self buildVisibleRect];
}

- (CGRect)buildVisibleRect {

    CGFloat navigationBarHeight =
    CGRectGetHeight(self.navbar.bounds);

    CGFloat toolbarHeight =
    CGRectGetHeight(self.toolbar.bounds);

    return
    CGRectMake(0.0f,
               navigationBarHeight,
               CGRectGetWidth(self.view.frame),
               CGRectGetHeight(self.view.frame) - navigationBarHeight - toolbarHeight);
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

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDisplayLink];
    [self setupEndPointMarkerView];
    [self setupGestures];
    [self setupToolbar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateVisibleRect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Data Source

#pragma mark - Actions

- (void)cancelPressed:(id)sender {
    [self.calendarDelegate calendarSelectionViewControllerCancelled:self];
}

- (void)donePressed:(id)sender {
    [self.calendarDelegate calendarSelectionViewController:self didSelectedRange:self.selectedDateRange];
}

#pragma mark - Getters and Setters

- (void)setCurrentStartDate:(NSDate *)currentStartDate {

    NSDateComponents *dateComponents =
    [NSDateComponents
     components:NSCalendarUnitYear|NSCalendarUnitMonth
     fromDate:currentStartDate];

    _currentStartDate =
    [NSDate
     dateWithYear:dateComponents.year
     month:dateComponents.month
     day:1];
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

    NSDate *endDate =
    [self.selectedDateRange.startDate dateByAddingDays:6];

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

#warning IMPLEMENT enumerateMonthViews
// TODO: IMPLEMENT enumerateMonthViews
- (void)enumerateMonthViews:(void(^)(PBMonthView *monthView, NSInteger index, BOOL *stop))block {

    if (block == nil) return;
}

#warning IMPLEMENT updateVisibleCalendarSelection
// TODO: IMPLEMENT updateVisibleCalendarSelection
- (void)updateVisibleCalendarSelection {

    [self enumerateMonthViews:^(PBMonthView *monthView, NSInteger index, BOOL *stop) {
    }];
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

- (void)updateFloatingStartPointMarker:(CGPoint)point {

    CGPoint pointInMonthView = [self endPointMarkingInCalendar];

    if (pointInMonthView.y < MAXFLOAT) {
        
        self.endPointMarkerView.hidden = NO;

        self.endPointMarkerTopSpace.constant = pointInMonthView.y;

        self.endPointMarkerLeadingSpace.constant =
        point.x - kPBCalendarSelectionViewEndPointRadius;

        [self.endPointMarkerView layoutIfNeeded];
    }
}

- (void)updateFloatingEndPointMarker:(CGPoint)point {

    CGPoint pointInMonthView = [self endPointMarkingInCalendar];

    if (pointInMonthView.y < MAXFLOAT) {

        self.endPointMarkerView.hidden = NO;
        self.endPointMarkerTopSpace.constant = pointInMonthView.y;

        self.endPointMarkerLeadingSpace.constant =
        point.x - kPBCalendarSelectionViewEndPointRadius;

        [self.endPointMarkerView layoutIfNeeded];
    }
}

#warning IMPLEMENT endPointMarkingInCalendar
// TODO: IMPLEMENT endPointMarkingInCalendar
- (CGPoint)endPointMarkingInCalendar {

    __block CGPoint markerViewFinalPoint = CGPointZero;

    [self enumerateMonthViews:^(PBMonthView *monthView, NSInteger index, BOOL *stop) {

    }];

    return markerViewFinalPoint;
}

#pragma mark - Gestures

- (void)handleTap:(UITapGestureRecognizer *)gesture {

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

    NSDate *date = [self dateAtPoint:location];

    if (date != nil) {

        NSDateComponents *dateComponents =
        [NSDateComponents
         components:NSCalendarUnitWeekday
         fromDate:date];

        NSInteger distanceStartOfWeek = self.firstDayOfTheWeek - dateComponents.weekday;

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

        self.selectedDateRange =
        [PBDateRange
         dateRangeWithStartDate:startDate
         endDate:endDate];

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

            self.tableView.scrollEnabled = NO;
            self.displayLink.paused = NO;
            self.hideEndPointMarkers = YES;
            [self endPointMarkersHidden:YES];
        }
    }
}

- (void)endPointMarkersHidden:(BOOL)hidden {

    [self enumerateMonthViews:^(PBMonthView *monthView, NSInteger index, BOOL *stop) {

        if (self.draggingStartDate != nil) {
            monthView.hideStartingPointMarker = hidden;
        } else {
            monthView.hideEndingPointMarker = hidden;
        }
    }];
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

                [self endPointMarkersHidden:NO];
                self.draggingStartDate = nil;
                self.draggingEndDate = date;
                [self endPointMarkersHidden:YES];

                startDate = endDate;
                endDate = date;
            }

            [self updateFloatingStartPointMarker:_lastPanningLocation];

        } else {

            if ([date isGreaterThan:endDate] || [date isGreaterThanOrEqualTo:startDate]) {
                endDate = date;
                self.draggingEndDate = date;
            } else if ([date isLessThan:startDate]) {
                endDate = startDate;
                startDate = date;

                [self endPointMarkersHidden:NO];
                self.draggingEndDate = nil;
                self.draggingStartDate = date;
                [self endPointMarkersHidden:YES];
            }

            [self updateFloatingEndPointMarker:_lastPanningLocation];
        }

    } else {

        startDate = date;

        [self updateFloatingStartPointMarker:_lastPanningLocation];
    }

    if ([startDate isEqualToDate:self.selectedDateRange.startDate] == NO ||
        [endDate isEqualToDate:self.selectedDateRange.endDate.midnight] == NO) {

        if (_rangeMode) {

            self.selectedDateRange =
            [PBDateRange
             dateRangeWithStartDate:startDate
             endDate:endDate];

        } else {

            self.selectedDateRange =
            [PBDateRange
             dateRangeWithStartDate:startDate
             endDate:startDate];
        }

        [self enumerateMonthViews:^(PBMonthView *monthView, NSInteger index, BOOL *stop) {
            monthView.selectedDateRange = self.selectedDateRange;
        }];
    }
}

- (void)outOfBoundsCheck {

    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval delta = now - _lastOutOfBoundsUpdate;

    if (delta >= kPBCalendarSelectionOutOfBoundsUpdatePeriod) {

        CGPoint contentOffset = self.tableView.contentOffset;
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
        self.tableView.contentOffset = contentOffset;

        _lastOutOfBoundsUpdate = now;
    }
}

- (void)handlePanEnded:(UIPanGestureRecognizer *)gesture {

    self.tableView.scrollEnabled = YES;
    self.displayLink.paused = YES;
    self.hideEndPointMarkers = NO;

    CGPoint markerViewFinalPoint = [self endPointMarkingInCalendar];

    [self.endPointMarkerView setNeedsLayout];

    NSTimeInterval t = .15f;

    CGPoint velocity = [gesture velocityInView:gesture.view];
    CGFloat xPos = self.endPointMarkerLeadingSpace.constant + velocity.x * t / 4.0f;
    CGFloat yPos = self.endPointMarkerTopSpace.constant + velocity.y * t / 4.0f;

    [UIView
     animateWithDuration:t
     animations:^{

         self.endPointMarkerTopSpace.constant = yPos;
         self.endPointMarkerLeadingSpace.constant = xPos;

         [self.endPointMarkerView layoutIfNeeded];

     } completion:^(BOOL finished) {

         [self.endPointMarkerView setNeedsLayout];
         
         [UIView
          animateWithDuration:.15f
          delay:0.0f
          usingSpringWithDamping:.7f
          initialSpringVelocity:15.0f
          options:0
          animations:^{

              self.endPointMarkerTopSpace.constant = markerViewFinalPoint.y;
              self.endPointMarkerLeadingSpace.constant = markerViewFinalPoint.x + 4.0f;

              [self.endPointMarkerView layoutIfNeeded];

          } completion:^(BOOL finished) {

              self.endPointMarkerView.hidden = YES;

              if (self.draggingStartDate == nil && self.draggingEndDate == nil) {
                  return;
              }

              [self endPointMarkersHidden:NO];

              if (_rangeMode &&
                  self.modeSwitchOn &&
                  [self.selectedDateRange.startDate isEqualToDate:self.selectedDateRange.endDate.midnight]) {
                  [self toggleRangeMode];
              }
          }];
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
