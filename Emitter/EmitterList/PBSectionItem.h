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
@property (nonatomic, readonly) NSArray *items;

+ (PBSectionItem *)sectionItemWithHeaderTitle:(NSString *)headerTitle
                                  footerTitle:(NSString *)footerTitle
                                        items:(NSArray *)items;

@end
