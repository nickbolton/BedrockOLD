//
//  NSString+Utilities.h
//  Sometime
//
//  Created by Nick Bolton on 12/1/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utilities)

+ (NSString *)durationTextForDuration:(NSTimeInterval)duration
                            startTime:(NSDate *)startTime
                               active:(BOOL)active;

@end
