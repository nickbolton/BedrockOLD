//
//  PBListDatePickerItem.h
//  Pods
//
//  Created by Nick Bolton on 3/3/14.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListExpandableItem.h"

@class PBListControlItem;
@class PBDateRange;

@interface PBListDatePickerItem : PBListExpandableItem

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) PBDateRange *dateRange;

+ (PBListDatePickerItem *)datePickerItemWithTitle:(NSString *)title
                                             date:(NSDate *)date
                                     valueUpdated:(void(^)(PBListDatePickerItem *item, NSDate *updatedValue))valueUpdatedBlock;

@end
