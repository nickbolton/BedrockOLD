//
//  NSAppleScript+Bedrock.h
//  Bedrock
//
//  Created by Nick Bolton on 1/16/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSAppleScript (Bedrock)

+ (NSAppleEventDescriptor *)runScript:(NSString*)scriptText;
+ (NSAppleEventDescriptor *)runScript:(NSString*)scriptText error:(NSDictionary **)error;
+ (NSAppleEventDescriptor *)runScriptWithFile:(NSString *)scriptFile;
+ (NSAppleEventDescriptor *)runScriptWithFile:(NSString *)scriptFile
                            tokenReplacements:(NSDictionary *)tokenReplacements;
+ (NSAppleEventDescriptor *)runScriptWithFile:(NSString *)scriptFile
                            tokenReplacements:(NSDictionary *)tokenReplacements
                                        error:(NSDictionary **)errorDict;
+ (NSString *)runScriptWithStringResult:(NSString *)scriptFile;
+ (NSNumber *)runScriptWithNumberResult:(NSString *)scriptFile;

@end
