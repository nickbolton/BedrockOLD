//
//  PBListDatePickerExpandedItem.m
//  Pods
//
//  Created by Nick Bolton on 3/6/14.
//
//

#import "PBListDatePickerExpandedItem.h"

static CGFloat const kPBListDatePickerHeight = 216.0f;

@implementation PBListDatePickerExpandedItem

#pragma mark - Public

- (void)valueChanged:(UIDatePicker *)datePicker {


    BOOL reloadItemOnValueChange = self.reloadItemOnValueChange;
    self.reloadItemOnValueChange = NO;
    self.date = datePicker.date;
    self.reloadItemOnValueChange = reloadItemOnValueChange;

    [super valueChanged:datePicker];
}

#pragma mark - Getters and Setters

- (CGFloat)rowHeight {
    return kPBListDatePickerHeight;
}

- (NSString *)date {
    return self.itemValue;
}

- (void)setDate:(NSDate *)date {
    self.itemValue = date;
}

- (UIDatePicker *)datePicker {
    return (id)self.control;
}

- (void)setDatePicker:(UIDatePicker *)datePicker {

    if (self.dateRange != nil) {
        datePicker.minimumDate = self.dateRange.startDate;
        datePicker.maximumDate = self.dateRange.endDate;
    }
    
    self.control = datePicker;
}

@end
