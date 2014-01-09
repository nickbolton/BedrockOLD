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
@property (nonatomic, readwrite) NSArray *items;

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

- (id)initWithHeaderTitle:(NSString *)headerTitle
              footerTitle:(NSString *)footerTitle
              items:(NSArray *)items {
    
    self = [super init];
    if (self) {
        self.headerTitle = headerTitle;
        self.footerTitle = footerTitle;
        self.items = items;
        self.headerViewReuseIdentifier = @"table-view-section-header";
        self.footerViewReuseIdentifier = @"table-view-section-footer";
        self.headerHeightPadding = 27.0f;
        self.footerHeightPadding = 0.0f;
        self.footerFont = [UIFont systemFontOfSize:11.0f];
    }
    return self;
}

@end
