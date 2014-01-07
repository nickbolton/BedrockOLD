//
//  PBListViewControllerItem.h
//  PBEmitterViewControllerListExample
//
//  Created by Nick Bolton on 1/6/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBListItem.h"

@protocol PBListViewControllerItemProtocol <NSObject>

@optional
- (CGFloat)listViewItemHeight;
- (void)setListViewItemHeight;

@end

@interface PBListViewControllerItem : PBListItem

@property (nonatomic, readonly) UIViewController <PBListViewControllerItemProtocol> *viewController;

+ (instancetype)customNibItemWithViewController:(UIViewController <PBListViewControllerItemProtocol> *)viewController
                                         cellID:(NSString *)cellID
                                        cellNib:(UINib *)cellNib;

+ (instancetype)customClassItemWithViewController:(UIViewController <PBListViewControllerItemProtocol> *)viewController
                                           cellID:(NSString *)cellID
                                        cellClass:(Class)cellClass;

@end
