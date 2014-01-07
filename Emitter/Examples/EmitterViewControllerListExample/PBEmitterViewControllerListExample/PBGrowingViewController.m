//
//  PBGrowingViewController.m
//  PBEmitterViewControllerListExample
//
//  Created by Nick Bolton on 1/6/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBGrowingViewController.h"

@interface PBGrowingViewController ()

@property (nonatomic) NSInteger itemCount;
@property (nonatomic) CGFloat listViewItemHeight;

@end

@implementation PBGrowingViewController

#pragma mark - Setup

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [NSString stringWithFormat:@"Detail %ld", self.navigationController.viewControllers.count];
    self.tableView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)buildDataSource {

    NSMutableArray *items = [NSMutableArray array];

    __weak typeof(self) this = self;

    PBListItem *addItem =
    [PBListItem
     selectionItemWithTitle:@"Add Item"
     value:nil
     itemType:PBItemTypeDefault
     hasDisclosure:NO
     selectAction:^(id cell) {

         [this.tableView beginUpdates];
         this.itemCount++;

         [this reloadData];
//         [this reloadDataSource];
//
//         NSIndexPath *indexPath =
//         [NSIndexPath indexPathForRow:this.itemCount inSection:0];
//
//         [this.tableView
//          insertRowsAtIndexPaths:@[indexPath]
//          withRowAnimation:UITableViewRowAnimationAutomatic];
//
//         [this.tableView endUpdates];

         // setting listViewItemHeight triggers container view controllers to
         // update their height the value is abitrary in our case because the
         // container view controller will use our data source to determine
         // our height.  if containing view controllers do not subclass from
         // PBListViewController, then they'll have to set an actual value.

         this.listViewItemHeight = 0.0f;

     } deleteAction:nil];
    addItem.titleAlignment = NSTextAlignmentCenter;
    addItem.titleColor = [UIColor blackColor];
    addItem.backgroundColor = [UIColor redColor];

    [items addObject:addItem];

    for (NSInteger i = 0; i < self.itemCount; i++) {

        NSString *title =
        [NSString stringWithFormat:@"Item %ld", (long)i];

        PBListItem *item =
        [PBListItem
         selectionItemWithTitle:title
         value:nil
         itemType:PBItemTypeChecked
         hasDisclosure:NO
         selectAction:^(id cell) {

             PBLog(@"item pressed: %@", title);

         } deleteAction:nil];

        item.titleColor = [UIColor blackColor];
        item.backgroundColor = [UIColor greenColor];

        [items addObject:item];
    }
    
    return items;
}

@end
