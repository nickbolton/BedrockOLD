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
#import "PBListDatePickerExpandedItem.h"

@interface PBListDatePickerItem() {
}

@end

@implementation PBListDatePickerItem

+ (PBListDatePickerItem *)datePickerItemWithTitle:(NSString *)title
                                             date:(NSDate *)date
                                     valueUpdated:(void(^)(PBListDatePickerItem *item, NSDate *updatedValue))valueUpdatedBlock {

    PBListDatePickerItem *item = [[PBListDatePickerItem alloc] init];

    [item commonInit];
    item.title = title;
    item.value = [item.dateFormatter stringFromDate:date];
    item.itemType = PBItemTypeDefault;
    item.hasDisclosure = YES;
    item.selectionStyle = UITableViewCellSelectionStyleGray;
    item.valueColor = [UIColor grayColor];

    item.selectActionBlock = ^(PBListViewExpandableCell *cell) {

        PBListDatePickerItem *item = (id)cell.item;
        item.expanded = !item.expanded;


        if (item.isExpanded) {

            NSIndexPath *expandedIndexPath =
            [NSIndexPath
             indexPathForRow:item.indexPath.row+1
             inSection:item.indexPath.section];

            [item.listViewController.tableView
             scrollToRowAtIndexPath:expandedIndexPath
             atScrollPosition:UITableViewScrollPositionBottom
             animated:NO];
        }
    };

    PBListDatePickerExpandedItem *expandedItem =
    [[PBListDatePickerExpandedItem alloc] init];

    [expandedItem commonInit];
    expandedItem.itemType = PBItemTypeCustom;
    expandedItem.date = date;
    expandedItem.cellID = NSStringFromClass([PBListDatePickerExpandedItem class]);
    expandedItem.cellClass = [PBListViewDefaultCell class];
    expandedItem.valueUpdatedBlock = ^(PBListControlItem *controlItem, NSDate *updatedValue) {

        item.value = [item.dateFormatter stringFromDate:updatedValue];

        [item.listViewController
         reloadTableRowAtIndexPath:item.indexPath
         withAnimation:UITableViewRowAnimationAutomatic];

        if (valueUpdatedBlock != nil) {
            valueUpdatedBlock(item, updatedValue);
        }
    };

    item.expandedItem = expandedItem;

    return item;
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

- (void)setDateRange:(PBDateRange *)dateRange {
    _dateRange = dateRange;

    PBListDatePickerExpandedItem *expandedItem = (id)self.expandedItem;
    expandedItem.dateRange = dateRange;
}

@end
