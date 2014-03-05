//
//  PBListExpandableControlItem.h
//  Pods
//
//  Created by Nick Bolton on 3/5/14.
//
//

#import "PBListControlItem.h"

@interface PBListExpandableControlItem : PBListControlItem

@property (nonatomic, getter = isExpanded) BOOL expanded;
@property (nonatomic) CGFloat expandableHeight;

@end
