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
@property (nonatomic, strong) PBListItem *indicatorItem;
@property (nonatomic) NSInteger endDistance;
@property (nonatomic) NSInteger section;
@property (nonatomic) NSInteger indicatorCellHeight;
@property (nonatomic) Class indicatorCellClass;
@property (nonatomic) NSMutableArray *indexPathTriggerStack;
@property (nonatomic, weak) PBListViewController *listViewController;
@property (nonatomic, readonly) NSIndexPath *lastIndexPathUsed;

@property (nonatomic) NSIndexPath *lastPageMaxIndexPath;
@property (nonatomic) BOOL useLastPageMaxIndexPath;

@end

@implementation PBPaginationRenderer

- (id)initWithTriggerCallback:(BOOL(^)(void))callback
            atDistanceFromEnd:(NSInteger)distance
                    inSection:(NSInteger)section
           indicatorCellClass:(Class)indicatorCellClass
          indicatorCellHeight:(CGFloat)indicatorCellHeight {

    self = [super init];

    if (self != nil) {
        self.triggerCallback = callback;
        self.endDistance = distance;
        self.section = section;
        self.indicatorCellHeight = indicatorCellHeight;
        self.indicatorCellClass = indicatorCellClass;
        self.indexPathTriggerStack = [NSMutableArray array];
    }

    return self;
}


#pragma mark - Getters and Setters

- (NSIndexPath *)lastIndexPathUsed {
    return [self.indexPathTriggerStack lastObject];
}

#pragma mark - Public

- (void)renderItem:(PBListItem *)item
       atIndexPath:(NSIndexPath *)indexPath
            inCell:(UITableViewCell *)cell
      withListView:(PBListViewController *)listViewController {

    NSIndexPath *triggerIndexPath = self.lastIndexPathUsed;
    BOOL usingLastPageMaxIndexPath = NO;

    if (self.useLastPageMaxIndexPath && self.lastPageMaxIndexPath != nil) {
        triggerIndexPath = self.lastPageMaxIndexPath;
        usingLastPageMaxIndexPath = YES;
    }

    if (indexPath.section == self.section &&
        self.triggerCallback != nil &&
        indexPath.row > triggerIndexPath.row) {

        self.listViewController = listViewController;

        PBSectionItem *sectionItem = item.sectionItem;

        NSInteger triggerThreshold =
        sectionItem.items.count - 1 - self.endDistance;

        if (sectionItem != nil &&
            (indexPath.row >= triggerThreshold || usingLastPageMaxIndexPath)) {

            self.useLastPageMaxIndexPath = NO;

            NSIndexPath *lastIndexPath =
            [NSIndexPath
             indexPathForRow:sectionItem.items.count
             inSection:indexPath.section];

            [self.indexPathTriggerStack addObject:lastIndexPath];

            if (self.triggerCallback()) {

                [self configureFooterItemIfNecessary];

                __weak typeof(self) this = self;

                dispatch_async(dispatch_get_main_queue(), ^{
                    [this.listViewController
                     appendItemsToDataSource:@[this.indicatorItem]
                     inSection:this.section];
                });
            }
        }
    }
}

- (void)appendPageItems:(NSArray *)items {

    if (self.indicatorItem != nil) {

        [self.listViewController.tableView beginUpdates];

        if ([self.listViewController removeItemAtIndexPath:self.indicatorItem.indexPath]) {

            [self.listViewController.tableView
             deleteRowsAtIndexPaths:@[self.indicatorItem.indexPath]
             withRowAnimation:UITableViewRowAnimationBottom];
        }

        PBSectionItem *sectionItem =
        [self.listViewController sectionItemAtSection:self.section];

        PBListItem *lastItem = sectionItem.items.lastObject;

        self.lastPageMaxIndexPath = lastItem.indexPath;

        if (items.count > 0) {
            [self.listViewController doAppendItems:items toSection:self.section];
        }

        [self.listViewController.tableView endUpdates];
    }

    self.useLastPageMaxIndexPath = NO;
}

- (void)cancelPage:(BOOL)resetToLastPage {

    if (self.indicatorItem != nil) {

        [self.listViewController.tableView beginUpdates];

        if ([self.listViewController removeItemAtIndexPath:self.indicatorItem.indexPath]) {

            [self.listViewController.tableView
             deleteRowsAtIndexPaths:@[self.indicatorItem.indexPath]
             withRowAnimation:UITableViewRowAnimationBottom];
        }

        [self.listViewController.tableView endUpdates];
    }

    [self.indexPathTriggerStack removeLastObject];
    self.useLastPageMaxIndexPath = resetToLastPage;
}

#pragma mark -

- (void)configureFooterItemIfNecessary {

    static NSString * const paginationFooterID = @"pagination-footer";

    if (self.indicatorItem == nil) {

        self.indicatorItem =
        [PBListItem
         customClassItemWithUserContext:nil
         cellID:paginationFooterID
         cellClass:self.indicatorCellClass
         configure:nil
         binding:nil
         selectAction:nil
         deleteAction:nil];

        [self.listViewController.tableView
         registerClass:self.indicatorCellClass
         forCellReuseIdentifier:paginationFooterID];

        self.indicatorItem.rowHeight = self.indicatorCellHeight;
    }
}

@end
