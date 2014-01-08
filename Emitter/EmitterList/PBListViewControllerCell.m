//
//  PBListViewControllerCell.m
//  Bedrock
//
//  Created by Nick Bolton on 1/7/14.
//  Copyright (c) 2014 Pixelbleed. All rights reserved.
//

#import "PBListViewControllerCell.h"
#import "PBListViewController.h"

@implementation PBListViewControllerCell

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.viewController.view removeFromSuperview];
    [self.viewController removeFromParentViewController];
}

@end
