//
//  PBListViewControllerItem.m
//  PBEmitterViewControllerListExample
//
//  Created by Nick Bolton on 1/6/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBListViewControllerItem.h"

static void *ObservationContext = &ObservationContext;

@interface PBListViewControllerItem()

@property (nonatomic, readwrite) UIViewController <PBListViewControllerItemProtocol> *viewController;
@property (nonatomic, weak) PBListViewController *listViewController;

@end

@implementation PBListViewControllerItem

+ (instancetype)customNibItemWithViewController:(UIViewController <PBListViewControllerItemProtocol> *)viewController
                                         cellID:(NSString *)cellID
                                        cellNib:(UINib *)cellNib {

    PBListViewControllerItem *item = [[PBListViewControllerItem alloc] init];

    [item commonInit];
    item.viewController = viewController;
    item.itemType = PBItemTypeCustom;
    item.cellID = cellID;
    item.cellNib = cellNib;
    [item setupConfigureBlock];

    return item;
}

+ (instancetype)customClassItemWithViewController:(UIViewController <PBListViewControllerItemProtocol> *)viewController
                                           cellID:(NSString *)cellID
                                        cellClass:(Class)cellClass {

    PBListViewControllerItem *item = [[PBListViewControllerItem alloc] init];

    [item commonInit];
    item.viewController = viewController;
    item.itemType = PBItemTypeCustom;
    item.cellID = cellID;
    item.cellClass = cellClass;
    [item setupConfigureBlock];

    return item;
}

- (void)setupConfigureBlock {

    __weak typeof(self) this = self;

    self.configureBlock = ^(PBListViewController *parentViewController, PBListItem *item, PBListViewDefaultCell *cell) {

        this.listViewController = parentViewController;

        [parentViewController addChildViewController:this.viewController];

        this.viewController.view.autoresizingMask =
        UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleWidth;

        [cell addSubview:this.viewController.view];

        [this.viewController didMoveToParentViewController:parentViewController];

        [parentViewController reloadTableRow:item.indexPath.row];

        [this.viewController
         addObserver:this
         forKeyPath:@"listViewItemHeight"
         options:NSKeyValueObservingOptionInitial
         context:&ObservationContext];
    };
}

- (CGFloat)rowHeight {

    if ([self.viewController isKindOfClass:[PBListViewController class]]) {

        // calculate the row height based of the embedded list view controller data source

        CGFloat result = 0.0f;

        PBListViewController *listViewController = (id)self.viewController;

        for (PBListItem *item in listViewController.dataSource) {
            result += item.rowHeight;
        }
        
        return result;
    }

    NSAssert([self.viewController respondsToSelector:@selector(listViewItemHeight)],
             @"PBListViewControllerItem viewController does not listViewItemHeight method");
    
    return [self.viewController listViewItemHeight];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == ObservationContext) {
        [self.listViewController reloadTableRow:self.indexPath.row];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
