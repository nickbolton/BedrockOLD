//
//  PBCalendarDayViewController.h
//  Sometime
//
//  Created by Nick Bolton on 1/2/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCollectionViewController.h"

@class PBCalendarDayViewController;
@class PBCalendarLayout;

@interface PBCalendarDayViewController : PBCollectionViewController

@property (nonatomic) NSInteger itemIndex;
@property (nonatomic, strong) NSDate *dayDate;
@property (nonatomic, readonly) PBCalendarLayout *timelineLayout;
@property (nonatomic, strong) NSLayoutConstraint *leadingSpace;
@property (nonatomic, getter = isPinching) BOOL pinching;

- (void)updateContentOffset:(CGPoint)contentOffset;
- (void)updateScale:(CGFloat)scale animate:(BOOL)animate;
- (void)scrollToTopAnimated:(void(^)(void))completionBlock;

@end
