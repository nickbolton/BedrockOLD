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

@property (nonatomic, copy) void(^textUpdatedBlock)(NSString *updatedText);
@property (nonatomic, weak) PBListViewController *listViewController;

@end

@implementation PBListTextItem

+ (PBListTextItem *)textItemWithText:(NSString *)text
                           textColor:(UIColor *)textColor
                                font:(UIFont *)font
                         placeholder:(NSString *)placeholder
                         textUpdated:(void(^)(NSString *updatedText))textUpdatedBlock {

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

- (void)textChanged:(UITextField *)textField {

    if (self.textUpdatedBlock != nil) {
        self.textUpdatedBlock(textField.text);
    }
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
