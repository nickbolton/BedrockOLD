//
//  PBListViewControllerItem.h
//  Bedrock
//
//  Created by Nick Bolton on 1/6/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBListItem.h"

@protocol PBListViewControllerItemProtocol <NSObject>

@optional
- (CGFloat)listViewItemHeight;
- (void)setListViewItemHeight:(CGFloat)height;

@end

@interface PBListViewControllerItem : PBListItem

@property (nonatomic, readonly) UIViewController <PBListViewControllerItemProtocol> *contentViewController;

+ (instancetype)itemWithViewController:(UIViewController <PBListViewControllerItemProtocol> *)viewController
                                cellID:(NSString *)cellID;

@end
