//
//  PBListExpandableItem.h
//  Pods
//
//  Created by Nick Bolton on 3/6/14.
//
//

#import "PBListItem.h"

@interface PBListExpandableItem : PBListItem

@property (nonatomic, getter = isExpanded) BOOL expanded;
@property (nonatomic, strong) PBListItem *expandedItem;

@end
