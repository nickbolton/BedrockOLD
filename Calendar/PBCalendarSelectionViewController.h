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
- (void)calendarSelectionViewControllerPresentJumpToActionSheet:(PBCalendarSelectionViewController *)viewController
                                                          title:(NSString *)title
                                                   buttonTitles:(NSArray *)buttonTitles
                                                 actionDelegate:(PBActionDelegate *)actionDelegate;

@end

@interface PBCalendarSelectionViewController : UIViewController

@property (nonatomic) id <PBCalendarSelectionDelegate> delegate;
@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *weekdayTextColor;
@property (nonatomic, strong) UIColor *weekendTextColor;
@property (nonatomic, strong) UIColor *monthIndicatorTextColor;
@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic) UIBarStyle barStyle;
@property (nonatomic) BOOL showCancel;

- (id)initWithSelectedDateRange:(PBDateRange *)dateRange
                   modeSwitchOn:(BOOL)modeSwitchOn;
- (id)initWithSelectedDate:(NSDate *)date
              modeSwitchOn:(BOOL)modeSwitchOn;

- (void)showToday:(id)sender;

@end
