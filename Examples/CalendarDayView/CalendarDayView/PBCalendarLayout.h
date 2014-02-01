//
//  PBCalendarLayout.h
//  Sometime
//
//  Created by Nick Bolton on 1/2/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCollectionLayout.h"

@class PBCalendarItem;

@interface PBCalendarLayout : PBCollectionLayout

@property (nonatomic) CGFloat scale;
@property (nonatomic, readonly) CGFloat pixelsPerHour;
@property (nonatomic, readonly) CGFloat midnightPosition;
@property (nonatomic, readonly) CGFloat hourGutterWidth;
@property (nonatomic) CGFloat visibleViewHeight;
@property (nonatomic, strong) PBCalendarItem *itemFromPromotion;
@property (nonatomic, strong) PBCollectionItem *promotedItem;

- (CGFloat)scaleForMaxHeight;
- (CGFloat)heightForDuration:(NSTimeInterval)duration;

- (NSTimeInterval)durationSinceMidnightAtYPos:(CGFloat)yPos;
- (CGFloat)yPosForDurationSinceMidnight:(NSTimeInterval)duration;

@end
