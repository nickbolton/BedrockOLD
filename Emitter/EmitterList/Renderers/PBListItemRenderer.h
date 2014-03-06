//
//  PBListItemRenderer.h
//  Pods
//
//  Created by Nick Bolton on 2/7/14.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBListViewController;
@class PBListItem;
@class PBSectionItem;

@protocol PBListItemRenderer <NSObject>

- (void)renderItem:(PBListItem *)item
       atIndexPath:(NSIndexPath *)indexPath
            inCell:(UITableViewCell *)cell
      withListView:(PBListViewController *)listViewController;

@optional
- (void)didEndRendering:(PBListItem *)item
            atIndexPath:(NSIndexPath *)indexPath
                 inCell:(UITableViewCell *)cell
           withListView:(PBListViewController *)listViewController;

@end
