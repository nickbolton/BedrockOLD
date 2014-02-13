//
//  PBPaginationRenderer.h
//  Pods
//
//  Created by Nick Bolton on 2/7/14.
//
//

#import <UIKit/UIKit.h>
#import "PBListItemRenderer.h"

@interface PBPaginationRenderer : NSObject <PBListItemRenderer>

- (id)initWithTriggerCallback:(BOOL(^)(void))callback
            atDistanceFromEnd:(NSInteger)distance
                    inSection:(NSInteger)section
           indicatorCellClass:(Class)indicatorCellClass
          indicatorCellHeight:(CGFloat)indicatorCellHeight;

- (void)appendPageItems:(NSArray *)items;
- (void)cancelPage:(BOOL)resetToLastPage;

@end
