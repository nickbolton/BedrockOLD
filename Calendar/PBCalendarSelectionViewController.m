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
#import "PBCalendarEndPointView.h"

typedef NS_ENUM(NSInteger, PBCalendarViewMonthIndicatorState) {

    PBCalendarViewMonthIndicatorStateHidden = 0,
    PBCalendarViewMonthIndicatorStateShowing,
    PBCalendarViewMonthIndicatorStateHiding,
    PBCalendarViewMonthIndicatorStateVisible,
};

static CGFloat const kPBCalendarSelectionViewControllerNavigationBarHeight = 64.0f;
static CGFloat const kPBCalendarSelectionViewControllerToolbarHeight = 44.0f;
static CGFloat const kPBCalendarSelectionViewCurrentMonthAlpha = .7f;
static CGFloat const kPBCalendarSelectionViewShowCurrentMonthScrollVelocityThreshold = 1.4f;
static CGFloat const kPBCalendarSelectionViewHideCurrentMonthScrollVelocityStartThreshold = 300.0f;
static CGFloat const kPBCalendarSelectionPanningOutOfBoundsAdvancement = 10.0f;
static CGFloat const kPBCalendarSelectionPanningOutOfBoundsThreshold = 22.0f;
static NSTimeInterval const kPBCalendarSelectionOutOfBoundsUpdatePeriod = .3f;
static NSInteger const kPBCalendarSelectionMaxAnimationRange = 365;

@interface PBCalendarSelectionViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate> {

    BOOL _rangeMode;
    NSTimeInterval _lastScrollTime;
    CGFloat _lastScrollPosition;
    CGFloat _autoScrollAmount;
    BOOL _autoScrolling;
    BOOL _decelerating;
    BOOL _isDragging;
    PBCalendarViewMonthIndicatorState _monthIndicatorState;
    NSTimeInterval _monthIndicatorStopTime;
    NSTimeInterval _lastMonthIndicatorTrigger;
    CGPoint _lastPanningLocation;
    NSTimeInterval _lastOutOfBoundsUpdate;
}

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIView *topToolbarView;
@property (nonatomic, strong) UIButton *presetsButton;
@property (nonatomic, strong) UINavigationBar *navbar;
@property (nonatomic, strong) PBCalendarView *calendarView;
@property (nonatomic, readwrite) BOOL modeSwitchOn;
@property (nonatomic, strong) UIBarButtonItem *rangeToggleItem;
@property (nonatomic, strong) UIBarButtonItem *jumpToItem;
@property (nonatomic, strong) UIBarButtonItem *presetsItem;
@property (nonatomic, readonly) PBDateRange *selectedDateRange;
@property (nonatomic, strong) PBDateRange *initialSelectedDateRange;
@property (nonatomic, strong) UIView *monthIndicatorContainer;
@property (nonatomic, strong) UIView *monthIndicatorBackgroundView;
@property (nonatomic, strong) UILabel *monthIndicatorLabel;
@property (nonatomic, strong) NSDate *currentMonth;
@property (nonatomic, strong) NSArray *visibleMonthViews;
@property (nonatomic) CGRect visibleRect;
@property (nonatomic, strong) PBRunningAverageValue *averageScrollSpeed;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic, strong) NSDate *draggingStartDate;
@property (nonatomic, strong) NSDate *draggingEndDate;
@property (nonatomic) CADisplayLink *displayLink;
@property (nonatomic, strong) PBCalendarEndPointView *endPointLoupe;
@property (nonatomic, strong) NSLayoutConstraint *endPointLoupeWidth;
@property (nonatomic, strong) NSLayoutConstraint *endPointLoupeHeight;
@property (nonatomic, strong) PBActionDelegate *actionDelegate;
@property (nonatomic, strong) NSArray *presetTimePeriods;

@end

@implementation PBCalendarSelectionViewController

- (id)initWithSelectedDate:(NSDate *)date
         presetTimePeriods:(NSArray *)presetTimePeriods
              modeSwitchOn:(BOOL)modeSwitchOn {

    self = [super init];
    if (self) {
        self.initialSelectedDateRange =
        [PBDateRange dateRangeWithStartDate:date endDate:date];
        self.modeSwitchOn = modeSwitchOn;
        self.presetTimePeriods = presetTimePeriods;
        self.averageScrollSpeed = [[PBRunningAverageValue alloc] init];
        [self initializeTheme];
    }
    return self;
}

- (id)initWithSelectedDateRange:(PBDateRange *)dateRange
              presetTimePeriods:(NSArray *)presetTimePeriods
                   modeSwitchOn:(BOOL)modeSwitchOn {

    self = [super init];
    if (self) {
        self.initialSelectedDateRange = dateRange;
        self.modeSwitchOn = modeSwitchOn;
        self.presetTimePeriods = presetTimePeriods;

        _rangeMode =
        [dateRange.endDate.midnight isGreaterThan:dateRange.startDate];
        self.averageScrollSpeed = [[PBRunningAverageValue alloc] init];
        [self initializeTheme];
    }
    return self;
}

#pragma mark - Setup

- (void)initializeTheme {
    self.barTintColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setupNavigationBar {

    UINavigationItem *navigationItem;
    UINavigationBar *navigationBar;

    if (self.navigationController == nil) {

        self.navbar = [[UINavigationBar alloc] init];
        self.navbar.translatesAutoresizingMaskIntoConstraints = NO;
        self.navbar.translucent = YES;

        navigationBar = self.navbar;
        
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
        navigationBar = self.navigationController.navigationBar;
    }
    
    navigationBar.barTintColor = self.barTintColor;
    navigationBar.barStyle = self.barStyle;

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
    self.toolbar.barTintColor = self.barTintColor;
    self.toolbar.barStyle = self.barStyle;

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

    self.jumpToItem =
    [[UIBarButtonItem alloc]
     initWithTitle:PBLoc(@"Jump To…")
     style:UIBarButtonItemStylePlain
     target:self
     action:@selector(jumpToPressed:)];

    NSMutableArray *items = [NSMutableArray array];

    if (self.modeSwitchOn) {
        [items addObject:self.rangeToggleItem];
    }
    
    [items addObject:flexSpacer];
    [items addObject:self.jumpToItem];

    self.toolbar.items = items;
    
    if (self.presetTimePeriods.count > 0) {
        [self setupTopToolbarView];
    }
    
    [self updateToolbarItems];
}

- (void)setupTopToolbarView {
 
    self.topToolbarView = [[UIView alloc] init];
    self.topToolbarView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.topToolbarView];
    
    [NSLayoutConstraint
     addHeightConstraint:kPBCalendarSelectionViewControllerToolbarHeight
     toView:self.topToolbarView];
    
    [NSLayoutConstraint horizontallyCenterView:self.topToolbarView];
    [NSLayoutConstraint addWidthConstraint:90.0f toView:self.topToolbarView];
    
    [NSLayoutConstraint alignToBottom:self.topToolbarView withPadding:0.0f];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.topToolbarView addSubview:button];
    
    button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    
    [button
     setTitle:PBLoc(@"Presets")
     forState:UIControlStateNormal];

    [button
     addTarget:self
     action:@selector(presetsPressed:)
     forControlEvents:UIControlEventTouchDown];
    
    [button
     setTitleColor:self.tintColor
     forState:UIControlStateNormal];
    
    [button
     setTitleColor:[self.tintColor colorWithAlpha:.3f]
     forState:UIControlStateHighlighted];
    
    [NSLayoutConstraint
     expandToSuperview:button
     withInsets:UIEdgeInsetsMake(1.0f, 0.0f, 0.0f, 0.0f)];
    
    self.presetsButton = button;
}

- (void)setupCalendarView {
	
    self.calendarView =
    [[PBCalendarView alloc]
     initWithFrame:self.view.bounds
     selectedDateRange:self.initialSelectedDateRange];
    
    self.calendarView.delegate = self;
	self.calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.calendarView.backgroundColor = self.backgroundColor;
    self.calendarView.textColor = self.textColor;
    self.calendarView.separatorColor = self.separatorColor;

	[self.view addSubview:_calendarView];

    self.calendarView.selectedDateRange = self.initialSelectedDateRange;
}

- (void)setupMonthIndicatorLabel {

    self.monthIndicatorContainer = [[UIView alloc] init];
    self.monthIndicatorContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.monthIndicatorContainer.alpha = 0.0f;
    _monthIndicatorState = PBCalendarViewMonthIndicatorStateHidden;

    [self.view addSubview:self.monthIndicatorContainer];

    CGFloat statusBarHeight =
    CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);

    [NSLayoutConstraint
     alignToTop:self.monthIndicatorContainer
     withPadding:0.0f];

    [NSLayoutConstraint expandWidthToSuperview:self.monthIndicatorContainer];
    [NSLayoutConstraint
     addHeightConstraint:kPBCalendarSelectionViewControllerNavigationBarHeight
     toView:self.monthIndicatorContainer];

    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    backgroundView.backgroundColor = self.tintColor;
    backgroundView.alpha = kPBCalendarSelectionViewCurrentMonthAlpha;
    
    self.monthIndicatorBackgroundView = backgroundView;

    [self.monthIndicatorContainer addSubview:backgroundView];
    [NSLayoutConstraint expandToSuperview:backgroundView];

    self.monthIndicatorLabel = [[UILabel alloc] init];
    self.monthIndicatorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.monthIndicatorLabel.textColor = self.monthIndicatorTextColor;
    self.monthIndicatorLabel.textAlignment = NSTextAlignmentCenter;
    self.monthIndicatorLabel.font =
    [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];

    [self.monthIndicatorContainer addSubview:self.monthIndicatorLabel];
    [NSLayoutConstraint expandWidthToSuperview:self.monthIndicatorLabel];
    [NSLayoutConstraint alignToTop:self.monthIndicatorLabel withPadding:statusBarHeight];
    [NSLayoutConstraint alignToBottom:self.monthIndicatorLabel withPadding:0.0f];
}

- (void)setupGestures {

    self.tapGesture =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(handleTap:)];

    self.tapGesture.delegate = self;

    [self.view addGestureRecognizer:self.tapGesture];
    
    self.longPressGesture =
    [[UILongPressGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(handleLongPress:)];

    self.longPressGesture.delegate = self;

    [self.view addGestureRecognizer:self.longPressGesture];

    [self.tapGesture requireGestureRecognizerToFail:self.longPressGesture];
    [self.calendarView.panGestureRecognizer requireGestureRecognizerToFail:self.longPressGesture];
    
    if (self.modeSwitchOn) {
        
        self.doubleTapGesture =
        [[UITapGestureRecognizer alloc]
         initWithTarget:self
         action:@selector(handleDoubleTap:)];
        
        self.doubleTapGesture.numberOfTapsRequired = 2;
        self.doubleTapGesture.delegate = self;
        
        [self.view addGestureRecognizer:self.doubleTapGesture];
    }
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

- (void)setupEndPointLoupe {

    self.endPointLoupe = [[PBCalendarEndPointView alloc] initLarge];
    self.endPointLoupe.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view.window addSubview:self.endPointLoupe];

    CGFloat diameter = self.endPointLoupe.radius * 2.0f;

    self.endPointLoupeWidth =
    [NSLayoutConstraint addWidthConstraint:diameter toView:self.endPointLoupe];
    
    self.endPointLoupeHeight =
    [NSLayoutConstraint addHeightConstraint:diameter toView:self.endPointLoupe];

    self.endPointLoupe.topSpace =
    [NSLayoutConstraint alignToTop:self.endPointLoupe withPadding:0.0f];

    self.endPointLoupe.leadingSpace =
    [NSLayoutConstraint alignToLeft:self.endPointLoupe withPadding:0.0f];

    self.endPointLoupe.backgroundColor = [self.tintColor colorWithAlpha:.7f];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.tintColor = self.tintColor;
    [self setupDisplayLink];
	[self setupCalendarView];
    [self setupGestures];
    [self setupMonthIndicatorLabel];
    [self setupNavigationBar];
    [self setupToolbar];

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Getters and Setters

- (PBDateRange *)selectedDateRange {
    return self.calendarView.selectedDateRange;
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    _barTintColor = barTintColor;
    self.navbar.barTintColor = barTintColor;
    self.toolbar.barTintColor = barTintColor;
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
//    self.view.tintColor = tintColor;
    self.monthIndicatorBackgroundView.backgroundColor = tintColor;
    self.endPointLoupe.backgroundColor = tintColor;
    
    [self.presetsButton
     setTitleColor:tintColor
     forState:UIControlStateNormal];
    
    [self.presetsButton
     setTitleColor:[self.tintColor colorWithAlpha:.5f]
     forState:UIControlStateHighlighted];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.monthIndicatorLabel.textColor = textColor;
    self.calendarView.textColor = textColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.calendarView.backgroundColor = backgroundColor;
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    self.calendarView.separatorColor = separatorColor;
}

- (void)setBarStyle:(UIBarStyle)barStyle {
    _barStyle = barStyle;
    self.navbar.barStyle = barStyle;
    self.toolbar.barStyle = barStyle;
}

#pragma mark - Actions

- (void)cancelPressed:(id)sender {
    [self.delegate calendarSelectionViewControllerCancelled:self];
}

- (void)donePressed:(id)sender {
    [self.delegate calendarSelectionViewController:self didSelectedRange:self.selectedDateRange];
}

- (void)jumpToPressed:(id)sender {

    __weak typeof(self) this = self;
    
    NSInteger buttonIndex = 0;
    
    self.actionDelegate = [[PBActionDelegate alloc] init];
    NSMutableArray *buttonTitles = [NSMutableArray array];
    
    [buttonTitles addObject:PBLoc(@"Today")];
    
    [self.actionDelegate
     addBlock:^(id userContext) {
         [this showToday:nil];
     }
     userContext:nil
     toButton:buttonIndex++];
    
    NSInteger daysInRange =
    [self.selectedDateRange.startDate
     daysInBetweenDate:self.selectedDateRange.endDate];
    
    if (daysInRange <= 60) {
        
        if (_rangeMode) {
            
            [buttonTitles addObject:PBLoc(@"Selected Range")];

        } else {
            
            [buttonTitles addObject:PBLoc(@"Selected Day")];
        }
        
        [self.actionDelegate
         addBlock:^(id userContext) {

             NSInteger distance =
             [this.currentMonth
              daysInBetweenDate:this.selectedDateRange.startDate];
             
             if (ABS(distance) <= kPBCalendarSelectionMaxAnimationRange) {
                 
                 [this.calendarView
                  scrollToMonth:this.selectedDateRange.startDate
                  animated:YES];
                 
             } else {
                 
                 [this.calendarView reloadWithCurrentMonth:this.selectedDateRange.startDate];
             }
         }
         userContext:nil
         toButton:buttonIndex++];
        
    } else {
        
        [buttonTitles addObject:PBLoc(@"Start of Selection")];
        
        [self.actionDelegate
         addBlock:^(id userContext) {
             
             NSInteger distance =
             [this.currentMonth
              daysInBetweenDate:this.selectedDateRange.startDate];

             if (ABS(distance) <= kPBCalendarSelectionMaxAnimationRange) {
                 
                 [this.calendarView
                  scrollToMonth:this.selectedDateRange.startDate
                  animated:YES];
                 
             } else {
                 
                 [this.calendarView reloadWithCurrentMonth:this.selectedDateRange.startDate];
             }
         }
         userContext:nil
         toButton:buttonIndex++];

        [buttonTitles addObject:PBLoc(@"End of Selection")];
        
        [self.actionDelegate
         addBlock:^(id userContext) {
             
             NSInteger distance =
             [this.currentMonth
              daysInBetweenDate:this.selectedDateRange.endDate];
             
             if (ABS(distance) <= kPBCalendarSelectionMaxAnimationRange) {
                 
                 [this.calendarView
                  scrollToMonth:this.selectedDateRange.endDate
                  animated:YES];
                 
             } else {
                 
                 [this.calendarView reloadWithCurrentMonth:this.selectedDateRange.endDate];
             }
         }
         userContext:nil
         toButton:buttonIndex++];
    }
    
    [self.delegate
     calendarSelectionViewControllerPresentJumpToActionSheet:self
     title:PBLoc(@"Jump To…")
     buttonTitles:buttonTitles
     actionDelegate:self.actionDelegate];
}

- (void)presetsPressed:(id)sender {
    
    __weak typeof(self) this = self;
    
    NSInteger buttonIndex = 0;
    
    self.actionDelegate = [[PBActionDelegate alloc] init];
    NSMutableArray *timePeriods = [NSMutableArray array];

    for (NSNumber *timePeriodNumber in self.presetTimePeriods) {
        
        NSAssert([timePeriodNumber isKindOfClass:[NSNumber class]],
                 @"presetTimePeriods value is not an NSNumber");
        
        TimePeriod timePeriod = timePeriodNumber.integerValue;
        
        if (timePeriod >= TimePeriod_All &&
            timePeriod <= TimePeriod_PreviousYear) {
            
            if (timePeriod != TimePeriod_Today &&
                timePeriod != TimePeriod_Yesterday) {
                
                [timePeriods addObject:timePeriodNumber];
                
                [self.actionDelegate
                 addBlock:^(id userContext) {
                     [this selectPreset:timePeriod];
                 }
                 userContext:nil
                 toButton:buttonIndex++];
                
            } else {
                
                PBLog(@"Warning : Skipping single day time periods in presents");
            }
            
        } else {
            
            PBLog(@"Warning : timePeriod (%@) is out of TimePeriod enum range",
                  timePeriodNumber);
        }
    }
    
    if (timePeriods.count > 0) {
        
        [self.delegate
         calendarSelectionViewControllerPresentPresetSelectionModal:self
         title:PBLoc(@"Presets")
         timePeriods:timePeriods
         actionBlock:^(NSNumber *timePeriodNumber) {
             
             TimePeriod timePeriod = timePeriodNumber.integerValue;
             
             if (timePeriod >= TimePeriod_All &&
                 timePeriod <= TimePeriod_PreviousYear) {
                 
                 if (timePeriod != TimePeriod_Today &&
                     timePeriod != TimePeriod_Yesterday) {
                     
                     [this selectPreset:timePeriod];
                 }
             }
         }];
        
    } else {
        
        PBLog(@"Warning : no time period presets to present");
    }
}

- (void)showToday:(id)sender {
    
    NSDate *today = [NSDate date];
    
    NSInteger distance =
    [self.currentMonth
     daysInBetweenDate:today];
    
    if (ABS(distance) <= kPBCalendarSelectionMaxAnimationRange) {
        
        [self.calendarView
         scrollToMonth:today
         animated:YES];
        
    } else {
        
        [self.calendarView reloadWithCurrentMonth:today];
    }

	[self.calendarView
     scrollToMonth:today
     animated:ABS(distance) <= kPBCalendarSelectionMaxAnimationRange];
    
    [self doUpdateCurrentMonth:today];
}

- (void)selectPreset:(TimePeriod)timePeriod {
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
         self.navigationController.navigationBar.alpha = 0.0f;
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
         self.navigationController.navigationBar.alpha = 1.0f;
     } completion:^(BOOL finished) {
         _monthIndicatorState = PBCalendarViewMonthIndicatorStateHidden;
     }];
}

- (void)ensureMonthIndicatorHides {

    if ([self willMonthIndicatorBeVisible] && _autoScrolling == NO) {

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
     completelyVisible:NO];

    BOOL visibleMonthsChanged =
    [visibleMonthViews isEqualToArray:self.visibleMonthViews] == NO;

    self.visibleMonthViews = visibleMonthViews;

    NSDate *currentMonth = [self.calendarView currentMonth];

    [self doUpdateCurrentMonth:currentMonth];

    if (visibleMonthsChanged) {
        [self updateToolbarItems];
    }
}

- (void)doUpdateCurrentMonth:(NSDate *)date {
    
    NSDateComponents *monthComponents =
    [date components:NSCalendarUnitYear|NSCalendarUnitMonth];
    monthComponents.day = 1;
    
	NSDate *currentMonth =
    [NSDate
     dateWithYear:monthComponents.year
     month:monthComponents.month
     day:1];

    if (date != nil && [currentMonth isEqualToDate:self.currentMonth] == NO) {
        
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

- (NSDate *)startOrEndPointAtPoint:(CGPoint)point {
    
    point = [self.calendarView convertPoint:point fromView:self.view];
    return [self.calendarView startOrEndPointAtPoint:point];
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

- (void)updateFloatingStartPointMarker:(CGPoint)point forDate:(NSDate *)date {

    CGPoint pointInCalendarView = [self endPointMarkingInCalendar];

    if (pointInCalendarView.y < MAXFLOAT) {

        CGPoint pointInView =
        [self.view convertPoint:pointInCalendarView fromView:self.calendarView];

        self.endPointLoupe.hidden = NO;
        
        self.endPointLoupe.topSpace.constant =
        point.y - (3.0f * self.endPointLoupe.radius);

        self.endPointLoupe.leadingSpace.constant =
        point.x - self.endPointLoupe.radius;
        
        self.endPointLoupe.leadingSpace.constant =
        MAX(0.0f, self.endPointLoupe.leadingSpace.constant);
        
        self.endPointLoupe.leadingSpace.constant =
        MIN(CGRectGetMaxX(self.view.frame) - CGRectGetWidth(self.endPointLoupe.frame),
            self.endPointLoupe.leadingSpace.constant);

        [self.endPointLoupe updateEndPointLabel:date];

        [self.endPointLoupe layoutIfNeeded];
    }
}

- (void)updateFloatingEndPointMarker:(CGPoint)point forDate:(NSDate *)date {

    CGPoint pointInCalendarView = [self endPointMarkingInCalendar];

    if (pointInCalendarView.y < MAXFLOAT) {

        CGPoint pointInView =
        [self.view convertPoint:pointInCalendarView fromView:self.calendarView];

        self.endPointLoupe.hidden = NO;

        self.endPointLoupe.topSpace.constant =
        point.y - (3.0f * self.endPointLoupe.radius);

        self.endPointLoupe.leadingSpace.constant =
        point.x - self.endPointLoupe.radius;

        self.endPointLoupe.leadingSpace.constant =
        MAX(0.0f, self.endPointLoupe.leadingSpace.constant);
        
        self.endPointLoupe.leadingSpace.constant =
        MIN(CGRectGetMaxX(self.view.frame) - CGRectGetWidth(self.endPointLoupe.frame),
            self.endPointLoupe.leadingSpace.constant);

        [self.endPointLoupe updateEndPointLabel:date];

        [self.endPointLoupe layoutIfNeeded];
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
    [self hideMonthIndicatorContainer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateCurrentMonth];
    });
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

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
 
    if (self.draggingStartDate != nil || self.draggingEndDate != nil || _isDragging) {
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        if (_rangeMode == NO) {
            [self toggleRangeMode];
        }
        
        [self handleRangeModeTap:gesture];
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

- (void)handleLongPress:(UIPanGestureRecognizer *)gesture {
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
    _autoScrollAmount = 0.0f;
    
    if ([self pointInNavbarOrToolbar:_lastPanningLocation] == NO) {

        NSDate *date = [self startOrEndPointAtPoint:_lastPanningLocation];

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

            [self setupEndPointLoupe];

            self.endPointLoupe.transform = CGAffineTransformMakeScale(.5f, .5f);

            CGPoint markerViewStartPoint = [self endPointMarkingInCalendar];
            
            markerViewStartPoint =
            [self.view
             convertPoint:markerViewStartPoint
             fromView:self.calendarView];
            
            self.endPointLoupe.topSpace.constant = markerViewStartPoint.y;
            self.endPointLoupe.leadingSpace.constant = markerViewStartPoint.x;
            self.endPointLoupe.labelLeadingSpace.constant = 0.0f;
            self.endPointLoupe.alpha = 0.0f;
            
            [self.endPointLoupe layoutIfNeeded];
                        
            NSDate *date = [self nearestDateAtPoint:_lastPanningLocation];
            
            [self.endPointLoupe setNeedsLayout];
            
            
            [UIView
             animateWithDuration:.3f
             animations:^{
                 
                 [self updateFloatingEndPointMarker:_lastPanningLocation forDate:date];
                 self.endPointLoupe.transform = CGAffineTransformIdentity;
                 self.endPointLoupe.alpha = 1.0f;
                 
             } completion:^(BOOL finished) {
             }];

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
        gesture.enabled = NO;
        gesture.enabled = YES;
        return;
    }
    
    if (gesture != nil) {
        _lastPanningLocation = [gesture locationInView:self.view];
    }
    
    if (_autoScrolling) {
        return;
    }
    
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
        
        [self updateToolbarItems];
    }
}

- (void)outOfBoundsCheck {

    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval delta = now - _lastOutOfBoundsUpdate;

    static CGFloat const speedFactor = 100.0f;
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
    
    speed /= speedFactor;
        
    CGFloat scrollAmount = speed * advancement;
    
    contentOffset.y += scrollAmount;
    self.calendarView.contentOffset = contentOffset;
    
    _lastPanningLocation.y += scrollAmount;
    _lastOutOfBoundsUpdate = now;
    _autoScrolling = speed != 0.0f;
    
    if (speed > 0.0f) {
        
        self.endPointLoupe.hidden = YES;

        if (_autoScrollAmount == 0.0f) {
            [self showMonthIndicatorContainer];
            self.calendarView.withinRangeBackgroundHidden = YES;
            [self.calendarView updateMonthViews:YES];
        }
        
        _autoScrollAmount += scrollAmount;
        
    } else if (_autoScrollAmount != 0.0f) {
        
        [self hideMonthIndicatorContainer];
        self.endPointLoupe.hidden = NO;
        self.calendarView.withinRangeBackgroundHidden = NO;
        [self handlePanChanged:nil];
        
        _autoScrollAmount = 0.0f;
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

    [self.endPointLoupe setNeedsLayout];

    if (self.draggingStartDate != nil || self.draggingEndDate != nil) {
            
        if (_rangeMode &&
            self.modeSwitchOn &&
            [self.selectedDateRange.startDate isEqualToDate:self.selectedDateRange.endDate.midnight]) {
            [self toggleRangeMode];
        }
    }

    [UIView
     animateWithDuration:.3
     animations:^{
         
         CGAffineTransform transform = CGAffineTransformMakeScale(.5f, .5f);
         
         self.endPointLoupe.transform = transform;
         
         self.endPointLoupe.topSpace.constant = markerViewFinalPoint.y;
         self.endPointLoupe.leadingSpace.constant = markerViewFinalPoint.x;
         self.endPointLoupe.labelLeadingSpace.constant = 0.0f;

         [self.endPointLoupe layoutIfNeeded];
         
         if (self.draggingStartDate != nil || self.draggingEndDate != nil) {
             
             self.calendarView.startPointHidden = NO;
             self.calendarView.endPointHidden = NO;
             [self.calendarView updateMonthViews:NO];
         }

     } completion:^(BOOL finished) {
         
         [self.endPointLoupe removeFromSuperview];
         self.endPointLoupe = nil;
         
         self.draggingStartDate = nil;
         self.draggingEndDate = nil;
     }];
}

#pragma mark - UIGestureRecognizerDelegate Conformance

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [touch.view isDescendantOfView:self.toolbar] == NO;
}

@end
