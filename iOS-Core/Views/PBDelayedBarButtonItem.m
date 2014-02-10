//
//  PBDelayedBarButtonItem.m
//  Calendar
//
//  Created by Nick Bolton on 2/10/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBDelayedBarButtonItem.h"

@interface PBDelayedBarButtonItem() {

    NSTimeInterval _timeEnabledChanged;
}

@end

@implementation PBDelayedBarButtonItem

- (void)setEnabled:(BOOL)enabled {

    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval delta = now - _timeEnabledChanged;

    if (delta > .1f) {
        [super setEnabled:enabled];
    }
}

@end
