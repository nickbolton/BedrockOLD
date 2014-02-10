//
//  PBCalendarView.h
//  Calendar
//
//  Created by Nick Bolton on 2/8/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBCalendarView : UIScrollView

@property (nonatomic, strong) NSDateComponents *selectedDay;

- (void)setSelectedDay:(NSDateComponents *)selectedDay animated:(BOOL)animated;

- (void)scrollToMonth:(NSDate *)month;
- (void)scrollToMonth:(NSDate *)month animated:(BOOL)animated;
- (NSDate *)currentMonth;

@end
