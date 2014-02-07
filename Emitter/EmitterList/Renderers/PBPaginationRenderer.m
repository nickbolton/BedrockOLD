//
//  PBPaginationRenderer.m
//  Pods
//
//  Created by Nick Bolton on 2/7/14.
//
//

#import "PBPaginationRenderer.h"
#import "PBListViewController.h"
#import "PBSectionItem.h"
#import "PBListItem.h"
#import "PBListViewController_Private.h"

@interface PBPaginationRenderer()

@property (nonatomic, copy) BOOL(^triggerCallback)(void);
@property (nonatomic, strong) PBListItem *footerItem;
@property (nonatomic) NSInteger endDistance;
@property (nonatomic) NSInteger section;
@property (nonatomic) NSInteger footerHeight;
@property (nonatomic) Class footerViewClass;
@property (nonatomic, strong) NSIndexPath *lastIndexPathUsedForPaginationCallback;
@property (nonatomic, weak) PBListViewController *listViewController;

@end

@implementation PBPaginationRenderer

- (id)initWithTriggerCallback:(BOOL(^)(void))callback
            atDistanceFromEnd:(NSInteger)distance
                    inSection:(NSInteger)section
          footerViewCellClass:(Class)footerViewClass
                 footerHeight:(CGFloat)footerHeight {

    self = [super init];

    if (self != nil) {
        self.triggerCallback = callback;
        self.endDistance = distance;
        self.section = section;
        self.footerHeight = footerHeight;
        self.footerViewClass = footerViewClass;
    }

    return self;
}

- (void)renderItem:(PBListItem *)item
       atIndexPath:(NSIndexPath *)indexPath
            inCell:(UITableViewCell *)cell
      withListView:(PBListViewController *)listViewController {

    if (indexPath.section == self.section &&
        self.triggerCallback != nil &&
        indexPath.row > self.lastIndexPathUsedForPaginationCallback.row) {

        self.listViewController = listViewController;

        PBSectionItem *sectionItem = item.sectionItem;

        NSInteger triggerThreshold =
        sectionItem.items.count - 1 - self.endDistance;

        if (sectionItem != nil && indexPath.row >= triggerThreshold) {

            NSIndexPath *lastIndexPath =
            [NSIndexPath
             indexPathForRow:sectionItem.items.count
             inSection:indexPath.section];

            self.lastIndexPathUsedForPaginationCallback = lastIndexPath;

            if (self.triggerCallback()) {

                [self configureFooterItemIfNecessary];

                __weak typeof(self) this = self;

                dispatch_async(dispatch_get_main_queue(), ^{
                    [this.listViewController
                     appendItemsToDataSource:@[this.footerItem]
                     inSection:this.section];
                });
            }
        }
    }
}

- (void)configureFooterItemIfNecessary {

    static NSString * const paginationFooterID = @"pagination-footer";

    if (self.footerItem == nil) {

        self.footerItem =
        [PBListItem
         customClassItemWithUserContext:nil
         cellID:paginationFooterID
         cellClass:self.footerViewClass
         configure:nil
         binding:nil
         selectAction:nil
         deleteAction:nil];

        [self.listViewController.tableView
         registerClass:self.footerViewClass
         forCellReuseIdentifier:paginationFooterID];

        self.footerItem.rowHeight = self.footerHeight;
    }
}

- (void)appendPageItems:(NSArray *)items {

    if (self.footerItem != nil) {

        [self.listViewController.tableView beginUpdates];

        if ([self.listViewController removeItemAtIndexPath:self.footerItem.indexPath]) {

            [self.listViewController.tableView
             deleteRowsAtIndexPaths:@[self.footerItem.indexPath]
             withRowAnimation:UITableViewRowAnimationBottom];
        }

        [self.listViewController doAppendItems:items toSection:self.section];

        [self.listViewController.tableView endUpdates];
    }
}

@end
