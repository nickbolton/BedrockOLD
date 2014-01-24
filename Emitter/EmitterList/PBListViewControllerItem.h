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
@property (nonatomic) CGFloat listViewItemHeight;

@end

@interface PBListViewControllerItem : PBListItem

@property (nonatomic, readonly) UIViewController <PBListViewControllerItemProtocol> *contentViewController;

+ (instancetype)itemWithViewController:(UIViewController <PBListViewControllerItemProtocol> *)viewController
                                cellID:(NSString *)cellID;

@end
