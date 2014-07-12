//
//  PBCollectionDefaultCell.m
//  Bedrock
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBCollectionDefaultCell.h"
#import "PBCollectionItem.h"
#import "PBCollectionSupplimentaryImageItem.h"
#import "PBCollectionViewController.h"

@interface PBCollectionDefaultCell() {
    
    NSTimeInterval _lastSelectedTime;
}

@property (nonatomic, readwrite) IBOutlet UIImageView *backgroundImageView;

@end

@implementation PBCollectionDefaultCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.item = nil;
    self.indexPath = nil;

    _backgroundImageView.image = nil;
}

- (UIImageView *)backgroundImageView {

    if (_backgroundImageView == nil) {

        self.backgroundImageView =
        [[UIImageView alloc]
         initWithImage:self.item.backgroundImage];

        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundView.alpha = 0.0;
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.backgroundImageView];
        [NSLayoutConstraint expandToSuperview:self.backgroundImageView];
    }

    return _backgroundImageView;
}

- (void)updateForSelectedState {

    [self updateBackoundImage];

    if (self.item.selectionDisabled == NO &&
        self.item.selectActionBlock != nil) {
        self.item.selectActionBlock(self, self.item.isSelected);
    }

    self.item.selectionDisabled = NO;
}

- (void)setSelected:(BOOL)selected {
    
    static NSTimeInterval const doubleTapThreshold = .05f;
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval diff = now - _lastSelectedTime;

    _lastSelectedTime = now;
    
    if (diff > doubleTapThreshold) {
        if (self.viewController.isDragging == NO) {
            
            if (self.viewController.isMultiSelect) {
                
                if (selected) {
                    self.item.selected = self.item.isSelected == NO;
                    [self updateForSelectedState];
                }
                
            } else {
                
                self.item.selected = selected;
                [super setSelected:selected];
                [self updateForSelectedState];
            }
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self updateBackoundImage];
}

- (void)updateBackoundImage {

    if (self.isHighlighted) {

        if (self.item.isSelected) {

            if (self.item.highlightedSelectedBackgroundImage != nil) {

                self.backgroundImageView.image =
                self.item.highlightedSelectedBackgroundImage;
            }

        } else {

            if (self.item.hightlightedBackgroundImage != nil) {

                self.backgroundImageView.image =
                self.item.hightlightedBackgroundImage;
            }
        }

    } else {

        if (self.item.isSelected) {

            if (self.item.selectedBackgroundImage != nil) {

                self.backgroundImageView.image =
                self.item.selectedBackgroundImage;
            }

        } else {

            if (self.item.backgroundImage != nil) {

                self.backgroundImageView.image =
                self.item.backgroundImage;
            }
        }
    }
}

- (void)willDisplayCell {
}

- (void)didEndDisplayingCell {
}

@end
