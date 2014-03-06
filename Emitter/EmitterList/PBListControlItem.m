//
//  PBListControlItem.m
//  Pods
//
//  Created by Nick Bolton on 3/5/14.
//
//

#import "PBListControlItem.h"
#import "PBListViewController.h"
#import "PBSectionItem.h"

@interface PBListControlItem() {

    BOOL _markFirstResponder;
}

@end

@implementation PBListControlItem

- (id)init {

    self = [super init];
    if (self) {
        [self setupBindingBlock];
        self.reloadItemOnValueChange = YES;
    }
    return self;
}

- (void)setupBindingBlock {

    __weak typeof(self) this = self;

    self.bindingBlock = ^(PBListViewController *listViewController, NSIndexPath *indexPath, PBListItem *item, PBListViewDefaultCell *cell) {
        this.listViewController = listViewController;
    };
}

#pragma mark - Getters and Setters

- (void)setItemValue:(id)value {
    _itemValue = value;

    if (self.reloadItemOnValueChange) {
        [self.listViewController
         reloadTableRowAtIndexPath:self.indexPath
         withAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)setControl:(UIControl *)control {

    _control = control;

    if (_markFirstResponder) {
        [self.control becomeFirstResponder];
        _markFirstResponder = NO;
    }
}

- (void)setExpanded:(BOOL)expanded {

    BOOL changed = self.isExpanded != expanded;

    if (changed) {

        if (expanded) {
            [self becomeFirstResponder];
        } else {
            [self resignFirstResponder];
        }

        [self.listViewController
         reloadTableRowAtIndexPath:self.indexPath
         withAnimation:UITableViewRowAnimationAutomatic];
    }

    [super setExpanded:expanded];
}

#pragma mark -

- (void)resignFirstResponder {
    [self.control resignFirstResponder];
}

- (void)becomeFirstResponder {

    if (self.control != nil) {
        [self.control becomeFirstResponder];

    } else {
        _markFirstResponder = YES;
    }

    for (PBSectionItem *sectionItem in self.listViewController.dataSource) {

        for (PBListControlItem *item in sectionItem.items) {

            if (item != self && [item isKindOfClass:[PBListControlItem class]]) {
                [item resignFirstResponder];
            }
        }
    }
}

- (void)valueChanged:(UIControl *)control {

    if (self.valueUpdatedBlock != nil) {
        self.valueUpdatedBlock(self, self.itemValue);
    }
}

- (void)controlDidBeginEditing:(UIControl *)control {

    if (self.editingDidBegin != nil) {
        self.editingDidBegin(self);
    }
}

- (void)controlDidEndEditing:(UIControl *)control {
    _markFirstResponder = NO;
}

@end
