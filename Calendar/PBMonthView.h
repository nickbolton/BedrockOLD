//
//  PBMonthView.h
//  Calendar
//
//  Created by Nick Bolton on 1/19/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBDateRange;

@interface PBMonthView : UIView

@property (nonatomic, readonly) NSInteger year;
@property (nonatomic, readonly) NSInteger month;
@property (nonatomic, strong) PBDateRange *selectedDateRange;
@property (nonatomic) BOOL hideStartingPointMarker;
@property (nonatomic) BOOL hideEndingPointMarker;

- (void)setYear:(NSInteger)year month:(NSInteger)month;
- (void)setYearAndMonthFromDate:(NSDate *)date;

- (NSDateComponents *)dateComponentsAtPoint:(CGPoint)point;
- (NSDateComponents *)nearestDateComponentsAtPoint:(CGPoint)point;
- (void)updateView;

- (CGPoint)pointForStartingMarkerView;
- (CGPoint)pointForEndingMarkerView;

@end
