//
//  PBCollectionLayout.h
//  Bedrock
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBCollectionViewController;
@class PBCollectionItem;

@interface PBCollectionLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) PBCollectionViewController *viewController;

@property (nonatomic) CGSize minContentSize;
@property (nonatomic, getter = isDebugging) BOOL debugging;

- (void)configureAttributes:(UICollectionViewLayoutAttributes *)itemAttributes
                   withItem:(PBCollectionItem *)item
                atIndexPath:(NSIndexPath *)indexPath;

@end
