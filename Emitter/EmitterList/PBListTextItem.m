//
//  PBListTextItem.m
//  Pods
//
//  Created by Nick Bolton on 3/3/14.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListTextItem.h"
#import "PBListViewDefaultCell.h"
#import "PBListTextRenderer.h"
#import "PBListViewController.h"

@interface PBListTextItem() {
}

@end

@implementation PBListTextItem

+ (PBListTextItem *)textItemWithText:(NSString *)text
                           textColor:(UIColor *)textColor
                                font:(UIFont *)font
                         placeholder:(NSString *)placeholder
                        valueUpdated:(void(^)(PBListControlItem *item, NSString *updatedText))valueUpdatedBlock {

    PBListTextItem *item = [[PBListTextItem alloc] init];

    [item commonInit];
    item.text = text;
    item.placeholder = placeholder;
    item.textColor = textColor;
    item.font = font;
    item.keyboardType = UIKeyboardTypeDefault;
    item.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    item.itemType = PBItemTypeCustom;
    item.cellID = NSStringFromClass([self class]);
    item.cellClass = [PBListViewDefaultCell class];
    item.valueUpdatedBlock = valueUpdatedBlock;

    return item;
}

#pragma mark - Public

- (void)valueChanged:(UITextField *)textField {

    if (textField.text.trimmedValue.length > 0) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
    } else {
        textField.clearButtonMode = UITextFieldViewModeNever;
    }

    BOOL reloadItemOnValueChange = self.reloadItemOnValueChange;
    self.reloadItemOnValueChange = NO;
    self.text = textField.text;
    self.reloadItemOnValueChange = reloadItemOnValueChange;

    [super valueChanged:textField];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    if (textField.text.trimmedValue.length > 0) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
    } else {
        textField.clearButtonMode = UITextFieldViewModeNever;
    }

    [super controlDidBeginEditing:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.clearButtonMode = UITextFieldViewModeNever;
    [super controlDidEndEditing:textField];
}

#pragma mark - Getters and Setters

- (void)setTextField:(UITextField *)textField {
    self.control = textField;
}

- (NSString *)text {
    return self.itemValue;
}

- (void)setText:(NSString *)text {
    self.itemValue = text;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;

    [self.listViewController
     reloadTableRowAtIndexPath:self.indexPath
     withAnimation:UITableViewRowAnimationAutomatic];
}

@end
