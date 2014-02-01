//
//  PBCollectionView.m
//  CalendarDayView
//
//  Created by Nick Bolton on 2/1/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCollectionView.h"

@interface PBCollectionView() {

    CGPoint _lastContentOffset;
}

@end

@implementation PBCollectionView

- (void)setContentOffset:(CGPoint)contentOffset {

    if (self.isContentOffsetAdjustingDisabled) {
        return;
    }

//    _lastContentOffset = self.contentOffset;
//
//    if (self.isPinching && ABS(_lastContentOffset.y - contentOffset.y) > 10) {
//
//        // fixing some weird issue where the scroll view is auto adjusting the content
//        // offset back to the top when pinching
//        return;
//    }
//
//    NSLog(@"pinching: %d, co: %f", self.isPinching, contentOffset.y);
//
//    if (contentOffset.y == -20.f) {
//        NSLog(@"ZZZZ");
//    }
//
    [super setContentOffset:contentOffset];
}

- (void)setPinchingContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
}

@end
