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

        [self.listViewController
         reloadTableRowAtIndexPath:self.indexPath
         withAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
