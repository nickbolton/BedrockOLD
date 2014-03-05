//
//  PBListTextItem.h
//  Pods
//
//  Created by Nick Bolton on 3/3/14.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListControlItem.h"

@interface PBListTextItem : PBListControlItem <UITextFieldDelegate>

@property (nonatomic) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic) UITextField *textField;
@property (nonatomic) UIEdgeInsets textInsets;

+ (PBListTextItem *)textItemWithText:(NSString *)text
                           textColor:(UIColor *)textColor
                                font:(UIFont *)font
                         placeholder:(NSString *)placeholder
                        valueUpdated:(void(^)(PBListControlItem *item, NSString *updatedValue))valueUpdatedBlock;

@end
