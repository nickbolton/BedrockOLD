//
//  PBCollectionView.h
//  CalendarDayView
//
//  Created by Nick Bolton on 2/1/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBCollectionView : UICollectionView

@property (nonatomic, getter = isContentOffsetAdjustingDisabled) BOOL contentOffsetAdjustingDisabled;

- (void)setPinchingContentOffset:(CGPoint)contentOffset;

@end
