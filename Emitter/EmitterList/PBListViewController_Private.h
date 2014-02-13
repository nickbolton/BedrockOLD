//
//  PBListViewController_Private.h
//  Pods
//
//  Created by Nick Bolton on 2/7/14.
//
//

#import "PBListViewController.h"

@interface PBListViewController (Private)

- (PBSectionItem *)sectionItemAtSection:(NSInteger)section;
- (PBListItem *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (void)doAppendItems:(NSArray *)addedItems toSection:(NSInteger)section;

@end
