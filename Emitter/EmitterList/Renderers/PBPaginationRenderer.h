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
          footerViewCellClass:(Class)footerViewClass
                 footerHeight:(CGFloat)footerHeight;

- (void)appendPageItems:(NSArray *)items;

@end
