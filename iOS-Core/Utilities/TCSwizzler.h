//
//  TCSwizzler.h
//  Pods
//
//  Created by Nick Bolton on 3/9/14.
//
//

#import <Foundation/Foundation.h>

void PBReplaceSelectorForTargetWithSourceImpAndSwizzle(Class c, SEL orig, SEL new);

@interface TCSwizzler : NSObject

@end
