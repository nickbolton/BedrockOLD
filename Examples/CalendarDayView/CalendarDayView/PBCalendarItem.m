//
//  PBCalendarItem.m
//  Sometime
//
//  Created by Nick Bolton on 1/5/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCalendarItem.h"
#import "PBCalendarEntryCell.h"

@interface PBCalendarItem()

@property (nonatomic, readwrite) NSDate *startTime;
@property (nonatomic, readwrite) NSDate *endTime;

@end

@implementation PBCalendarItem

+ (instancetype)
itemWithStartTime:(NSDate *)startTime
endTime:(NSDate *)endTime
configure:(void(^)(PBCollectionViewController *viewController, PBCollectionItem *item, id cell))configureBlock
binding:(void(^)(PBCollectionViewController *viewController, NSIndexPath *indexPath, PBCollectionItem *item, id cell))bindingBlock
selectAction:(void(^)(PBCollectionViewController *viewController))selectActionBlock {

    NSString *reuseID = NSStringFromClass([PBCalendarEntryCell class]);
    UINib *nib =
    [UINib
     nibWithNibName:NSStringFromClass([PBCalendarEntryCell class])
     bundle:nil];

    PBCalendarItem *item =
    [[PBCalendarItem alloc]
     initWithUserContext:nil
     reuseIdentifier:reuseID
     cellNib:nib
     configure:configureBlock
     binding:bindingBlock
     selectAction:selectActionBlock];

    item.startTime = startTime;
    item.endTime = endTime;

    NSArray *colors =
    @[
      [UIColor colorWithRGBHex:0xde3c49],
      [UIColor colorWithRGBHex:0xde3cc3],
      [UIColor colorWithRGBHex:0x7f3cde],
      [UIColor colorWithRGBHex:0x3c72de],
      [UIColor colorWithRGBHex:0x2cc6b9],
      ];

    NSInteger colorIndex = [self randomNumberBetween:0 maxNumber:colors.count-1];

    item.backgroundColor = colors[colorIndex];

    return item;
}

+ (NSInteger)randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max {
    return min + arc4random() % (max - min + 1);
}

@end
