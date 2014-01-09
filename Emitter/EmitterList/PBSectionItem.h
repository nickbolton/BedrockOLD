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
@property (nonatomic, strong) UIFont *headerFont;
@property (nonatomic, strong) UIFont *footerFont;
@property (nonatomic, strong) UIColor *headerTextColor;
@property (nonatomic, strong) UIColor *footerTextColor;
@property (nonatomic) NSTextAlignment headerTextAlignment;
@property (nonatomic) NSTextAlignment footerTextAlignment;
@property (nonatomic) CGFloat headerHeightPadding;
@property (nonatomic) CGFloat footerHeightPadding;
@property (nonatomic, strong) NSString *headerViewReuseIdentifier;
@property (nonatomic, strong) NSString *footerViewReuseIdentifier;
@property (nonatomic) CGFloat headerTextMargin;
@property (nonatomic) CGFloat footerTextMargin;

+ (PBSectionItem *)sectionItemWithHeaderTitle:(NSString *)headerTitle
                                  footerTitle:(NSString *)footerTitle
                                        items:(NSArray *)items;

@end
