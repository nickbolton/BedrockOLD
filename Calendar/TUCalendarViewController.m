//
//  TUCalendarViewController.m
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TUCalendarViewController.h"
#import "PBCalendarView.h"

static CGFloat const kPBCalendarSelectionViewControllerNavigationBarHeight = 64.0f;
static CGFloat const kPBCalendarSelectionViewControllerToolbarHeight = 40.0f;
static CGFloat const kPBCalendarSelectionViewCurrentMonthAlpha = .7f;
static CGFloat const kPBCalendarSelectionViewShowCurrentMonthScrollVelocityThreshold = 2000.0f;
static CGFloat const kPBCalendarSelectionViewHideCurrentMonthScrollVelocityStartThreshold = 300.0f;

@interface TUCalendarViewController () <UIScrollViewDelegate> {

    BOOL _rangeMode;
    NSTimeInterval _lastScrollTime;
    CGFloat _lastScrollPosition;
    BOOL _decelerating;
}

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UINavigationBar *navbar;
@property (nonatomic, strong) PBCalendarView *calendarView;
@property (nonatomic, readwrite) BOOL modeSwitchOn;
@property (nonatomic, strong) UIBarButtonItem *rangeToggleItem;
@property (nonatomic, readonly) PBDateRange *selectedDateRange;
@property (nonatomic, strong) PBDateRange *initialSelectedDateRange;
@property (nonatomic, strong) UIView *currentMonthContainer;
@property (nonatomic, strong) UILabel *currentMonthLabel;
@property (nonatomic, strong) NSDate *currentMonth;

@end

@implementation TUCalendarViewController

- (id)initWithSelectedDate:(NSDate *)date
              modeSwitchOn:(BOOL)modeSwitchOn {

    self = [super init];
    if (self) {
        self.initialSelectedDateRange =
        [PBDateRange dateRangeWithStartDate:date endDate:date];
        self.modeSwitchOn = modeSwitchOn;
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
     action:@selector(showToday:)];

    UIBarButtonItem *currentSelectionItem =
    [[UIBarButtonItem alloc]
     initWithTitle:PBLoc(@"Selection")
     style:UIBarButtonItemStylePlain
     target:self
     action:@selector(showCurrentSelection:)];

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

- (void)setupCalendarView {
	self.calendarView = [[PBCalendarView alloc] initWithFrame:self.view.bounds];
    self.calendarView.delegate = self;
	self.calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_calendarView];

    NSDateComponents *components =
    [self.initialSelectedDateRange.startDate
     components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay];

    self.calendarView.selectedDay = components;
}

- (void)setupCurrentMonthLabel {

    self.currentMonthContainer = [[UIView alloc] init];
    self.currentMonthContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.currentMonthContainer.alpha = 0.0f;

    [self.view addSubview:self.currentMonthContainer];

    [NSLayoutConstraint
     alignToTop:self.currentMonthContainer
     withPadding:kPBCalendarSelectionViewControllerNavigationBarHeight];

    [NSLayoutConstraint expandWidthToSuperview:self.currentMonthContainer];
    [NSLayoutConstraint
     addHeightConstraint:40.0f
     toView:self.currentMonthContainer];

    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    backgroundView.backgroundColor = self.view.tintColor;
    backgroundView.alpha = kPBCalendarSelectionViewCurrentMonthAlpha;

    [self.currentMonthContainer addSubview:backgroundView];
    [NSLayoutConstraint expandToSuperview:backgroundView];

    self.currentMonthLabel = [[UILabel alloc] init];
    self.currentMonthLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.currentMonthLabel.textColor = [UIColor blackColor];
    self.currentMonthLabel.textAlignment = NSTextAlignmentCenter;
    self.currentMonthLabel.font =
    [UIFont fontWithName:@"HelveticaNeue" size:16.0f];

    [self.currentMonthContainer addSubview:self.currentMonthLabel];
    [NSLayoutConstraint expandToSuperview:self.currentMonthLabel];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupCalendarView];
    [self setupNavigationBar];
    [self setupToolbar];
    [self setupCurrentMonthLabel];    
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

    NSDate *startDate =
    [[NSCalendar calendarForCurrentThread]
     dateFromComponents:self.calendarView.selectedDay];

    NSDate *endDate =
    [[NSCalendar calendarForCurrentThread]
     dateFromComponents:self.calendarView.selectedDay];

    PBDateRange *dateRange =
    [PBDateRange
     dateRangeWithStartDate:startDate
     endDate:endDate];

    return dateRange;
}

#pragma mark - Actions

- (void)cancelPressed:(id)sender {
    [self.calendarDelegate calendarSelectionViewControllerCancelled:self];
}

- (void)donePressed:(id)sender {
    [self.calendarDelegate calendarSelectionViewController:self didSelectedRange:self.selectedDateRange];
}

- (void)showToday:(id)sender {
	[self.calendarView scrollToMonth:[NSDate date] animated:YES];
}

- (void)showCurrentSelection:(id)sender {
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

- (void)showCurrentMonthContainer {

    self.currentMonthContainer.alpha = 0.0f;

    [UIView
     animateWithDuration:.3f
     animations:^{
         self.currentMonthContainer.alpha = 1.0f;
     }];
}

- (void)hideCurrentMonthContainer {

    [UIView
     animateWithDuration:.3f
     animations:^{
         self.currentMonthContainer.alpha = 0.0f;
     }];
}

- (void)updateCurrentMonthLabel {

    if (self.currentMonthContainer.alpha > 0.0f) {

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
            
            self.currentMonthLabel.text = [dateFormatter stringFromDate:currentMonth];

            self.currentMonth = currentMonth;
        }
    }
}

#pragma mark - UIScrollViewDelegate Conformance

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

    _decelerating = decelerate;

    if (decelerate) {
        self.currentMonth = nil;
        _lastScrollPosition = scrollView.contentOffset.y;
        _lastScrollTime = [NSDate timeIntervalSinceReferenceDate];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (_decelerating) {

        CGFloat scrollPosition = scrollView.contentOffset.y;
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];

        NSTimeInterval deltaT = now - _lastScrollTime;
        CGFloat deltaY = scrollPosition - _lastScrollPosition;
        CGFloat speed = ABS(deltaY / deltaT);

//        NSLog(@"speed: %f", speed);

        if (self.currentMonthContainer.alpha == 0.0f) {
            if (speed > kPBCalendarSelectionViewShowCurrentMonthScrollVelocityThreshold) {
                [self updateCurrentMonthLabel];
                [self showCurrentMonthContainer];
            }
        } else {
            if (speed < kPBCalendarSelectionViewHideCurrentMonthScrollVelocityStartThreshold) {
                [self hideCurrentMonthContainer];
                _decelerating = NO;
            }
        }

        [self updateCurrentMonthLabel];

        _lastScrollPosition = scrollPosition;
        _lastScrollTime = now;
    }
}

@end
