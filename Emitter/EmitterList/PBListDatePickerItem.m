//
//  PBListDatePickerItem.m
//  Pods
//
//  Created by Nick Bolton on 3/3/14.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListDatePickerItem.h"
#import "PBListViewExpandableCell.h"
#import "PBListTextRenderer.h"
#import "PBListViewController.h"

static CGFloat const kPBListDatePickerHeight = 216.0f;

@interface PBListDatePickerItem() {
}

@end

@implementation PBListDatePickerItem

+ (PBListDatePickerItem *)datePickerItemWithTitle:(NSString *)title
                                             date:(NSDate *)date
                                     valueUpdated:(void(^)(PBListControlItem *item, NSDate *updatedValue))valueUpdatedBlock {

    PBListDatePickerItem *item = [[PBListDatePickerItem alloc] init];

    [item commonInit];
    item.title = title;
    item.date = date;
    item.value = [item.dateFormatter stringFromDate:date];
    item.itemType = PBItemTypeCustom;
    item.cellID = NSStringFromClass([self class]);
    item.cellClass = [PBListViewExpandableCell class];
    item.valueUpdatedBlock = valueUpdatedBlock;

    return item;
}

#pragma mark - Public

- (void)valueChanged:(UIDatePicker *)datePicker {

    self.date = datePicker.date;

    [super valueChanged:datePicker];
}

#pragma mark - Getters and Setters

- (CGFloat)expandableHeight {
    return kPBListDatePickerHeight;
}

- (NSDateFormatter *)dateFormatter {

    if (_dateFormatter == nil) {

        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
        _dateFormatter.timeStyle = NSDateFormatterNoStyle;
        _dateFormatter.locale = [NSLocale autoupdatingCurrentLocale];
    }

    return _dateFormatter;
}

- (NSString *)date {
    return self.itemValue;
}

- (void)setDate:(NSDate *)date {
    self.itemValue = date;
}

- (void)setDatePicker:(UIDatePicker *)datePicker {
    self.control = datePicker;
}

@end
