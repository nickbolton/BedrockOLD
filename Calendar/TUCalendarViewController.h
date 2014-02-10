//
//  TUCalendarViewController.h
//  InfiniteCalendar
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBCalendarView;
@class TUCalendarViewController;

@protocol PBCalendarSelectionDelegate <NSObject>

- (void)calendarSelectionViewController:(TUCalendarViewController *)viewController
                       didSelectedRange:(PBDateRange *)selectedRange;
- (void)calendarSelectionViewControllerCancelled:(TUCalendarViewController *)viewController;

@end

@interface TUCalendarViewController : UIViewController

@property (nonatomic) id <PBCalendarSelectionDelegate> calendarDelegate;

- (id)initWithSelectedDateRange:(PBDateRange *)dateRange
                   modeSwitchOn:(BOOL)modeSwitchOn;
- (id)initWithSelectedDate:(NSDate *)date
              modeSwitchOn:(BOOL)modeSwitchOn;

- (void)showToday:(id)sender;

@end
