//
//  PBListControlRenderer.h
//  Pods
//
//  Created by Nick Bolton on 3/5/14.
//
//

#import "PBListItemRenderer.h"

@class PBListControlItem;

@interface PBListControlRenderer : NSObject <PBListItemRenderer>

- (void)renderControl:(UIControl *)control
          withItem:(PBListControlItem *)item;

@end
