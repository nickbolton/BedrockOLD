//
//  PBListDatePickerRenderer.m
//  Pods
//
//  Created by Nick Bolton on 3/3/14.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListDatePickerRenderer.h"
#import "PBListDatePickerItem.h"
#import "PBListViewExpandableCell.h"

@interface PBListDatePickerRenderer()
@end

@implementation PBListDatePickerRenderer

- (void)renderItem:(PBListDatePickerItem *)item
       atIndexPath:(NSIndexPath *)indexPath
            inCell:(PBListViewExpandableCell *)cell
      withListView:(PBListViewController *)listViewController {

    [super
     renderItem:item
     atIndexPath:indexPath
     inCell:cell
     withListView:listViewController];

    if ([item isKindOfClass:[PBListDatePickerItem class]]) {

        [self renderCell:cell withItem:item];
    }
}

- (UIDatePicker *)cellDatePicker:(PBListViewExpandableCell *)cell
                            item:(PBListDatePickerItem *)item {

    static NSInteger const datePickerTag = 998;

    UIDatePicker *datePicker = (id)[cell viewWithTag:datePickerTag];

    if (datePicker == nil) {

        datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.translatesAutoresizingMaskIntoConstraints = NO;
        datePicker.tag = datePickerTag;
    }

    return datePicker;
}

- (void)renderCell:(PBListViewExpandableCell *)cell
          withItem:(PBListDatePickerItem *)item {

    UIDatePicker *datePicker = [self cellDatePicker:cell item:item];

    [super renderCell:cell withItem:item expandedView:datePicker];

    item.datePicker = datePicker;

    datePicker.date = item.date;

    [self renderControl:datePicker withItem:item];
}

@end
