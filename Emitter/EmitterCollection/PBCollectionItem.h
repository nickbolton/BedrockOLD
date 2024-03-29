//
//  PBCollectionItem.h
//  Bedrock
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBCollectionViewController;
@class PBSectionItem;

@interface PBCollectionItem : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *selectedBackgroundImage;
@property (nonatomic, strong) UIImage *hightlightedBackgroundImage;
@property (nonatomic, strong) UIImage *highlightedSelectedBackgroundImage;
@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, strong) UINib *cellNib;
@property (nonatomic) Class cellClass;
@property (nonatomic,  strong) NSString *kind;
@property (nonatomic, strong) id userContext;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic) UICollectionViewScrollPosition scrollPosition;
@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic) BOOL selectionDisabled;
@property (nonatomic) BOOL itemConfigured;
@property (nonatomic) BOOL selectAllItem;
@property (nonatomic) BOOL useCenter;
@property (nonatomic) BOOL useBackgroundImageSize;
@property (nonatomic) CGSize contentSizeOffset;
@property (nonatomic, strong) PBCollectionItem *supplimentaryItem;
@property (nonatomic, strong) PBCollectionItem *decorationItem;
@property (nonatomic, getter = isDeselectable) BOOL deselectable;
@property (nonatomic, copy) void(^selectActionBlock)(id cell, BOOL selected);
@property (nonatomic, copy) void(^configureBlock)(id sender, PBCollectionItem *item, id cell);
@property (nonatomic, copy) void(^bindingBlock)(id sender, NSIndexPath *indexPath, PBCollectionItem *item, id cell);
@property (nonatomic, weak) PBSectionItem *sectionItem;

// properties passed directly to UICollectionViewLayoutAttributes

@property (nonatomic) CGPoint point;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGSize size;
@property (nonatomic) CATransform3D transform3D;
@property (nonatomic) CGAffineTransform transform;
@property (nonatomic) CGFloat alpha;
@property (nonatomic) NSInteger zIndex;
@property (nonatomic, getter=isHidden) BOOL hidden;

+ (instancetype)
customNibItemWithUserContext:(id)userContext
reuseIdentifier:(NSString *)reuseIdentifier
cellNib:(UINib *)cellNib
configure:(void(^)(PBCollectionViewController *viewController, PBCollectionItem *item, id cell))configureBlock
binding:(void(^)(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, id cell))bindingBlock
selectAction:(void(^)(id cell, BOOL selected))selectActionBlock;

+ (instancetype)
customClassItemWithUserContext:(id)userContext
reuseIdentifier:(NSString *)reuseIdentifier
cellClass:(Class)cellClass
configure:(void(^)(PBCollectionViewController *viewController, PBCollectionItem *item, id cell))configureBlock
binding:(void(^)(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, id cell))bindingBlock
selectAction:(void(^)(id cell, BOOL selected))selectActionBlock;

- (id)
initWithUserContext:(id)userContext
reuseIdentifier:(NSString *)reuseIdentifier
cellNib:(UINib *)cellNib
configure:(void(^)(PBCollectionViewController *viewController, PBCollectionItem *item, id cell))configureBlock
binding:(void(^)(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, id cell))bindingBlock
selectAction:(void(^)(id cell, BOOL selected))selectActionBlock;

- (id)
initWithUserContext:(id)userContext
reuseIdentifier:(NSString *)reuseIdentifier
cellClass:(Class)cellClass
configure:(void(^)(PBCollectionViewController *viewController, PBCollectionItem *item, id cell))configureBlock
binding:(void(^)(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, id cell))bindingBlock
selectAction:(void(^)(id cell, BOOL selected))selectActionBlock;

@end
