//
//  NSImage+Bedrock.h
//  Bedrock
//
//  Created by Nick Bolton on 12/23/12.
//  Copyright (c) 2012 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Bedrock)

- (NSData *)pngData;
+ (NSImage *)imageWithPreviewOfFileAtPath:(NSString *)path
                                   ofSize:(NSSize)size
                                   asIcon:(BOOL)icon;

+ (NSImage *)stretchedImageWithParts:(NSArray *)imageParts
                                size:(NSSize)size
                            vertical:(BOOL)vertical
                               alpha:(CGFloat)alpha;

- (BOOL)isEqualToImage:(NSImage *)image;

@end
