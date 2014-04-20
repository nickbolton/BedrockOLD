//
//  PBListItem.m
//  Sometime
//
//  Created by Nick Bolton on 12/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListItem.h"
#import "PBListViewController.h"
#import "PBSectionItem.h"

CGFloat const kPBListRowHeight = 44.0f;
CGFloat const kPBListSpacerRowHeight = 32.0f;
CGFloat const kPBListActionRowHeight = 44.0f;

@implementation PBListItem

+ (instancetype)spacerItemWithHeight:(CGFloat)height {

    PBListItem *item =
    [self
     selectionItemWithTitle:nil
     value:nil
     itemType:PBItemTypeSpacer
     hasDisclosure:NO
     selectAction:nil
     deleteAction:nil];

    item.backgroundColor = [UIColor clearColor];
    item.rowHeight = height;
    item.selectionStyle = UITableViewCellSelectionStyleNone;
    item.highlightedAlpha = 1.0f;

    return item;
}

+ (instancetype)titleItemWithTitle:(NSString *)title height:(CGFloat)height {

    PBListItem *item =
    [self
     selectionItemWithTitle:title
     value:nil
     itemType:PBItemTypeTitle
     hasDisclosure:NO
     selectAction:nil
     deleteAction:nil];

    item.titleAlignment = NSTextAlignmentCenter;
    item.backgroundColor = [UIColor clearColor];
    item.rowHeight = height;
    item.selectionStyle = UITableViewCellSelectionStyleNone;
    item.highlightedAlpha = 1.0f;

    [item setDefaultParagraphStyle];

    return item;
}

+ (instancetype)selectionItemWithTitle:(NSString *)title
                                 value:(NSString *)value
                              itemType:(PBItemType)itemType
                         hasDisclosure:(BOOL)hasDisclosure
                          selectAction:(void(^)(id cell))selectActionBlock
                          deleteAction:(void(^)(id cell))deleteActionBlock {
    return
    [self
     selectionItemWithTitle:title
     value:value
     itemType:itemType
     checkedType:PBItemCheckedTypeNone
     hasDisclosure:hasDisclosure
     selectAction:selectActionBlock
     deleteAction:deleteActionBlock];
}

+ (instancetype)selectionItemWithTitle:(NSString *)title
                                 value:(NSString *)value
                              itemType:(PBItemType)itemType
                           checkedType:(PBItemCheckedType)checkedType
                         hasDisclosure:(BOOL)hasDisclosure
                          selectAction:(void(^)(id cell))selectActionBlock
                          deleteAction:(void(^)(id cell))deleteActionBlock {

    PBListItem *selectionItem =
    [[PBListItem alloc] init];

    [selectionItem commonInit];

    BOOL isCheckedType =
    checkedType == PBItemCheckedTypeSingle ||
    checkedType == PBItemCheckedTypeAll;

    selectionItem.title = title;
    selectionItem.value = value;
    selectionItem.itemType = itemType;
    selectionItem.checkedType = checkedType;
    selectionItem.hasDisclosure = hasDisclosure;
    selectionItem.selectActionBlock = selectActionBlock;
    selectionItem.deleteActionBlock = deleteActionBlock;
    selectionItem.selectionStyle = isCheckedType ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleGray;
    selectionItem.titleAlignment = NSTextAlignmentLeft;

    [selectionItem setDefaultParagraphStyle];

    return selectionItem;
}

+ (instancetype)selectAllItemWithTitle:(NSString *)title
                          selectAction:(void(^)(id cell))selectActionBlock
                          deleteAction:(void(^)(id cell))deleteActionBlock {

    PBListItem *selectionItem =
    [[PBListItem alloc] init];

    [selectionItem commonInit];

    selectionItem.title = title;
    selectionItem.value = nil;
    selectionItem.itemType = PBItemTypeDefault;
    selectionItem.checkedType = PBItemCheckedTypeAll;
    selectionItem.deselectable = NO;
    selectionItem.hasDisclosure = NO;
    selectionItem.selectActionBlock = selectActionBlock;
    selectionItem.deleteActionBlock = deleteActionBlock;
    selectionItem.titleAlignment = NSTextAlignmentLeft;

    [selectionItem setDefaultParagraphStyle];

    return selectionItem;
}

+ (instancetype)customNibItemWithUserContext:(id)userContext
                                      cellID:(NSString *)cellID
                                     cellNib:(UINib *)cellNib
                                   configure:(void(^)(id viewController, PBListItem *item, id cell))configureBlock
                                     binding:(void(^)(id viewController, NSIndexPath *indexPath, PBListItem *item, id cell))bindingBlock
                                selectAction:(void(^)(id cell))selectActionBlock
                                deleteAction:(void(^)(id cell))deleteActionBlock {

    PBListItem *selectionItem =
    [[PBListItem alloc] init];

    [selectionItem commonInit];

    selectionItem.itemType = PBItemTypeCustom;
    selectionItem.userContext = userContext;
    selectionItem.cellID = cellID;
    selectionItem.cellNib = cellNib;
    selectionItem.configureBlock = configureBlock;
    selectionItem.bindingBlock = bindingBlock;
    selectionItem.selectActionBlock = selectActionBlock;
    selectionItem.deleteActionBlock = deleteActionBlock;

    [selectionItem setDefaultParagraphStyle];

    return selectionItem;
}

+ (instancetype)customClassItemWithUserContext:(id)userContext
                                        cellID:(NSString *)cellID
                                     cellClass:(Class)cellClass
                                     configure:(void(^)(id viewController, PBListItem *item, id cell))configureBlock
                                       binding:(void(^)(id viewController, NSIndexPath *indexPath, PBListItem *item, id cell))bindingBlock
                                  selectAction:(void(^)(id cell))selectActionBlock
                                  deleteAction:(void(^)(id cell))deleteActionBlock {

    PBListItem *selectionItem =
    [[PBListItem alloc] init];

    [selectionItem commonInit];
    selectionItem.itemType = PBItemTypeCustom;
    selectionItem.userContext = userContext;
    selectionItem.cellID = cellID;
    selectionItem.cellClass = cellClass;
    selectionItem.configureBlock = configureBlock;
    selectionItem.bindingBlock = bindingBlock;
    selectionItem.selectActionBlock = selectActionBlock;
    selectionItem.deleteActionBlock = deleteActionBlock;

    [selectionItem setDefaultParagraphStyle];

    return selectionItem;
}

- (void)setDefaultParagraphStyle {

    NSMutableParagraphStyle *paragraphStyle =
    [[NSMutableParagraphStyle alloc] init];

    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = self.titleAlignment;

    self.titleParagraphStyle = paragraphStyle;
}

- (void)commonInit {

    self.rowHeight = -1.0f;
    self.deselectable = YES;
    self.titleMargin = 20.0f;
    self.valueMargin = 20.0f;
    self.highlightedAlpha = 1.0f;
    self.highlightedContentAlpha = 1.0f;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (BOOL)isDeletable {
    return self.deleteActionBlock != nil;
}

- (CGFloat)rowHeight {

    if (_rowHeight > 0) {
        return _rowHeight;
    }

    CGFloat rowHeight = kPBListRowHeight;

    switch (self.itemType) {
        case PBItemTypeAction:

            rowHeight = kPBListActionRowHeight;
            break;

            case PBItemTypeSpacer:
            rowHeight = kPBListSpacerRowHeight;

        default:
            rowHeight = kPBListRowHeight;
            break;
    }

    return rowHeight;
}

- (void)resignFirstResponder {
}

- (void)becomeFirstResponder {

    for (PBSectionItem *sectionItem in self.listViewController.dataSource) {

        for (PBListItem *item in sectionItem.items) {

            if (item != self) {
                [item resignFirstResponder];
            }
        }
    }

    SEL selector = @selector(resignFirstResponder);

    if ([self.listViewController.firstResponder respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.listViewController.firstResponder performSelector:selector];
#pragma clang diagnostic pop
    }

    self.listViewController.firstResponder = nil;
}

@end
