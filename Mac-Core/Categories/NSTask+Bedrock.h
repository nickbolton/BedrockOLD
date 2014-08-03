//
//  NSTask+Bedrock.h
//  Bedrock
//
//  Created by Nick Bolton on 12/19/12.
//  Copyright (c) 2012 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTask (Bedrock)

+ (NSString *)runTask:(NSString *)task withArguments:(NSArray *)arguments;

@end
