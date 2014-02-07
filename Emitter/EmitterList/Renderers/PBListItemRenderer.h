//
//  PBListItemRenderer.h
//  Pods
//
//  Created by Nick Bolton on 2/7/14.
//
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

@end
