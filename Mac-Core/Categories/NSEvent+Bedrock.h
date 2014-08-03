//
//  NSEvent+Bedrock.h
//  Bedrock
//
//  Created by Nick Bolton on 1/16/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSInteger const kPBEventAllModifiersMask;

@interface NSEvent (Bedrock)

+ (BOOL)isCurrentModifiersExactly:(NSUInteger)modifiers;
- (BOOL)isModifiersExactly:(NSUInteger)modifiers;

@end
