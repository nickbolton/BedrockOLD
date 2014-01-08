//
//  PBGroupedViewController.m
//  PBEmitterViewControllerListExample
//
//  Created by Nick Bolton on 1/7/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBGroupedViewController.h"
#import "PBDetailViewController.h"

@interface PBGroupedViewController ()

@end

@implementation PBGroupedViewController

#pragma mark - Setup

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Grouped";
    self.tableView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)buildDataSource {

    NSMutableArray *sections = [NSMutableArray array];

    __weak typeof(self) this = self;

    for (NSInteger i = 0; i < 10; i++) {

        NSMutableArray *items = [NSMutableArray array];

        NSString *sectionTitle =
        [NSString stringWithFormat:@"Group %ld", (long)i];

        for (NSInteger j = 0; j < 3; j++) {

            NSString *title =
            [NSString stringWithFormat:@"Item %ld - %ld", (long)i, (long)j];

            NSString *value =
            [NSString stringWithFormat:@"Value %ld - %ld", (long)i, (long)j];

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

        PBSectionItem *sectionItem =
        [PBSectionItem
         sectionItemWithHeaderTitle:sectionTitle
         footerTitle:nil
         items:items];

        [sections addObject:sectionItem];
    }

    return sections;
}

@end
