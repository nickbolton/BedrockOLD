//
//  PBListExpandableItem.m
//  Pods
//
//  Created by Nick Bolton on 3/6/14.
//
//

#import "PBListExpandableItem.h"
#import "PBListViewController.h"

@implementation PBListExpandableItem

- (void)setExpanded:(BOOL)expanded {

    BOOL changed = _expanded != expanded;

    if (changed) {

        _expanded = expanded;

        if (self.expandedItem != nil) {

            NSIndexPath *expandedItemIndexPath =
            [NSIndexPath
             indexPathForRow:self.indexPath.row+1
             inSection:self.indexPath.section];

            [self.listViewController.tableView beginUpdates];

            if (_expanded) {

                [self.listViewController
                 insertItem:self.expandedItem
                 atIndexPath:expandedItemIndexPath];

            } else {

                [self.listViewController
                 removeItemAtIndexPath:expandedItemIndexPath];
            }

            [self.listViewController.tableView endUpdates];
        }
    }
}

@end
