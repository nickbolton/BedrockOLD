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

- (void)renderControl:(UIControl *)control
             withItem:(PBListControlItem *)item {

    [control
     removeTarget:nil
     action:NULL
     forControlEvents:UIControlEventAllEvents];

    [control
     addTarget:item
     action:@selector(valueChanged:)
     forControlEvents:UIControlEventEditingChanged];
}

@end
