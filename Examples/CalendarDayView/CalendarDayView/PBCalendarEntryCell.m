//
//  PBCalendarEntryCell.m
//  Sometime
//
//  Created by Nick Bolton on 12/20/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBCalendarEntryCell.h"

@interface PBCalendarEntryCell()

@end

@implementation PBCalendarEntryCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self setupPrimaryLabel];
    [self setupSecondaryLabel];
    [self setupNotesLabel];
    [self setupTimerContainer];
}

#pragma mark - Setup

- (void)setupPrimaryLabel {

    self.primaryLabel.text = nil;
    self.primaryLabel.textColor = [UIColor whiteColor];
    self.primaryLabel.font = [UIFont boldSystemFontOfSize:17.0f];
}

- (void)setupSecondaryLabel {

    self.secondaryLabel.text = nil;
    self.secondaryLabel.textColor = [UIColor whiteColor];
    self.secondaryLabel.font =
    [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
}

- (void)setupNotesLabel {

    self.notesLabel.text = nil;
    self.notesLabel.textColor = [UIColor whiteColor];
    self.notesLabel.font = [UIFont systemFontOfSize:11.0f];
    self.notesLabel.numberOfLines = 0;
}

- (void)setupTimerContainer {

    self.editControlsContainer.alpha = 0.0f;
    self.doneImageView.alpha = 0.0f;

    self.timerContainer.layer.cornerRadius = 2.0f;
}

#pragma mark - Getters and Setters

- (void)setEditMode:(BOOL)editMode {
    _editMode = editMode;

    CGFloat editControlsAlpha = editMode ? 1.0f : 0.0f;
    CGFloat editAlpha = editMode ? 0.0f : 1.0f;

    self.editImageView.alpha = editAlpha;
    self.doneImageView.alpha = editControlsAlpha;
    self.editControlsContainer.alpha = editControlsAlpha;
}

#pragma mark - Public

- (void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timerContentContainer addFadingMaskWithEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 8.0f, 0.0f)];
    });
}

- (void)updatePrimaryLabel:(NSString *)primaryLabel
            secondaryLabel:(NSString *)secondaryLabel
                notesLabel:(NSString *)notesLabel {

    self.primaryLabel.text = primaryLabel;
    self.secondaryLabel.text = secondaryLabel;

    [self updateNotes:notesLabel];
}

- (void)updateNotes:(NSString *)notes {

    CGSize size = CGSizeMake(CGRectGetWidth(self.notesLabel.frame), MAXFLOAT);

    NSMutableParagraphStyle *paragraphStyle =
    [[NSMutableParagraphStyle alloc] init];

    paragraphStyle.minimumLineHeight = 15.0f;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;

    NSDictionary *attributes =
    @{
      NSFontAttributeName : self.notesLabel.font,
      NSParagraphStyleAttributeName : paragraphStyle
      };

    CGRect boundingRect =
    [notes
     boundingRectWithSize:size
     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
     attributes:attributes
     context:nil];

    self.notesLabelHeight.constant = CGRectGetHeight(boundingRect);
    [self.notesLabel layoutIfNeeded];

    if (notes != nil) {
        self.notesLabel.attributedText =
        [[NSAttributedString alloc]
         initWithString:notes
         attributes:attributes];
    }
}


@end
