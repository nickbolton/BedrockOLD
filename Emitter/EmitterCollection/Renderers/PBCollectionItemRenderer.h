//
//  PBCollectionItemRenderer.h
//  Pods
//
//  Created by Nick Bolton on 2/7/14.
//
//

#import <Foundation/Foundation.h>

@protocol PBCollectionItemRenderer <NSObject>

- (void)renderItem:(PBCollectionViewController *)collectionViewController
         indexPath:(NSIndexPath *)indexPath
              item:(PBItem *)item
              cell:(UITableViewCell *) cell;

@end
