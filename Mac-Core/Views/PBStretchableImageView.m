//
//  PBStretchableImageView.m
//  Bedrock
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBStretchableImageView.h"

@implementation PBStretchableImageView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _vertical = NO;
    self.flipped = NO;
    _alpha = 1.0f;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];

    NSImage *image = [[NSImage alloc] initWithSize:frameRect.size];
    [image lockFocus];
    NSDrawThreePartImage(self.bounds,
                         _topImage,
                         _middleImage,
                         _bottomImage,
                         _vertical,
                         NSCompositeSourceOver,
                         _alpha,
                         self.isFlipped);

    [image unlockFocus];

    self.image = image;
}

@end
