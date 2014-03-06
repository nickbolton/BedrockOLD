//
//  PBListControlRenderer.m
//  Pods
//
//  Created by Nick Bolton on 3/5/14.
//
//

#import "PBListControlRenderer.h"
#import "PBListViewDefaultCell.h"
#import "PBListControlItem.h"

@implementation PBListControlRenderer

#pragma mark - Getter and Setters

- (UIControlEvents)valueChangedControlEvents {
    return UIControlEventValueChanged;
}

#pragma mark - Public

- (void)renderControl:(UIControl *)control
             withItem:(PBListControlItem *)item {

    [control
     removeTarget:nil
     action:NULL
     forControlEvents:UIControlEventAllEvents];

    [control
     addTarget:item
     action:@selector(valueChanged:)
     forControlEvents:self.valueChangedControlEvents];
}

#pragma mark - PBListItemRenderer Conformance

- (void)renderItem:(PBListItem *)item
       atIndexPath:(NSIndexPath *)indexPath
            inCell:(UITableViewCell *)cell
      withListView:(PBListViewController *)listViewController {
}

- (void)didEndRendering:(PBListControlItem *)item
            atIndexPath:(NSIndexPath *)indexPath
                 inCell:(UITableViewCell *)cell
           withListView:(PBListViewController *)listViewController {

    if ([item isKindOfClass:[PBListControlItem class]]) {
        item.control = nil;
    }
}

@end
