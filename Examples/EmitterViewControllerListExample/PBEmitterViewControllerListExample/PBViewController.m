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
#import "PBGroupedViewController.h"

@interface PBViewController ()

@end

@implementation PBViewController

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
    
    // subclasses of PBListViewController need only supply PBListItem objects

    NSMutableArray *items = [NSMutableArray array];

    [items addObject:[self spacerItem]];
    [items addObject:[self buildModalViewControllerItem]];
    [items addObject:[self spacerItem]];
    [items addObject:[self buildPushingViewControllerItem]];

    return items;
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

- (PBListItem *)spacerItem {
    
    PBListItem *item =
    [PBListItem spacerItemWithHeight:20.0f];
    item.backgroundColor = [UIColor lightGrayColor];
    return item;
}

@end
