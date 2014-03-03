//
//  PBListTextRenderer.m
//  Pods
//
//  Created by Nick Bolton on 3/3/14.
//
//

#import "PBListTextRenderer.h"
#import "PBListTextItem.h"
#import "PBListViewDefaultCell.h"

@interface PBListTextRenderer()
@end

@implementation PBListTextRenderer

- (void)renderItem:(PBListTextItem *)item
       atIndexPath:(NSIndexPath *)indexPath
            inCell:(PBListViewDefaultCell *)cell
      withListView:(PBListViewController *)listViewController {

    if ([item isKindOfClass:[PBListTextItem class]]) {

        [self renderCell:cell withItem:item];
    }
}

- (UITextField *)cellTextField:(PBListViewDefaultCell *)cell {

    static NSInteger const textFieldTag = 999;

    UITextField *textField = (id)[cell viewWithTag:textFieldTag];

    if (textField == nil) {

        textField = [[UITextField alloc] init];
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        textField.tag = textFieldTag;

        [cell.contentView addSubview:textField];

        [NSLayoutConstraint expandHeightToSuperview:textField];
    }

    return textField;
}

- (void)renderCell:(PBListViewDefaultCell *)cell
          withItem:(PBListTextItem *)item {

    UITextField *textField = [self cellTextField:cell];

    textField.delegate = item;
    textField.text = item.text;
    textField.textColor = item.textColor;
    textField.font = item.font;

    textField.placeholder = item.placeholder;

    [textField
     removeTarget:nil
     action:NULL
     forControlEvents:UIControlEventAllEvents];

    [textField
     addTarget:item
     action:@selector(textChanged:)
     forControlEvents:UIControlEventEditingChanged];
}

@end
