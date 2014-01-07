//
//  PBListViewDefaultCell.h
//  Pods
//
//  Created by Nick Bolton on 12/9/13.
//
//

#import <UIKit/UIKit.h>

@class PBListItem;
@class PBListViewController;

@interface PBListViewDefaultCell : UITableViewCell

@property (nonatomic, strong) PBListItem *item;
@property (nonatomic, weak) PBListViewController *viewController;
@property (nonatomic) BOOL cellConfigured;

- (void)updateForSelectedState;

@end
