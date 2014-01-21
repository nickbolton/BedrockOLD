//
//  PBCalendarSelectionViewController.h
//  Calendar
//
//  Created by Nick Bolton on 1/19/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "Emitter.h"

@class PBDateRange;

@class PBCalendarSelectionViewController;

@protocol PBCalendarSelectionDelegate <NSObject>

- (void)calendarSelectionViewController:(PBCalendarSelectionViewController *)viewController
                       didSelectedRange:(PBDateRange *)selectedRange;
- (void)calendarSelectionViewControllerCancelled:(PBCalendarSelectionViewController *)viewController;

@end

@interface PBCalendarSelectionViewController : PBListViewController

+ (void)presentCalendarSelectionViewController:(UIViewController *)presentingViewController
                                      delegate:(id <PBCalendarSelectionDelegate>)delegate
                                  modeSwitchOn:(BOOL)modeSwitchOn
                             firstDayOfTheWeek:(NSInteger)firstDayOfTheWeek
                         withSelectedDateRange:(PBDateRange *)dateRange
                                    completion:(void(^)(void))completionBlock;

+ (void)presentCalendarSelectionViewController:(UIViewController *)presentingViewController
                                      delegate:(id <PBCalendarSelectionDelegate>)delegate
                                  modeSwitchOn:(BOOL)modeSwitchOn
                             firstDayOfTheWeek:(NSInteger)firstDayOfTheWeek
                              withSelectedDate:(NSDate *)date
                                    completion:(void(^)(void))completionBlock;

- (id)initWithSelectedDateRange:(PBDateRange *)dateRange
                   modeSwitchOn:(BOOL)modeSwitchOn
              firstDayOfTheWeek:(NSInteger)firstDayOfTheWeek;
- (id)initWithSelectedDate:(NSDate *)date
              modeSwitchOn:(BOOL)modeSwitchOn
         firstDayOfTheWeek:(NSInteger)firstDayOfTheWeek;

@property (nonatomic) UIEdgeInsets separatorInsets;
@property (nonatomic, readonly) BOOL modeSwitchOn;
@property (nonatomic) id <PBCalendarSelectionDelegate> delegate;

@end
