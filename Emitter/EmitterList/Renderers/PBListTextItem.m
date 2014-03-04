//
//  PBListTextItem.m
//  Pods
//
//  Created by Nick Bolton on 3/3/14.
//
//

#import "PBListTextItem.h"
#import "PBListViewDefaultCell.h"
#import "PBListTextRenderer.h"
#import "PBListViewController.h"

@interface PBListTextItem()

@property (nonatomic, copy) void(^textUpdatedBlock)(PBListTextItem *item, NSString *updatedText);
@property (nonatomic, weak) PBListViewController *listViewController;
@property (nonatomic, weak) UITextField *textField;

@end

@implementation PBListTextItem

+ (PBListTextItem *)textItemWithText:(NSString *)text
                           textColor:(UIColor *)textColor
                                font:(UIFont *)font
                         placeholder:(NSString *)placeholder
                         textUpdated:(void(^)(PBListTextItem *item, NSString *updatedText))textUpdatedBlock {

    PBListTextItem *item = [[PBListTextItem alloc] init];

    [item commonInit];
    item.text = text;
    item.placeholder = placeholder;
    item.textColor = textColor;
    item.font = font;
    item.itemType = PBItemTypeCustom;
    item.cellID = NSStringFromClass([self class]);
    item.cellClass = [PBListViewDefaultCell class];
    item.textUpdatedBlock = textUpdatedBlock;

    [item setupBindingBlock];

    return item;
}

- (void)setupBindingBlock {

    __weak typeof(self) this = self;

    self.bindingBlock = ^(PBListViewController *listViewController, NSIndexPath *indexPath, PBListItem *item, PBListViewDefaultCell *cell) {
        this.listViewController = listViewController;
    };
}

#pragma mark - Public

- (void)resignFirstResponder {
    [self.textField resignFirstResponder];
}

- (void)textChanged:(UITextField *)textField {

    if (textField.text.trimmedValue.length > 0) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
    } else {
        textField.clearButtonMode = UITextFieldViewModeNever;
    }

    if (self.textUpdatedBlock != nil) {
        self.textUpdatedBlock(self, textField.text);
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    self.textField = textField;

    if (textField.text.trimmedValue.length > 0) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
    } else {
        textField.clearButtonMode = UITextFieldViewModeNever;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.textField = nil;
    textField.clearButtonMode = UITextFieldViewModeNever;
}

#pragma mark - Getters and Setters

- (void)setText:(NSString *)text {
    _text = text;

    [self.listViewController
     reloadTableRowAtIndexPath:self.indexPath
     withAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;

    [self.listViewController
     reloadTableRowAtIndexPath:self.indexPath
     withAnimation:UITableViewRowAnimationAutomatic];
}

@end
