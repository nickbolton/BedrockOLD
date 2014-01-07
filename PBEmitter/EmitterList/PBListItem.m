//
//  PBListItem.m
//  Sometime
//
//  Created by Nick Bolton on 12/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListItem.h"

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

    return item;
}

+ (instancetype)selectionItemWithTitle:(NSString *)title
                                 value:(NSString *)value
                              itemType:(PBItemType)itemType
                         hasDisclosure:(BOOL)hasDisclosure
                          selectAction:(void(^)(id cell))selectActionBlock
                          deleteAction:(void(^)(id cell))deleteActionBlock {

    PBListItem *selectionItem =
    [[PBListItem alloc] init];

    [selectionItem commonInit];

    selectionItem.title = title;
    selectionItem.value = value;
    selectionItem.itemType = itemType;
    selectionItem.hasDisclosure = hasDisclosure;
    selectionItem.selectActionBlock = selectActionBlock;
    selectionItem.deleteActionBlock = deleteActionBlock;
    selectionItem.selectionStyle = itemType == PBItemTypeChecked ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleGray;
    selectionItem.titleAlignment = NSTextAlignmentLeft;

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
    selectionItem.itemType = PBItemTypeSelectAll;
    selectionItem.deselectable = NO;
    selectionItem.hasDisclosure = NO;
    selectionItem.selectActionBlock = selectActionBlock;
    selectionItem.deleteActionBlock = deleteActionBlock;
    selectionItem.titleAlignment = NSTextAlignmentLeft;

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

    return selectionItem;
}

- (void)commonInit {

    self.rowHeight = -1.0f;
    self.deselectable = YES;
    self.titleMargin = 20.0f;
    self.valueMargin = 20.0f;
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

@end
