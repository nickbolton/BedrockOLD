//
//  PBListCell.h
//  Bedrock
//
//  Created by Nick Bolton on 11/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewDefaultCell.h"

@interface PBListCell : PBListViewDefaultCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@property (nonatomic) BOOL valueMarginAdjusted;

@end
