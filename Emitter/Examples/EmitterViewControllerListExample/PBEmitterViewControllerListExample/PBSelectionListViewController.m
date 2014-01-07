//
//  PBSelectionListViewController.m
//  PBEmitterViewControllerListExample
//
//  Created by Nick Bolton on 1/6/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBSelectionListViewController.h"

@interface PBSelectionListViewController ()

@end

@implementation PBSelectionListViewController

#pragma mark - Setup

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)buildDataSource {

    NSMutableArray *items = [NSMutableArray array];

    for (NSInteger i = 0; i < 10; i++) {

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

        [items addObject:item];
    }

    return items;
}

@end
