//
//  PBListCell.m
//  Bedrock
//
//  Created by Nick Bolton on 11/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListCell.h"
#import "PBListItem.h"

@implementation PBListCell

- (void) layoutSubviews {
    [super layoutSubviews];

    CGRect frame = self.titleLabel.frame;
    CGFloat xdiff = self.item.titleMargin - CGRectGetMinX(frame);

    frame.origin.x += xdiff;
    frame.size.width -= xdiff;
    self.titleLabel.frame = frame;
}

@end
