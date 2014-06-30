//
//  PBCollectionItem.m
//  Bedrock
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBCollectionItem.h"
#import "PBCollectionViewController.h"

@implementation PBCollectionItem

+ (instancetype)
customClassItemWithUserContext:(id)userContext
reuseIdentifier:(NSString *)reuseIdentifier
cellClass:(Class)cellClass
configure:(void(^)(PBCollectionViewController *viewController, PBCollectionItem *item, id cell))configureBlock
binding:(void(^)(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, id cell))bindingBlock
selectAction:(void(^)(id cell, BOOL selected))selectActionBlock {

    PBCollectionItem *item =
    [[PBCollectionItem alloc]
     initWithUserContext:userContext
     reuseIdentifier:reuseIdentifier
     cellClass:cellClass
     configure:configureBlock
     binding:bindingBlock
     selectAction:selectActionBlock];

    return item;
}

+ (instancetype)
customNibItemWithUserContext:(id)userContext
reuseIdentifier:(NSString *)reuseIdentifier
cellNib:(UINib *)cellNib
configure:(void(^)(PBCollectionViewController *viewController, PBCollectionItem *item, id cell))configureBlock
binding:(void(^)(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, id cell))bindingBlock
selectAction:(void(^)(id cell, BOOL selected))selectActionBlock {

    PBCollectionItem *item =
    [[PBCollectionItem alloc]
     initWithUserContext:userContext
     reuseIdentifier:reuseIdentifier
     cellNib:cellNib
     configure:configureBlock
     binding:bindingBlock
     selectAction:selectActionBlock];

    return item;
}

- (id)
initWithUserContext:(id)userContext
reuseIdentifier:(NSString *)reuseIdentifier
cellClass:(Class)cellClass
configure:(void(^)(PBCollectionViewController *viewController, PBCollectionItem *item, id cell))configureBlock
binding:(void(^)(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, id cell))bindingBlock
selectAction:(void(^)(id cell, BOOL selected))selectActionBlock {

    self = [super init];
    if (self) {

        self.userContext = userContext;
        self.reuseIdentifier = reuseIdentifier;
        self.cellClass = cellClass;
        self.configureBlock = configureBlock;
        self.bindingBlock = bindingBlock;
        self.selectActionBlock = selectActionBlock;

        [self commonInit];
    }
    return self;
}

- (id)
initWithUserContext:(id)userContext
reuseIdentifier:(NSString *)reuseIdentifier
cellNib:(UINib *)cellNib
configure:(void(^)(PBCollectionViewController *viewController, PBCollectionItem *item, id cell))configureBlock
binding:(void(^)(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, id cell))bindingBlock
selectAction:(void(^)(id cell, BOOL selected))selectActionBlock {

    self = [super init];
    if (self) {

        self.userContext = userContext;
        self.reuseIdentifier = reuseIdentifier;
        self.cellNib = cellNib;
        self.configureBlock = configureBlock;
        self.bindingBlock = bindingBlock;
        self.selectActionBlock = selectActionBlock;

        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.kind = kPBCollectionViewCellKind;
    self.deselectable = YES;
    self.useBackgroundImageSize = YES;
    self.point = CGPointZero;
    self.center = CGPointZero;
    self.size = CGSizeZero;
    self.transform3D = CATransform3DIdentity;
    self.transform = CGAffineTransformIdentity;
    self.alpha = 1.0f;
    self.zIndex = 0;
    self.hidden = NO;
}

- (void)setSelectAllItem:(BOOL)selectAllItem {
    _selectAllItem = selectAllItem;
    self.deselectable = NO;
}

@end
