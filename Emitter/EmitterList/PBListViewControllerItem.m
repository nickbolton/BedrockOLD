//
//  PBListViewControllerItem.m
//  Bedrock
//
//  Created by Nick Bolton on 1/6/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBListViewControllerItem.h"
#import "PBListViewDefaultCell.h"
#import "PBListViewController.h"
#import "PBListViewControllerCell.h"
#import "PBSectionItem.h"

static void *ObservationContext = &ObservationContext;

@interface PBListViewControllerItem()

@property (nonatomic, readwrite) UIViewController <PBListViewControllerItemProtocol> *contentViewController;
@property (nonatomic, strong) PBListViewController *listViewController;

@end

@implementation PBListViewControllerItem

+ (instancetype)itemWithViewController:(UIViewController <PBListViewControllerItemProtocol> *)viewController
                                cellID:(NSString *)cellID {

    PBListViewControllerItem *item = [[PBListViewControllerItem alloc] init];

    [item commonInit];
    item.contentViewController = viewController;
    item.itemType = PBItemTypeCustom;
    item.cellID = cellID;
    item.cellClass = [PBListViewControllerCell class];
    [item setupBindingBlock];

    if ([viewController respondsToSelector:@selector(setListViewItemHeight:)]) {
        [viewController
         addObserver:item
         forKeyPath:@"listViewItemHeight"
         options:NSKeyValueObservingOptionInitial
         context:&ObservationContext];
    }

    return item;
}

- (void)setupBindingBlock {

    __weak typeof(self) this = self;

    self.bindingBlock = ^(PBListViewController *parentViewController, NSIndexPath *indexPath, PBListItem *item, PBListViewControllerCell *cell) {

        cell.contentViewController = this.contentViewController;
        this.listViewController = parentViewController;

        [parentViewController addChildViewController:this.contentViewController];
        this.contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:this.contentViewController.view];
        [NSLayoutConstraint expandToSuperview:this.contentViewController.view];
        [this.contentViewController didMoveToParentViewController:parentViewController];
        [parentViewController reloadTableRow:item.indexPath.row];
    };
}

- (CGFloat)rowHeight {

    if ([self.contentViewController isKindOfClass:[PBListViewController class]]) {

        // calculate the row height based of the embedded list view controller data source

        CGFloat result = 0.0f;

        PBListViewController *listViewController = (id)self.contentViewController;

        for (PBSectionItem *sectionItem in listViewController.dataSource) {
            for (PBListItem *item in sectionItem.items) {
                result += item.rowHeight;
            }
        }
        
        return result;
    }

    NSAssert([self.contentViewController respondsToSelector:@selector(listViewItemHeight)],
             @"PBListViewControllerItem viewController does not listViewItemHeight method");
    
    return [self.contentViewController listViewItemHeight];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == ObservationContext) {
        [self.listViewController reloadTableRow:self.indexPath.row];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
