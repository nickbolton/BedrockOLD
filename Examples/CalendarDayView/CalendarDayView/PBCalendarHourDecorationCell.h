//
//  PBCalendarHourDecorationCell.h
//  Sometime
//
//  Created by Nick Bolton on 1/26/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCollectionDefaultCell.h"

@interface PBCalendarHourDecorationCell : PBCollectionDefaultCell

@property (nonatomic, readonly) UILabel *hourLabel;
@property (nonatomic, readonly) UILabel *quarterHourLabel;
@property (nonatomic, readonly) UILabel *halfHourLabel;
@property (nonatomic, readonly) UILabel *threeQuarterHourLabel;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGFloat minScale;
@property (nonatomic) CGFloat pixelsPerHour;
@property (nonatomic) CGFloat hourGutterWidth;
@property (nonatomic) CGFloat hourPosition;
@property (nonatomic) NSInteger hour;
@property (nonatomic, getter = isPinching) BOOL pinching;

@end
