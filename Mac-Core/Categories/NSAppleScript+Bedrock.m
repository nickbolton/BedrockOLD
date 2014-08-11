//
//  NSAppleScript+Bedrock.m
//  Bedrock
//
//  Created by Nick Bolton on 1/16/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSAppleScript+Bedrock.h"

DescType const PBAppleScriptTextDescriptorType = 1970567284;
DescType const PBAppleScriptLongDescriptorType = 1819242087;

@implementation NSAppleScript (Bedrock)

+ (NSAppleEventDescriptor *)runScript:(NSString*)scriptText {

    NSError *error = nil;
    NSAppleEventDescriptor *appleEventDescriptor =
    [self runScript:scriptText error:&error];
    if (error != nil) {
        PBLog(@"error: %@", error);
    }
    return appleEventDescriptor;
}

+ (NSAppleEventDescriptor *)runScript:(NSString*)scriptText error:(NSDictionary **)error {
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:scriptText];
    NSAppleEventDescriptor *appleEventDescriptor =
    [appleScript executeAndReturnError:error];
    return appleEventDescriptor;
}

+ (NSAppleEventDescriptor *)runScriptWithFile:(NSString *)scriptFile {

    NSString *extension = [scriptFile pathExtension];
    NSString *scriptName = [scriptFile stringByDeletingPathExtension];

    NSString *scriptPath =
    [[NSBundle mainBundle]
     pathForResource:scriptName ofType:extension];

    if (scriptPath == nil) {
        PBLog(@"No script exists with name: %@", scriptFile);
        return nil;
    }

    NSError *error = nil;

    NSString *scriptText =
    [NSString
     stringWithContentsOfFile:scriptPath
     encoding:NSUTF8StringEncoding
     error:&error];

    if (error != nil) {
        PBLog(@"Failed loading script file: %@ - %@", scriptFile, scriptPath);
        return nil;
    }

    return [self runScript:scriptText];
}

+ (NSAppleEventDescriptor *)runScriptWithFile:(NSString *)scriptFile
                            tokenReplacements:(NSDictionary *)tokenReplacements {
    return
    [self
     runScriptWithFile:scriptFile
     tokenReplacements:tokenReplacements
     error:NULL];
}

+ (NSAppleEventDescriptor *)runScriptWithFile:(NSString *)scriptFile
                            tokenReplacements:(NSDictionary *)tokenReplacements
                                        error:(NSDictionary **)errorDict {

    NSString *extension = [scriptFile pathExtension];
    NSString *scriptName = [scriptFile stringByDeletingPathExtension];

    NSString *scriptPath =
    [[NSBundle mainBundle]
     pathForResource:scriptName ofType:extension];

    if (scriptPath == nil) {
        PBLog(@"No script exists with name: %@", scriptFile);
        return nil;
    }

    NSError *error = nil;

    NSString *scriptText =
    [NSString
     stringWithContentsOfFile:scriptPath
     encoding:NSUTF8StringEncoding
     error:&error];

    if (error != nil) {
        
        if (errorDict) {
            *errorDict = @{@"error" : error};
        }
        
        PBLog(@"Failed loading script file: %@ - %@", scriptFile, scriptPath);
        return nil;
    }

    for (NSString *token in tokenReplacements) {
        scriptText =
        [scriptText
         stringByReplacingOccurrencesOfString:token
         withString:[tokenReplacements objectForKey:token]];
    }
    
    error = nil;
    
    return [self runScript:scriptText error:errorDict];
}

+ (NSString *)runScriptWithStringResult:(NSString *)scriptFile {
    NSAppleEventDescriptor *eventDescriptor =
    [self runScriptWithFile:scriptFile];

    NSString *message =
    [NSString stringWithFormat:
     @"Return descriptor type (%@) != PBAppleScriptTextDescriptorType",
     NSFileTypeForHFSTypeCode([eventDescriptor descriptorType])];

    NSAssert([eventDescriptor descriptorType] == PBAppleScriptTextDescriptorType,
             message);

    return eventDescriptor.stringValue;
}

+ (NSNumber *)runScriptWithNumberResult:(NSString *)scriptFile {
    NSAppleEventDescriptor *eventDescriptor =
    [self runScriptWithFile:scriptFile];

    NSString *message =
    [NSString stringWithFormat:
     @"Return descriptor type (%@) != PBAppleScriptLongDescriptorType",
     NSFileTypeForHFSTypeCode([eventDescriptor descriptorType])];

    NSAssert([eventDescriptor descriptorType] == PBAppleScriptLongDescriptorType,
             message);
    
    return @(eventDescriptor.int32Value);
}

@end

