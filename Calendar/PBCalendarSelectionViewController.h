//
//  PBCalendarSelectionViewController.h
//  Bedrock
//
//  Created by David Beck on 5/7/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBCalendarView;
@class PBCalendarSelectionViewController;

@protocol PBCalendarSelectionDelegate <NSObject>

- (void)calendarSelectionViewController:(PBCalendarSelectionViewController *)viewController
                       didSelectedRange:(PBDateRange *)selectedRange;
- (void)calendarSelectionViewControllerCancelled:(PBCalendarSelectionViewController *)viewController;

@end

@interface PBCalendarSelectionViewController : UIViewController

@property (nonatomic) id <PBCalendarSelectionDelegate> delegate;

- (id)initWithSelectedDateRange:(PBDateRange *)dateRange
                   modeSwitchOn:(BOOL)modeSwitchOn;
- (id)initWithSelectedDate:(NSDate *)date
              modeSwitchOn:(BOOL)modeSwitchOn;

- (void)showToday:(id)sender;

@end
