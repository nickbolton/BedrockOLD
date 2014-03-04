//
//  PBListTextItem.h
//  Pods
//
//  Created by Nick Bolton on 3/3/14.
//
//

#import "PBListItem.h"

@interface PBListTextItem : PBListItem <UITextFieldDelegate>

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic) UIEdgeInsets textInsets;

+ (PBListTextItem *)textItemWithText:(NSString *)text
                           textColor:(UIColor *)textColor
                                font:(UIFont *)font
                         placeholder:(NSString *)placeholder
                         textUpdated:(void(^)(PBListTextItem *item, NSString *updatedText))textUpdatedBlock;

- (void)textChanged:(UITextField *)textField;
- (void)resignFirstResponder;

@end
