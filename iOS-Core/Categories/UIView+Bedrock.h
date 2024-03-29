//
//  UIView+Bedrock.h
//  Bedrock
//
//  Created by Nick Bolton on 4/1/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Bedrock)

- (void)removeAllSubviews;
- (void)DEBUG_colorizeSelfAndSubviews;
- (void)fadeOutInWithDuration:(CGFloat)duration andBlock:(void(^)(void))block;
- (UIImage *)snapshot;
- (void)addFadingMaskWithEdgeInsets:(UIEdgeInsets)edgeInsets;
- (void)disableGesturesOfType:(Class)gestureType recurse:(BOOL)recurse;

- (UIImage *)pb_screenshot;
- (UIImage *)pb_screenshotInBounds:(CGRect)bounds
                afterScreenUpdates:(BOOL)afterScreenUpdates;

// animations
- (void)startWiggleAnimationWithRotation:(CGFloat)rotation
                             translation:(CGPoint)translation;
- (void)stopWiggleAnimation;

- (void)startPulsingAnimation:(CGFloat)periodcity;
- (void)stopPulsingAnimation;

- (void)startBlinkingAnimation:(CGFloat)periodcity;
- (void)startBlinkingAnimation:(CGFloat)periodcity
               minimumDuration:(NSTimeInterval)minimumDuration;
- (void)stopBlinkingAnimation;
- (void)stopBlinkingAnimation:(BOOL)force;

// motion
- (void)addHorizontalMotion:(CGFloat)weight;
- (void)addVerticalMotion:(CGFloat)weight;
- (void)add2DMotion:(CGFloat)weight;

@end
