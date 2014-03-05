//
//  PBListViewExpandableCell.h
//  Pods
//
//  Created by Nick Bolton on 3/5/14.
//
//

#import "PBListCell.h"

@interface PBListViewExpandableCell : PBListCell

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *defaultCellHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleLeadingSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *valueTrailingSpace;

@end
