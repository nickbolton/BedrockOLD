//
//  NSValue+Bedrock.h
//  Bedrock
//
//  Created by Nick Bolton on 8/8/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue (Bedrock)

+ (NSValue *)valueWithEdgeInsets:(NSEdgeInsets)insets;
- (NSEdgeInsets)edgeInsetsValue;

@end
