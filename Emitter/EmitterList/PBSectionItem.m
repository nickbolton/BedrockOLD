//
//  PBSectionItem.m
//  Bedrock
//
//  Created by Nick Bolton on 1/7/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBSectionItem.h"

@interface PBSectionItem()

@property (nonatomic, readwrite) NSString *headerTitle;
@property (nonatomic, readwrite) NSString *footerTitle;

@end

@implementation PBSectionItem

+ (PBSectionItem *)sectionItemWithHeaderTitle:(NSString *)headerTitle
                                  footerTitle:(NSString *)footerTitle
                                        items:(NSArray *)items {
    return
    [[PBSectionItem alloc]
     initWithHeaderTitle:headerTitle
     footerTitle:footerTitle
     items:items];
}

+ (PBSectionItem *)sectionItemWithItems:(NSArray *)items {

    return
    [[PBSectionItem alloc]
     initWithHeaderTitle:nil
     footerTitle:nil
     items:items];
}

- (id)initWithHeaderTitle:(NSString *)headerTitle
              footerTitle:(NSString *)footerTitle
              items:(NSArray *)items {
    
    self = [super init];
    if (self) {
        self.headerTitle = headerTitle;
        self.footerTitle = footerTitle;
        self.items = items != nil ? items : @[];
    }
    return self;
}

- (void)addItems:(NSArray *)items {

    NSMutableArray *updatedItems = [self.items mutableCopy];
    [updatedItems addObjectsFromArray:items];

    self.items = updatedItems;
}

- (void)insertItem:(id)item atIndex:(NSInteger)index {
    
    NSMutableArray *items = [self.items mutableCopy];
    if (index < items.count) {
        [items insertObject:item atIndex:index];
    } else {
        [items addObject:item];
    }
    self.items = items;    
}

- (void)removeItemAtIndex:(NSInteger)index {
    
    NSMutableArray *items = [self.items mutableCopy];
    if (index < items.count) {
        [items removeObjectAtIndex:index];
    }
    self.items = items;
}

- (void)replaceWithItem:(id)item atIndex:(NSInteger)index {
    
    if (self.items.count > index) {
        
        NSMutableArray *items = [self.items mutableCopy];
        [items replaceObjectAtIndex:index withObject:item];
        self.items = items;
    }
}

- (void)replaceItem:(id)oldItem withItem:(id)item {

    NSInteger pos = [self.items indexOfObject:oldItem];

    if (pos != NSNotFound) {

        NSMutableArray *items = [self.items mutableCopy];
        [items replaceObjectAtIndex:pos withObject:item];
        self.items = items;
    }
}

- (void)removeItems:(NSArray *)items {

    NSMutableArray *updatedItems = [self.items mutableCopy];
    [updatedItems removeObjectsInArray:items];
    self.items = updatedItems;
}

@end
