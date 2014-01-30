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

@end
