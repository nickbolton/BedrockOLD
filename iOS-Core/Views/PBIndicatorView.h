//
//  PBIndicatorView.h
//  Bedrock
//
//  Created by Nick Bolton on 5/26/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PBIndicatorState) {
    
    PBIndicatorStateHidden = 0,
    PBIndicatorStateShowing,
    PBIndicatorStateHiding,
    PBIndicatorStateVisible,
};

@interface PBIndicatorView : UIView

- (instancetype)initWithBackgroundAlpha:(CGFloat)alpha;

@property (nonatomic) CGFloat backgroundAlpha;
@property (nonatomic, strong) UIColor *textColor;

@end
