//
//  PBCalendarHourDecorationCell.m
//  Sometime
//
//  Created by Nick Bolton on 1/26/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBCalendarHourDecorationCell.h"

static CGFloat const kPBCalendarHalfHourMinScale = .75f;
static CGFloat const kPBCalendarEvenHourMinScale = .5f;
static CGFloat const kPBCalendarQuarterHourMinScale = .25f;

@interface PBCalendarHourDecorationCell()

@property (nonatomic, readwrite) UILabel *hourLabel;
@property (nonatomic, readwrite) UILabel *quarterHourLabel;
@property (nonatomic, readwrite) UILabel *halfHourLabel;
@property (nonatomic, readwrite) UILabel *threeQuarterHourLabel;
@property (nonatomic, strong) UIView *hourLine;
@property (nonatomic, strong) UIView *halfHourLine;
@property (nonatomic, strong) NSLayoutConstraint *halfHourLineTopSpace;

@end


@implementation PBCalendarHourDecorationCell

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

- (void)commonInit {
    _hour = -1;
    _scale = -1.0f;
    _minScale = -1.0f;
    _pixelsPerHour = -1.0f;
}

#pragma mark - Getters and Setters

- (void)setHour:(NSInteger)hour {

    BOOL changing = _hour = hour;
    _hour = hour;

    if (changing) {
        [self updateHalfHourLine];
        [self updateHourLabel];
    }
}

- (void)setScale:(CGFloat)scale {

    BOOL changing = _scale != scale;
    _scale = scale;

    if (changing) {
        [self updateAlpha];
    }
}

- (void)setMinScale:(CGFloat)minScale {

    BOOL changing = _minScale != minScale;
    _minScale = minScale;

    if (changing) {
        [self updateAlpha];
    }
}

- (void)setPixelsPerHour:(CGFloat)pixelsPerHour {
    BOOL changing = _pixelsPerHour != pixelsPerHour;
    _pixelsPerHour = pixelsPerHour;

    if (changing) {
        [self updateHalfHourLine];
    }
}

#pragma mark - UICollectionViewCell methods

- (void)layoutSubviews {
    [self buildLayoutIfNecessary];
    [super layoutSubviews];
}

#pragma mark - Layout

- (void)buildLayoutIfNecessary {

    if (self.hourLabel == nil) {
        [self buildLayout];
    }
}

- (void)buildLayout {

    self.backgroundColor = [UIColor clearColor];

    [self buildHourLine];
    [self buildHalfHourLine];
    [self buildHourLabel];
    [self buildQuarterHourLabel];
    [self buildHalfHourLabel];
    [self buildThreeQuarterHourLabel];

    [self updateHourLabel];
    [self updateHalfHourLine];

//    [self DEBUG_colorizeSelfAndSubviews];
}

- (void)buildHourLine {

    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat height = 1.0f / scale;

    self.hourLine = [[UIView alloc] init];
    self.hourLine.translatesAutoresizingMaskIntoConstraints = NO;
    self.hourLine.backgroundColor = [UIColor colorWithRGBHex:0xB2B2B2];

    [self.contentView addSubview:self.hourLine];

    [NSLayoutConstraint
     addWidthConstraint:CGRectGetWidth(self.frame) - self.hourGutterWidth
     toView:self.hourLine];

    [NSLayoutConstraint addHeightConstraint:height toView:self.hourLine];
    [NSLayoutConstraint alignToLeft:self.hourLine withPadding:self.hourGutterWidth];
    [NSLayoutConstraint alignToTop:self.hourLine withPadding:self.hourPosition];
}

- (void)buildHalfHourLine {

    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat height = 1.0f / scale;

    self.halfHourLine = [[UIView alloc] init];
    self.halfHourLine.translatesAutoresizingMaskIntoConstraints = NO;
    self.halfHourLine.backgroundColor = [UIColor colorWithRGBHex:0xE5E5E5];

    [self.contentView addSubview:self.halfHourLine];

    [NSLayoutConstraint
     addWidthConstraint:CGRectGetWidth(self.frame) - self.hourGutterWidth
     toView:self.halfHourLine];

    [NSLayoutConstraint addHeightConstraint:height toView:self.halfHourLine];
    [NSLayoutConstraint alignToLeft:self.halfHourLine withPadding:self.hourGutterWidth];

    self.halfHourLineTopSpace =
    [NSLayoutConstraint alignToTop:self.halfHourLine withPadding:self.hourPosition + self.pixelsPerHour/2.0f];
}

- (void)buildHourLabel {

    self.hourLabel = [[UILabel alloc] init];
    self.hourLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.hourLabel.font = [UIFont systemFontOfSize:8.0f];
    self.hourLabel.textColor = [UIColor blackColor];
    self.hourLabel.textAlignment = NSTextAlignmentRight;
    self.hourLabel.backgroundColor = [UIColor clearColor];

    [self.contentView addSubview:self.hourLabel];

    [NSLayoutConstraint addWidthConstraint:self.hourGutterWidth-2.0f toView:self.hourLabel];
    [NSLayoutConstraint addHeightConstraint:21.0f toView:self.hourLabel];
    [NSLayoutConstraint alignToLeft:self.hourLabel withPadding:0.0f];
    [NSLayoutConstraint alignToTop:self.hourLabel withPadding:0.0f];
}

- (void)buildQuarterHourLabel {

}

- (void)buildHalfHourLabel {

}

- (void)buildThreeQuarterHourLabel {

}

#pragma mark -

- (void)updateAlpha {

    CGFloat minScale = 0.0f;

    if (self.hour % 2 != 0) {
        minScale = kPBCalendarEvenHourMinScale;
    } else if (self.hour % 4 != 0) {
        minScale = kPBCalendarQuarterHourMinScale;
    }

    if (minScale > 0.0f) {

        if (self.isPinching) {

            [UIView
             animateWithDuration:.3
             animations:^{
                 self.item.alpha = self.scale <= minScale ? 0.0f : 1.0f;
                 self.alpha = self.item.alpha;
             }];

        } else {
            self.item.alpha = self.scale <= minScale ? 0.0f : 1.0f;
            self.alpha = self.item.alpha;
        }
    }
}

- (void)updateHalfHourLine {

    BOOL hidden =
    self.scale < kPBCalendarHalfHourMinScale || self.hour == 24;

    CGFloat alpha = hidden ? 0.0f : 1.0f;

    if (hidden == NO) {
        self.halfHourLineTopSpace.constant = self.hourPosition + self.pixelsPerHour/2.0f;
        [self.halfHourLine layoutIfNeeded];
    }

    if (self.isPinching) {

        [UIView
         animateWithDuration:.3
         animations:^{
             self.halfHourLine.alpha = alpha;
         }];

    } else {

        self.halfHourLine.alpha = alpha;
    }
}

- (void)updateHourLabel {

    BOOL am = YES;

    NSInteger hour = self.hour;

    if (hour == 24 || hour == 0) {
        hour = 12;
    } else if (hour == 12) {
        am = NO;
    } else if (hour > 12) {
        hour -= 12;
        am = NO;
    }

    NSString *period = am ? PBLoc(@"AM") : PBLoc(@"PM");

    self.hourLabel.text =
    [NSString stringWithFormat:@"%ld %@", (long)hour, period];
}

@end
