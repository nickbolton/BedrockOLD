//
//  PBListDatePickerItem.h
//  Pods
//
//  Created by Nick Bolton on 3/3/14.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListControlItem.h"

@interface PBListDatePickerItem : PBListControlItem

@property (nonatomic) NSDate *date;
@property (nonatomic) UIDatePicker *datePicker;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

+ (PBListDatePickerItem *)datePickerItemWithTitle:(NSString *)title
                                             date:(NSDate *)date
                                     valueUpdated:(void(^)(PBListControlItem *item, NSDate *updatedValue))valueUpdatedBlock;

@end
