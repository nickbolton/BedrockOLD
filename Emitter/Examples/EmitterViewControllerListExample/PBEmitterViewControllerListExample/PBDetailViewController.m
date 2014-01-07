//
//  PBDetailViewController.m
//  PBEmitterViewControllerListExample
//
//  Created by Nick Bolton on 1/6/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBDetailViewController.h"

@interface PBDetailViewController ()

@end

@implementation PBDetailViewController

#pragma mark - Setup

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [NSString stringWithFormat:@"Detail %ld", self.navigationController.viewControllers.count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)buildDataSource {

    NSMutableArray *items = [NSMutableArray array];

    __weak typeof(self) this = self;

    for (NSInteger i = 0; i < 10; i++) {

        NSString *title =
        [NSString stringWithFormat:@"Item %ld", (long)i];

        NSString *value =
        [NSString stringWithFormat:@"Value %ld", (long)i];

        PBListItem *item =
        [PBListItem
         selectionItemWithTitle:title
         value:value
         itemType:PBItemTypeDefault
         hasDisclosure:YES
         selectAction:^(id cell) {

             PBLog(@"item pressed: %@", title);

             PBDetailViewController *viewController =
             [[PBDetailViewController alloc] init];

             [this.navigationController pushViewController:viewController animated:YES];

         } deleteAction:nil];

        item.titleColor = [UIColor blackColor];

        [items addObject:item];
    }
    
    return items;
}

@end
