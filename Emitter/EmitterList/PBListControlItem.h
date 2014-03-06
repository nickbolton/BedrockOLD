//
//  PBListControlItem.h
//  Pods
//
//  Created by Nick Bolton on 3/5/14.
//
//

#import "PBListItem.h"

@interface PBListControlItem : PBListItem

@property (nonatomic, strong) id itemValue;
@property (nonatomic, weak) PBListViewController *listViewController;
@property (nonatomic, weak) UIControl *control;
@property (nonatomic, copy) void (^editingDidBegin)(PBListControlItem *item);
@property (nonatomic, copy) void(^valueUpdatedBlock)(PBListControlItem *item, id updatedValue);
@property (nonatomic) BOOL reloadItemOnValueChange;

- (void)valueChanged:(UIControl *)control;

- (void)controlDidBeginEditing:(UIControl *)control;
- (void)controlDidEndEditing:(UIControl *)control;

@end
