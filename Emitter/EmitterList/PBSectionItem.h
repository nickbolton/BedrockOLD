//
//  PBSectionItem.h
//  Bedrock
//
//  Created by Nick Bolton on 1/7/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBSectionItem : NSObject

@property (nonatomic, readonly) NSString *headerTitle;
@property (nonatomic, readonly) NSString *footerTitle;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic) CGFloat headerHeight;
@property (nonatomic) CGFloat footerHeight;

+ (PBSectionItem *)sectionItemWithHeaderTitle:(NSString *)headerTitle
                                  footerTitle:(NSString *)footerTitle
                                        items:(NSArray *)items;

+ (PBSectionItem *)sectionItemWithItems:(NSArray *)items;

- (void)addItems:(NSArray *)items;
- (void)removeItems:(NSArray *)items;
- (void)insertItem:(id)item atIndex:(NSInteger)index;
- (void)removeItemAtIndex:(NSInteger)index;
- (void)replaceItem:(id)oldItem withItem:(id)item;

@end
