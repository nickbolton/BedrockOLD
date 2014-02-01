//
//  PBCalendarDayViewController.m
//  Sometime
//
//  Created by Nick Bolton on 1/2/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCalendarDayViewController.h"
#import "PBCalendarLayout.h"
#import "PBCalendarItem.h"
#import "PBCalendarEntryCell.h"
#import "PBCalendarHourDecorationCell.h"
#import "PBCollectionView.h"
#import "NSString+Utilities.h"

typedef NS_ENUM(NSInteger, PBCalendarSection) {

    PBCalendarSectionTimers = 0,
    PBCalendarSectionDecorations,
};

@interface PBCalendarDayViewController () <UIGestureRecognizerDelegate> {

    CGFloat _startingPinchScale;
    CGFloat _startingPinchContentOffset;
    CGFloat _startingPinchLocationInContainer;
    CGFloat _startingPinchLocation;
    CGFloat _centeredPinchLocationPercent;
    CGFloat _startingPinchHeight;
    CGFloat _pinchTranslationVelocity;
    NSTimeInterval _pinchLastTimestamp;
    CGFloat _pinchLastTranslationPosition;
}

@property (nonatomic, copy) void (^scrollToTopCompletionBlock)(void);

@end

@implementation PBCalendarDayViewController

+ (Class)collectionViewLayoutClass {
    return [PBCalendarLayout class];
}

- (id)init {
    self = [super initWithNib];

    if (self != nil) {
    }

    return self;
}

#pragma mark - Setup

- (void)setupGestures {

//    UITapGestureRecognizer *doubleTapGesture =
//    [[UITapGestureRecognizer alloc]
//     initWithTarget:self
//     action:@selector(handleDoubleTap:)];
//    doubleTapGesture.numberOfTouchesRequired = 2;
//    doubleTapGesture.numberOfTapsRequired = 2;
//
//    [self.view addGestureRecognizer:doubleTapGesture];

    UIPinchGestureRecognizer *pinchGesture =
    [[UIPinchGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(handlePinch:)];

    pinchGesture.delegate = self;

    [self.view addGestureRecognizer:pinchGesture];
}

- (void)setupCollectionView {
    [super setupCollectionView];

    self.collectionLayout.debugging = NO;
    self.view.backgroundColor = [UIColor colorWithRGBHex:0xF3F3F3];

    self.collectionView.contentInset =
    UIEdgeInsetsMake(20.0f,
                     0.0f,
                     0.0f,
                     0.0f);

    self.timelineLayout.visibleViewHeight =
    CGRectGetHeight(self.view.frame) - 20.0f;
    self.timelineLayout.scale = 1.0f;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    self.reloadDataOnViewLoad = NO;
    [super viewDidLoad];
    [self setupGestures];
    [self setupCollectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Getters and Setters

- (void)setPinching:(BOOL)pinching {
    _pinching = pinching;
    [self updateVisibleHourCells];
}

#pragma mark - Public

- (void)updateContentOffset:(CGPoint)contentOffset {

    if (self.isPinching) {
        [(PBCollectionView *)self.collectionView setPinchingContentOffset:contentOffset];
    } else {
        self.collectionView.contentOffset = contentOffset;
    }
}

- (void)updateScale:(CGFloat)scale animate:(BOOL)animate {

    scale = MIN(1.0f, scale);
    scale = MAX(0.0f, scale);

    if (animate) {

        CGFloat damping = .7f;
        CGFloat springVelocity = 15.0f;

        if (scale == 0.0f) {
            damping = 1.0f;
            springVelocity = 0.0f;
        }

        [UIView
         animateWithDuration:1.0f
         delay:0.0f
         usingSpringWithDamping:damping
         initialSpringVelocity:springVelocity
         options:0
         animations:^{

             [self.collectionView
              performBatchUpdates:^{
                  self.timelineLayout.scale = scale;
              } completion:nil];

             [self updateVisibleHourCells];

         } completion:nil];

    } else {

        self.timelineLayout.scale = scale;
        [self.timelineLayout invalidateLayout];
        [self updateVisibleHourCells];
    }
}

#pragma mark - Data Source

- (NSArray *)buildDataSource {

    NSMutableArray *items = [NSMutableArray array];

    [items addObject:[self buildTimerSection]];
    [items addObject:[self buildDecorationSection]];

    return items;
}

- (PBCalendarItem *)buildTimerItemHour:(NSInteger)hour {

    NSCalendar *calendar =
    [[PBCalendarManager sharedInstance] calendarForCurrentThread];

    NSDateComponents *dayDateComponents =
    [calendar
     components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
     fromDate:self.dayDate];

    NSDate *startTime =
    [NSDate
     dateWithYear:dayDateComponents.year
     month:dayDateComponents.month
     day:dayDateComponents.day
     hours:hour
     minutes:0];

    NSDate *endTime =
    [NSDate
     dateWithYear:dayDateComponents.year
     month:dayDateComponents.month
     day:dayDateComponents.day
     hours:hour+1
     minutes:0];

    PBCalendarItem *item =
    [PBCalendarItem
     itemWithStartTime:startTime
     endTime:endTime
     configure:^(PBCollectionViewController *viewController, PBCollectionItem *item, PBCalendarEntryCell *cell) {

         cell.layer.cornerRadius = 2.0f;

     } binding:^(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, PBCalendarEntryCell *cell) {

         PBCalendarItem *timelineItem = (id)item;
         cell.timerContainer.backgroundColor = timelineItem.backgroundColor;

         NSTimeInterval elapsedTime =
         timelineItem.endTime.timeIntervalSinceReferenceDate -
         timelineItem.startTime.timeIntervalSinceReferenceDate;

         NSString *durationText =
         [NSString
          durationTextForDuration:elapsedTime
          startTime:timelineItem.startTime
          active:NO];

         NSString *secondaryText =
         [NSString
          stringWithFormat:@"%@",
          durationText];

         [cell
          updatePrimaryLabel:[NSString stringWithFormat:@"Entry %ld", (long)item.indexPath.item]
          secondaryLabel:secondaryText
          notesLabel:@"This is an entry note."];

     } selectAction:^(PBCollectionViewController *viewController) {
     }];

    item.zIndex = 99;

    return item;
}

- (PBSectionItem *)buildTimerSection {

    NSMutableArray *items = [NSMutableArray array];

    [items addObject:[self buildTimerItemHour:8]];
    [items addObject:[self buildTimerItemHour:9]];
    [items addObject:[self buildTimerItemHour:12]];
    [items addObject:[self buildTimerItemHour:14]];
    [items addObject:[self buildTimerItemHour:16]];

    return [PBSectionItem sectionItemWithItems:items];
}

- (PBSectionItem *)buildDecorationSection {

    NSMutableArray *items = [NSMutableArray array];
    PBCollectionItem *item;
    NSInteger index = 0;

    for (NSInteger i = 0; i <= 24; i++) {

        item =
        [self
         buildTimelineHourItem:i
         index:index++];

        [items addObject:item];
    }

    return [PBSectionItem sectionItemWithItems:items];
}

- (PBCollectionItem *)buildTimelineHourItem:(NSInteger)hour
                                      index:(NSInteger)index {

    __weak typeof(self) this = self;

    PBCollectionItem *item =
    [PBCollectionItem
     customClassItemWithUserContext:@(hour)
     reuseIdentifier:[NSString stringWithFormat:@"hour-decoration-%ld", (long)hour]
     cellClass:[PBCalendarHourDecorationCell class]
     configure:^(PBCollectionViewController *viewController, PBCollectionItem *item, PBCalendarHourDecorationCell *cell) {

         NSInteger hour = [item.userContext integerValue];

         [item.userContext description];
         cell.quarterHourLabel.text = @":15";
         cell.halfHourLabel.text = @":30";
         cell.threeQuarterHourLabel.text = @":45";
         cell.hour = hour;

     } binding:^(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, PBCalendarHourDecorationCell *cell) {

         [this updateVisibleHourCell:cell];

     } selectAction:nil];

    return item;
}

#pragma mark -

- (void)updateVisibleHourCells {

    for (PBCalendarHourDecorationCell *cell in self.collectionView.visibleCells) {
        if ([cell isKindOfClass:[PBCalendarHourDecorationCell class]]) {
            [self updateVisibleHourCell:cell];
        }
    }
}

- (void)updateVisibleHourCell:(PBCalendarHourDecorationCell *)cell {

    cell.scale = self.timelineLayout.scale;
    cell.pixelsPerHour = self.timelineLayout.pixelsPerHour;
    cell.hourGutterWidth = self.timelineLayout.hourGutterWidth;
    cell.hourPosition = self.timelineLayout.midnightPosition;
    cell.pinching = self.isPinching;
    cell.minScale = .4f;
}

- (PBCalendarLayout *)timelineLayout {
    return (id)self.collectionLayout;
}

- (void)scrollToTopAnimated:(void(^)(void))completionBlock {

    self.scrollToTopCompletionBlock = completionBlock;

    NSIndexPath *indexPath =
    [NSIndexPath indexPathForItem:0 inSection:PBCalendarSectionDecorations];

    [self.collectionView
     scrollToItemAtIndexPath:indexPath
     atScrollPosition:UICollectionViewScrollPositionTop
     animated:YES];
}

- (void)scrollToBottomAnimated:(void(^)(void))completionBlock {

    self.scrollToTopCompletionBlock = completionBlock;

    PBSectionItem *decorationSection =
    self.dataSource[PBCalendarSectionDecorations];

    NSIndexPath *indexPath =
    [NSIndexPath
     indexPathForItem:decorationSection.items.count-1
     inSection:PBCalendarSectionDecorations];

    [self.collectionView
     scrollToItemAtIndexPath:indexPath
     atScrollPosition:UICollectionViewScrollPositionBottom
     animated:YES];
}

- (CGFloat)minimumCollectionViewContentOffset {
    UIEdgeInsets insets = self.collectionView.contentInset;
    return -insets.top;
}

- (CGFloat)maximumCollectionViewContentOffset {
    UIEdgeInsets insets = self.collectionView.contentInset;
    return
    [self.timelineLayout heightForDuration:kTCSTimerDayInSeconds] -
    [self.timelineLayout visibleViewHeight] -
    insets.bottom;
}

#pragma mark - Gestures

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateEnded) {

        CGFloat scale = self.timelineLayout.scale;

        CGFloat distanceToSmallestScale =
        fabsf(scale - self.timelineLayout.scaleForMaxHeight);

        CGFloat distanceToLargestScale = fabsf(1.0f - scale);

        self.pinching = NO;

        if (distanceToLargestScale < distanceToSmallestScale) {

            CGFloat minContentOffset = [self minimumCollectionViewContentOffset];

            if (self.collectionView.contentOffset.y > minContentOffset) {

                [self scrollToTopAnimated:^{

                    [self updateScale:0.0f animate:YES];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }];

            } else {

                [self updateScale:0.0f animate:YES];
            }

        } else {

            [self updateScale:1.0f animate:YES];
        }
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture {

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {

            self.pinching = YES;
            ((PBCollectionView *)self.collectionView).contentOffsetAdjustingDisabled = YES;
            self.collectionView.scrollEnabled = NO; // bad boy sets content offset to top

            _startingPinchScale = self.timelineLayout.scale;
            _startingPinchContentOffset = self.collectionView.contentOffset.y;

            _startingPinchLocation =
            [gesture locationInView:self.collectionView].y ;

            _startingPinchLocationInContainer = [gesture locationInView:self.view].y;

            _centeredPinchLocationPercent = _startingPinchLocation / self.collectionView.contentSize.height;

            _startingPinchHeight = self.collectionView.contentSize.height / _startingPinchScale;

            _pinchTranslationVelocity = 0.0f;
            _pinchLastTimestamp = [NSDate timeIntervalSinceReferenceDate];

        } break;

        case UIGestureRecognizerStateChanged: {

            CGFloat scale = _startingPinchScale * gesture.scale;

            [self updateScale:scale animate:NO];

            scale = self.timelineLayout.scale;

            CGFloat scaledHeight = _startingPinchHeight * scale;
            CGFloat centeredPinchLocation = scaledHeight * _centeredPinchLocationPercent;
            CGFloat pinchLocationInContainer =
            [gesture locationInView:self.view].y;

            CGFloat centerDiff = centeredPinchLocation - _startingPinchLocation;

            CGPoint contentOffset = self.collectionView.contentOffset;
            contentOffset.y = _startingPinchContentOffset;
            contentOffset.y += centerDiff;

            CGFloat translationDelta =
            pinchLocationInContainer - _startingPinchLocationInContainer;

            contentOffset.y -= translationDelta;

            NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];

            NSTimeInterval deltaTime = now - _pinchLastTimestamp;

            CGFloat velocity = (pinchLocationInContainer - _pinchLastTranslationPosition) / deltaTime;

            _pinchLastTranslationPosition = pinchLocationInContainer;
            _pinchLastTimestamp = now;
            _pinchTranslationVelocity = velocity;

            [self updateContentOffset:contentOffset];

        } break;
            
        default: {

            self.pinching = NO;
            ((PBCollectionView *)self.collectionView).contentOffsetAdjustingDisabled = NO;

            if (self.collectionView.contentOffset.y < [self minimumCollectionViewContentOffset]) {
                [self scrollToTopAnimated:^{
                    self.collectionView.scrollEnabled = YES;
                }];
            } else if (self.collectionView.contentOffset.y > [self maximumCollectionViewContentOffset]) {
                [self scrollToBottomAnimated:^{
                    self.collectionView.scrollEnabled = YES;
                }];
            } else {
                self.collectionView.scrollEnabled = YES;
            }

//            Playing with scroll after pinch with velocity
//            
//            NSLog(@"velocity: %f", _pinchTranslationVelocity);
//
//            CGFloat k = 2.0f; // spring constant
//            NSTimeInterval duration = .15f;
//
//            CGPoint contentOffset = self.collectionView.contentOffset; // y0
//            contentOffset.y -= _pinchTranslationVelocity * duration; // vt
//
//            CGRect rect = CGRectMake(0.0f, contentOffset.y, 1.0f, 1.0f);
//
//            NSLog(@"rect: %@", NSStringFromCGRect(rect));
//
//            if (_pinchTranslationVelocity != 0.0) {
//
//                CGFloat springForce = 0.0f;
//
//                if (contentOffset.y < [self minimumCollectionViewContentOffset]) {
//                    springForce = -k * ([self minimumCollectionViewContentOffset] - contentOffset.y);
//
//                } else if (contentOffset.y > [self maximumCollectionViewContentOffset]) {
//                    springForce = -k * (contentOffset.y - [self maximumCollectionViewContentOffset]);
//                }
//
//                contentOffset.y -= springForce * duration * duration;
//            }
//
//            if (contentOffset.y >= [self minimumCollectionViewContentOffset] ||
//                contentOffset.y <= [self maximumCollectionViewContentOffset]) {
//
//                CGRect rect = CGRectMake(0.0f, contentOffset.y, 1.0f, 1.0f);
//                NSLog(@"rect: %@", NSStringFromCGRect(rect));
//            }
//
//            [UIView
//             animateWithDuration:duration
//             delay:0.0f
//             options:UIViewAnimationOptionCurveEaseOut
//             animations:^{
//
//                 self.collectionView.contentOffset = contentOffset;
//
//             } completion:^(BOOL finished) {
//
//                 if (self.collectionView.contentOffset.y < [self minimumCollectionViewContentOffset]) {
//                     [self scrollToTopAnimated:^{
//                         self.collectionView.scrollEnabled = YES;
//                     }];
//                 } else if (self.collectionView.contentOffset.y > [self maximumCollectionViewContentOffset]) {
//                     [self scrollToBottomAnimated:^{
//                         self.collectionView.scrollEnabled = YES;
//                     }];
//                 } else {
//                     self.collectionView.scrollEnabled = YES;
//                 }
//             }];

        } break;
    }
}

#pragma mark - UICollectionViewDelegate Conformance

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

    if (self.scrollToTopCompletionBlock != nil) {

        void (^completionBlock)(void) = self.scrollToTopCompletionBlock;

        self.scrollToTopCompletionBlock();

        if (completionBlock == self.scrollToTopCompletionBlock) {
            self.scrollToTopCompletionBlock = nil;
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate Conformance

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
