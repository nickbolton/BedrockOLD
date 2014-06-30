//
//  PBListViewDefaultCell.m
//  Pods
//
//  Created by Nick Bolton on 12/9/13.
//
//

#import "PBListViewDefaultCell.h"
#import "PBListItem.h"
#import "NSLayoutConstraint+Bedrock.h"
#import "PBListViewController.h"

@interface PBListViewDefaultCell()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *highlightedColorView;

@end

@implementation PBListViewDefaultCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.item = nil;

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
        [self.contentView insertSubview:self.backgroundImageView atIndex:0];
        [NSLayoutConstraint expandToSuperview:self.backgroundImageView];
    }

    return _backgroundImageView;
}

- (UIView *)highlightedColorView {

    if (_highlightedColorView == nil) {

        self.highlightedColorView = [[UIView alloc] init];
        self.highlightedColorView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView insertSubview:self.highlightedColorView atIndex:0];
        [NSLayoutConstraint expandToSuperview:self.highlightedColorView];
    }

    return _highlightedColorView;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
}

- (void)updateForSelectedState {

    [self updateBackoundImage];

    self.item.selected = self.isSelected;

    if (self.item.checkedType == PBItemCheckedTypeAll ||
        self.item.checkedType == PBItemCheckedTypeSingle) {

        if (self.isSelected) {

            if (self.item.selectionAccessoryNib != nil) {

                if (CGSizeEqualToSize(self.item.selectionAccessorySize, CGSizeZero)) {
                    PBLog(@"WARN : item selectionAccessorySize not set");
                }

            } else if (self.item.selectionAccessoryClass != NULL) {

                if (CGSizeEqualToSize(self.item.selectionAccessorySize, CGSizeZero)) {
                    PBLog(@"WARN : item selectionAccessorySize not set");
                }

                CGRect frame = CGRectZero;
                frame.size = self.item.selectionAccessorySize;

                self.accessoryView =
                [[self.item.selectionAccessoryClass alloc]
                 initWithFrame:frame];

            } else {
                self.accessoryType = UITableViewCellAccessoryCheckmark;
            }

        } else {

            if (self.item.selectionAccessoryNib != nil ||
                self.item.selectionAccessoryClass != NULL) {

                self.accessoryView = nil;
            } else {
                self.accessoryType = UITableViewCellAccessoryNone;
            }
        }

        [self setNeedsDisplay];
    }

    if (self.item.selectionDisabled == NO) {

        if (self.isSelected) {
            
            if (self.item.selectActionBlock != nil) {
                    
                    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                    
                    NSTimeInterval delayInSeconds = .1f;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                        self.item.selectActionBlock(self);
                    });
                }
            
        } else {
            
            if (self.item.deselectActionBlock != nil) {
                
                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                
                NSTimeInterval delayInSeconds = .1f;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    self.item.deselectActionBlock(self);
                });
            }
        }
    }

    self.item.selectionDisabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    if (self.viewController.isDragging == NO) {
        
        if (self.isSelected != selected) {
            
            [super setSelected:selected animated:animated];
            [self updateForSelectedState];
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self updateBackoundImage];
    [self updateHightlightedState:animated];
}

- (void)updateHightlightedState:(BOOL)animated {

    if (self.item != nil) {
        
        if (self.item.isEnabled) {
            
            if (self.item.highlightedOverlayAlpha < 1.0f &&
                self.item.highlightedOverlayColor != nil) {
                
                if (self.isHighlighted) {
                    
                    self.highlightedColorView.hidden = NO;
                    self.highlightedColorView.backgroundColor =
                    self.item.highlightedOverlayColor;
                    
                    [self.highlightedColorView.superview
                     bringSubviewToFront:self.highlightedColorView];
                    
                    self.highlightedColorView.alpha = self.item.highlightedOverlayAlpha;
                    
                } else {
                    
                    self.highlightedColorView.hidden = YES;
                }
            } else if (self.item.highlightedContentAlpha < 1.0f) {
                
                CGFloat alpha = self.isHighlighted ? .5f : 1.0f;
                NSTimeInterval duration = animated ? .15f : 0.0f;
                
                [UIView
                 animateWithDuration:duration
                 animations:^{
                     
                     self.contentView.alpha = alpha;
                 }];
            }
            
        } else {
            
            self.contentView.alpha = .5f;
        }
    }
}

- (void)updateBackoundImage {

    if (self.isHighlighted) {

        if (self.isSelected) {

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

        if (self.isSelected) {

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
    self.item = nil;
}

- (void) layoutSubviews {
    [super layoutSubviews];

    CGRect frame = self.textLabel.frame;
    CGFloat xdiff = self.item.titleMargin - CGRectGetMinX(frame);

    frame.origin.x += xdiff;
    frame.size.width -= xdiff;
    self.textLabel.frame = frame;
}

@end
