//
//  PBListExpandableControlRenderer.m
//  Pods
//
//  Created by Nick Bolton on 3/5/14.
//
//

#import "PBListExpandableControlRenderer.h"
#import "PBListViewExpandableCell.h"
#import "PBListExpandableControlItem.h"

@implementation PBListExpandableControlRenderer

- (void)renderCell:(PBListViewExpandableCell *)cell
          withItem:(PBListExpandableControlItem *)item
      expandedView:(UIView *)view {

    if (item.isExpanded) {

        cell.defaultCellHeight.constant = item.rowHeight - item.expandableHeight;
        [self addExpandedView:view toCell:cell withItem:item];

    } else {

        [view removeFromSuperview];
        cell.defaultCellHeight.constant = item.rowHeight;
    }

    cell.titleLeadingSpace.constant = item.titleMargin;
    cell.valueTrailingSpace.constant = item.valueMargin;
}

- (void)addExpandedView:(UIView *)view
                 toCell:(PBListViewExpandableCell *)cell
               withItem:(PBListExpandableControlItem *)item {

    [cell.contentView addSubview:view];

    [NSLayoutConstraint addHeightConstraint:item.expandableHeight toView:view];
    [NSLayoutConstraint alignToBottom:view withPadding:0.0f];
    [NSLayoutConstraint alignToLeft:view withPadding:0.0f];
    [NSLayoutConstraint alignToRight:view withPadding:0.0f];

}

@end
