//
//  PBCollectionItemRenderer.h
//  Pods
//
//  Created by Nick Bolton on 2/7/14.
//
//

#import <Foundation/Foundation.h>

@protocol PBCollectionItemRenderer <NSObject>

- (void)renderItem:(PBCollectionItem *)item
       atIndexPath:(NSIndexPath *)indexPath
            inCell:(UICollectionViewCell *)cell
withCollectionView:(PBCollectionViewController *)collectionViewController;

@end
