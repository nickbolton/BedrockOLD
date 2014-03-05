//
//  PBListExpandableControlItem.m
//  Pods
//
//  Created by Nick Bolton on 3/5/14.
//
//

#import "PBListExpandableControlItem.h"
#import "PBListViewController.h"

@implementation PBListExpandableControlItem

- (void)setExpanded:(BOOL)expanded {

    BOOL changed = _expanded != expanded;

    if (changed) {

        _expanded = expanded;

        [self.listViewController
         reloadTableRowAtIndexPath:self.indexPath
         withAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (CGFloat)rowHeight {

    if (self.isExpanded) {
        return self.expandableHeight + [super rowHeight];
    }

    return [super rowHeight];
}

@end
