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

#pragma mark -

- (void)resignFirstResponder {
    [super resignFirstResponder];
    [self.control resignFirstResponder];
}

- (void)becomeFirstResponder {
    [super becomeFirstResponder];

    if (self.control != nil) {
        [self.control becomeFirstResponder];

    } else {
        _markFirstResponder = YES;
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

    [super becomeFirstResponder];
}

- (void)controlDidEndEditing:(UIControl *)control {
    _markFirstResponder = NO;
}

@end
