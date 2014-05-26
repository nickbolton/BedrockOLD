//
//  PBIndicatorView.m
//  Bedrock
//
//  Created by Nick Bolton on 5/26/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBIndicatorView.h"

@interface PBIndicatorView()

@property (nonatomic, strong) UIView *indicatorBackgroundView;
@property (nonatomic, strong) UILabel *indicatorLabel;
@property (nonatomic) PBIndicatorState indicatorState;
@property (nonatomic) CGFloat backgroundAlpha;

@end

@implementation PBIndicatorView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithBackgroundAlpha:(CGFloat)alpha {
    self = [super init];
    if (self) {
        self.backgroundAlpha = alpha;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    self.indicatorState = PBIndicatorStateHidden;
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    backgroundView.backgroundColor = self.tintColor;
    backgroundView.alpha = self.backgroundAlpha;
    
    self.indicatorBackgroundView = backgroundView;
    
    [self addSubview:backgroundView];
    [NSLayoutConstraint expandToSuperview:backgroundView];
    
    self.indicatorLabel = [[UILabel alloc] init];
    self.indicatorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.indicatorLabel.textAlignment = NSTextAlignmentCenter;
    self.indicatorLabel.font =
    [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    
    CGFloat statusBarHeight =
    CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    
    [self addSubview:self.indicatorLabel];
    [NSLayoutConstraint expandWidthToSuperview:self.indicatorLabel];
    [NSLayoutConstraint alignToTop:self.indicatorLabel withPadding:statusBarHeight];
    [NSLayoutConstraint alignToBottom:self.indicatorLabel withPadding:0.0f];
}

#pragma mark - Getters and Setters

- (void)setBackgroundAlpha:(CGFloat)backgroundAlpha {
    _backgroundAlpha = backgroundAlpha;
    self.indicatorBackgroundView.alpha = backgroundAlpha;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.indicatorLabel.textColor = textColor;
}

@end
