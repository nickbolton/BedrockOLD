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

        if (expanded) {
            [self becomeFirstResponder];
        } else {
            [self resignFirstResponder];
        }

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

                [self.listViewController.tableView
                 insertRowsAtIndexPaths:@[expandedItemIndexPath]
                 withRowAnimation:UITableViewRowAnimationAutomatic];

            } else {

                [self.listViewController
                 removeItemAtIndexPath:expandedItemIndexPath];

                [self.listViewController.tableView
                 deleteRowsAtIndexPaths:@[expandedItemIndexPath]
                 withRowAnimation:UITableViewRowAnimationAutomatic];
            }

            [self.listViewController.tableView endUpdates];
        }
    }
}

- (void)resignFirstResponder {
    [super resignFirstResponder];

    if (self.isExpanded) {
        self.expanded = NO;
    }
}

@end
