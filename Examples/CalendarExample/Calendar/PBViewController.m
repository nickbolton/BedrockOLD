//
//  PBViewController.m
//  Calendar
//
//  Created by Nick Bolton on 1/19/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBViewController.h"
#import "PBCalendarSelectionViewController.h"

@interface PBViewController () <PBCalendarSelectionDelegate>

@property (nonatomic, strong) PBDateRange *selectedDateRange;

@end

@implementation PBViewController

#pragma mark - Setup

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDate *startDate =
    [NSDate dateWithYear:2013 month:11 day:17];

    NSDate *endDate =
    [NSDate dateWithYear:2013 month:11 day:23];

    self.selectedDateRange =
    [PBDateRange dateRangeWithStartDate:startDate endDate:endDate];

    [self updateDateLabels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)selectDate:(id)sender {

    PBCalendarSelectionViewController *viewController =
    [[PBCalendarSelectionViewController alloc]
     initWithSelectedDateRange:self.selectedDateRange
     modeSwitchOn:YES];

    viewController.delegate = self;

    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - 

- (void)updateDateLabels {

    self.startDateLabel.text =
    [NSDateFormatter
     localizedStringFromDate:self.selectedDateRange.startDate
     dateStyle:NSDateFormatterShortStyle
     timeStyle:NSDateFormatterNoStyle];

    self.endDateLabel.text =
    [NSDateFormatter
     localizedStringFromDate:self.selectedDateRange.endDate
     dateStyle:NSDateFormatterShortStyle
     timeStyle:NSDateFormatterNoStyle];
}

#pragma mark - PBCalendarViewDelegate Conformance

- (void)calendarSelectionViewController:(PBCalendarSelectionViewController *)viewController
                       didSelectedRange:(PBDateRange *)selectedRange {

    self.selectedDateRange = selectedRange;
    [self updateDateLabels];
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)calendarSelectionViewControllerCancelled:(PBCalendarSelectionViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
