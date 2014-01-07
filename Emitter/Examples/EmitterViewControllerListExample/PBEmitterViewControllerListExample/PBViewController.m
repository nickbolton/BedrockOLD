//
//  PBViewController.m
//  PBEmitterViewControllerListExample
//
//  Created by Nick Bolton on 1/6/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBViewController.h"
#import "PBSelectionListViewController.h"
#import "PBDetailViewController.h"
#import "PBGrowingViewController.h"

@interface PBViewController ()

@end

@implementation PBViewController

#pragma mark - Setup

- (PBListViewControllerItem *)buildSimpleSelectionViewControllerItem {

    PBSelectionListViewController *viewController =
    [[PBSelectionListViewController alloc] init];

    return
    [PBListViewControllerItem
     customClassItemWithViewController:viewController
     cellID:NSStringFromClass([viewController class])
     cellClass:[PBListCell class]];
}

- (PBListItem *)buildModalViewControllerItem {

    __weak typeof(self) this = self;

    PBListItem *item =
    [PBListItem
     selectionItemWithTitle:@"Launch Modal"
     value:nil
     itemType:PBItemTypeDefault
     hasDisclosure:YES
     selectAction:^(id cell) {

         PBDetailViewController *viewController =
         [[PBDetailViewController alloc] init];

         viewController.hasCancelNavigationBarItem = YES;

         [UINavigationController
          presentViewController:viewController
          fromViewController:this
          completion:nil];

     } deleteAction:nil];
    item.backgroundColor = [UIColor whiteColor];
    item.titleColor = [UIColor blackColor];

    return item;
}

- (PBListItem *)buildPushingViewControllerItem {

    __weak typeof(self) this = self;

    PBListItem *item =
    [PBListItem
     selectionItemWithTitle:@"Push Detail"
     value:nil
     itemType:PBItemTypeDefault
     hasDisclosure:YES
     selectAction:^(id cell) {

         PBDetailViewController *viewController =
         [[PBDetailViewController alloc] init];

         [this.navigationController
          pushViewController:viewController
          animated:YES];

     } deleteAction:nil];
    item.backgroundColor = [UIColor whiteColor];
    item.titleColor = [UIColor blackColor];
    
    return item;
}

- (PBListItem *)buildGrowingViewControllerItem {

    PBGrowingViewController *viewController =
    [[PBGrowingViewController alloc] init];

    return
    [PBListViewControllerItem
     customClassItemWithViewController:viewController
     cellID:NSStringFromClass([viewController class])
     cellClass:[PBListCell class]];
}

- (PBListItem *)spacerItem {

    PBListItem *item =
    [PBListItem spacerItemWithHeight:20.0f];
    item.backgroundColor = [UIColor lightGrayColor];
    return item;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Root View";
    self.tableView.backgroundColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)buildDataSource {

    NSMutableArray *items = [NSMutableArray array];

    [items addObject:[self buildModalViewControllerItem]];
    [items addObject:[self buildPushingViewControllerItem]];
    [items addObject:[self spacerItem]];
    [items addObject:[self buildGrowingViewControllerItem]];
    [items addObject:[self spacerItem]];
    [items addObject:[self buildSimpleSelectionViewControllerItem]];

    return items;
}

@end
