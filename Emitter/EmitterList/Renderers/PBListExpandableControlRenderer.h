//
//  PBListExpandableControlRenderer.h
//  Pods
//
//  Created by Nick Bolton on 3/5/14.
//
//

#import "PBListControlRenderer.h"

@class PBListViewExpandableCell;
@class PBListExpandableControlItem;

@interface PBListExpandableControlRenderer : PBListControlRenderer

- (void)renderCell:(PBListViewExpandableCell *)cell
          withItem:(PBListExpandableControlItem *)item
      expandedView:(UIView *)view;

@end
