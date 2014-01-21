//
//  PBCalendarDayCell.h
//  Calendar
//
//  Created by Nick Bolton on 1/19/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCollectionDefaultCell.h"

@interface PBCalendarDayCell : PBCollectionDefaultCell

@property (nonatomic, readonly) UILabel *dayLabel;
@property (nonatomic, getter = isStartingDay) BOOL startingDay;
@property (nonatomic, getter = isEndingDay) BOOL endingDay;
@property (nonatomic, getter = isWithinRange) BOOL withinRange;
@property (nonatomic, getter = isCurrentDay) BOOL currentDay;

@end
