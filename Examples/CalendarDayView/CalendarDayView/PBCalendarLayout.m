//
//  PBCalendarLayout.m
//  Sometime
//
//  Created by Nick Bolton on 1/2/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCalendarLayout.h"
#import "PBCalendarItem.h"
#import "PBCalendarHourDecorationCell.h"

static CGFloat const kPBCalendarLayoutControlsPadding = 88.0f;
static CGFloat const kPBCalendarLayoutPixelsPerHour = 128.0f;
static CGFloat const kPBCalendarLayoutHourGutterWidth = 32.0f;
static CGFloat const kPBCalendarLayoutTimerMinX = kPBCalendarLayoutHourGutterWidth + 16.0f;
static CGFloat const kPBCalendarTabBarHeight = 25.0f;
static CGFloat const kPBCalendarHourPosition = 10.5f;
static CGFloat const kPBCalendarTimerPadding = 1.0f;

@implementation PBCalendarLayout

- (id)init {
    self = [super init];

    if (self != nil) {
    }

    return self;
}

- (CGFloat)yPositionForDate:(NSDate *)date item:(PBCalendarItem *)item {

    NSDate *midnight = [item.startTime midnight];

    if ([date isLessThan:midnight]) {
        date = midnight;
    }

    NSTimeInterval timeIntervalSinceMidnight =
    date.timeIntervalSinceReferenceDate -  midnight.timeIntervalSinceReferenceDate;

    CGFloat yPos =
    (timeIntervalSinceMidnight / kTCSTimerHourInSeconds) * self.pixelsPerHour;

    return [self halfPixelAligned:yPos];
}

- (CGFloat)timerViewWidthWithNoEvents {
    static CGFloat const maxWidth = 256.0f;
    return maxWidth;
}

- (void)setScale:(CGFloat)scale {
    CGFloat minScale = [self scaleForMaxHeight];
    _scale = MAX(scale, minScale);
}

- (CGFloat)dayHeight {
    NSTimeInterval oneDayDuration = kTCSTimerDayInSeconds;
    return [self heightForDuration:oneDayDuration] + (2.0f * kPBCalendarTimerPadding);
}

- (CGFloat)pixelsPerHour {
    return kPBCalendarLayoutPixelsPerHour * self.scale;
}

- (CGFloat)hourGutterWidth {
    return kPBCalendarLayoutHourGutterWidth;
}

- (CGFloat)midnightPosition {
    return kPBCalendarHourPosition + kPBCalendarTimerPadding;
}

- (CGFloat)minHeight {
    return
    self.pixelsPerHour * (kTCSTimerMinimumDuration/kTCSTimerHourInSeconds) - (2.0f * kPBCalendarTimerPadding); // 15 minutes
}

- (CGFloat)scaleForMaxHeight {
    return (self.visibleViewHeight-3.0f) / 25.0f / kPBCalendarLayoutPixelsPerHour;
}

- (CGFloat)halfPixelAligned:(CGFloat)pos {
    return roundf(pos * 2.0f) / 2.0f;
}

- (CGFloat)heightForDuration:(NSTimeInterval)duration {

    CGFloat height =
    MAX([self minHeight],
        self.pixelsPerHour * (duration / kTCSTimerHourInSeconds));

    return [self halfPixelAligned:height] - (2.0f * kPBCalendarTimerPadding);
}

- (NSTimeInterval)durationSinceMidnightAtYPos:(CGFloat)yPos {

    CGFloat heightSinceMidnight = yPos - self.midnightPosition - kPBCalendarTimerPadding;
    return (heightSinceMidnight / self.pixelsPerHour) * kTCSTimerHourInSeconds;
}

- (CGFloat)yPosForDurationSinceMidnight:(NSTimeInterval)duration {
    return self.midnightPosition + [self heightForDuration:duration] + kPBCalendarTimerPadding;
}

- (void)configureAttributes:(UICollectionViewLayoutAttributes *)itemAttributes
                   withItem:(PBCollectionItem *)item
                atIndexPath:(NSIndexPath *)indexPath {

    if ([item isKindOfClass:[PBCalendarItem class]]) {

        [self
         configureTimerAttributes:itemAttributes
         withItem:(id)item
         atIndexPath:indexPath];

    } else if (item.cellClass == [PBCalendarHourDecorationCell class]) {

        [self
         configureTimelineHourAttributes:itemAttributes
         withItem:item
         atIndexPath:indexPath];
    }

    [super configureAttributes:itemAttributes withItem:item atIndexPath:indexPath];
}

- (void)configureTimerAttributes:(UICollectionViewLayoutAttributes *)itemAttributes
                        withItem:(PBCalendarItem *)item
                     atIndexPath:(NSIndexPath *)indexPath {

    NSTimeInterval timeInterval =
    item.endTime.timeIntervalSinceReferenceDate -
    item.startTime.timeIntervalSinceReferenceDate;

    CGFloat yPos =
    [self yPositionForDate:item.startTime item:item] -
    (kPBCalendarLayoutControlsPadding / 2.0f) +
    self.midnightPosition + kPBCalendarTimerPadding;

    if (self.itemFromPromotion == item) {

        item.point =
        CGPointMake(self.promotedItem.point.x,
                    [self halfPixelAligned:yPos]);

    } else {

        item.point =
        CGPointMake(kPBCalendarLayoutTimerMinX,
                    [self halfPixelAligned:yPos]);
    }

    CGFloat height =
    kPBCalendarLayoutControlsPadding + [self heightForDuration:timeInterval];

    item.size =
    CGSizeMake([self timerViewWidthWithNoEvents],
               [self halfPixelAligned:height]);
}

- (void)configureTimelineHourAttributes:(UICollectionViewLayoutAttributes *)itemAttributes
                               withItem:(PBCollectionItem *)item
                            atIndexPath:(NSIndexPath *)indexPath {

    NSInteger hour = [item.userContext integerValue];

    item.point =
    CGPointMake(0.0f,
                [self halfPixelAligned:self.pixelsPerHour * hour]);

    item.size =
    CGSizeMake(CGRectGetWidth(self.collectionView.frame),
               [self halfPixelAligned:self.pixelsPerHour]);
}

- (CGSize)collectionViewContentSize {

    CGFloat oneDayHeight = [self dayHeight];

    CGSize size =
    CGSizeMake(CGRectGetWidth(self.collectionView.frame),
               oneDayHeight + kPBCalendarTabBarHeight);

    return size;
}

@end
