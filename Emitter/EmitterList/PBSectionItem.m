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
        self.items = items;
    }
    return self;
}

- (void)addItems:(NSArray *)items {

    NSMutableArray *updatedItems = [self.items mutableCopy];
    [updatedItems addObjectsFromArray:items];

    self.items = updatedItems;
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
