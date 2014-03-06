//
//  PBListDatePickerRenderer.m
//  Pods
//
//  Created by Nick Bolton on 3/3/14.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListDatePickerRenderer.h"
#import "PBListDatePickerExpandedItem.h"
#import "PBListViewExpandableCell.h"

@interface PBListDatePickerRenderer()
@end

@implementation PBListDatePickerRenderer

- (void)renderItem:(PBListDatePickerExpandedItem *)item
       atIndexPath:(NSIndexPath *)indexPath
            inCell:(PBListViewExpandableCell *)cell
      withListView:(PBListViewController *)listViewController {

    [super
     renderItem:item
     atIndexPath:indexPath
     inCell:cell
     withListView:listViewController];

    if ([item isKindOfClass:[PBListDatePickerExpandedItem class]]) {

        [self renderCell:cell withItem:item];
    }
}

- (UIDatePicker *)cellDatePicker:(PBListViewExpandableCell *)cell
                            item:(PBListDatePickerExpandedItem *)item {

    static NSInteger const datePickerTag = 998;

    UIDatePicker *datePicker = (id)[cell viewWithTag:datePickerTag];

    if (datePicker == nil) {

        datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.translatesAutoresizingMaskIntoConstraints = NO;
        datePicker.tag = datePickerTag;

        [cell.contentView addSubview:datePicker];

        [NSLayoutConstraint expandToSuperview:datePicker];
    }

    return datePicker;
}

- (void)renderCell:(PBListViewExpandableCell *)cell
          withItem:(PBListDatePickerExpandedItem *)item {

    UIDatePicker *datePicker = [self cellDatePicker:cell item:item];
    item.datePicker = datePicker;

    datePicker.date = item.date != nil ? item.date : [NSDate date];

    [self renderControl:datePicker withItem:item];
}

@end
