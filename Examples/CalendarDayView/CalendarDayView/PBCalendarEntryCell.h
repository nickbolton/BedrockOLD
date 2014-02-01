//
//  PBCalendarEntryCell.h
//  Sometime
//
//  Created by Nick Bolton on 12/20/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBCollectionDefaultCell.h"

@interface PBCalendarEntryCell : PBCollectionDefaultCell

@property (nonatomic, weak) IBOutlet UIView *timerContainer;
@property (nonatomic, weak) IBOutlet UIView *timerContentContainer;
@property (nonatomic, weak) IBOutlet UIView *editControlsContainer;
@property (nonatomic, weak) IBOutlet UILabel *primaryLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondaryLabel;
@property (nonatomic, weak) IBOutlet UILabel *notesLabel;
@property (nonatomic, weak) IBOutlet UIImageView *editImageView;
@property (nonatomic, weak) IBOutlet UIImageView *doneImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *notesLabelHeight;

@property (nonatomic) BOOL editMode;

- (void)updatePrimaryLabel:(NSString *)primaryLabel
            secondaryLabel:(NSString *)secondaryLabel
                notesLabel:(NSString *)notesLabel;

@end
