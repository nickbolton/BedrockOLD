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
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UIFont *placeholderFont;
@property (nonatomic) UITextField *textField;
@property (nonatomic) UIEdgeInsets textInsets;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (nonatomic, getter = isSecure) BOOL secure;

+ (PBListTextItem *)textItemWithText:(NSString *)text
                           textColor:(UIColor *)textColor
                                font:(UIFont *)font
                         placeholder:(NSString *)placeholder
                        valueUpdated:(void(^)(PBListControlItem *item, NSString *updatedValue))valueUpdatedBlock;

@end
