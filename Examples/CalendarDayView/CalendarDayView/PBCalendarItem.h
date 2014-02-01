//
//  PBCalendarItem.h
//  Sometime
//
//  Created by Nick Bolton on 1/5/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCollectionItem.h"

@interface PBCalendarItem : PBCollectionItem

@property (nonatomic, readonly) NSDate *startTime;
@property (nonatomic, readonly) NSDate *endTime;

+ (instancetype)
itemWithStartTime:(NSDate *)startTime
endTime:(NSDate *)endTime
configure:(void(^)(PBCollectionViewController *viewController, PBCollectionItem *item, id cell))configureBlock
binding:(void(^)(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, id cell))bindingBlock
selectAction:(void(^)(PBCollectionViewController *viewController))selectActionBlock;

@end
