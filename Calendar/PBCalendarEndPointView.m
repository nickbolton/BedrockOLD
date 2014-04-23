//
//  PBCalendarEndPointView.m
//  Pods
//
//  Created by Nick Bolton on 4/23/14.
//
//

#import "PBCalendarEndPointView.h"

static CGFloat const kPBCalendarEndPointViewSmallRadius = 16.0f;
static CGFloat const kPBCalendarEndPointViewLargeRadius = 32.0f;

@interface PBCalendarEndPointView()

@property (nonatomic, strong) UILabel *endPointLabel;
@property (nonatomic, readwrite) NSLayoutConstraint *labelLeadingSpace;
@property (nonatomic, strong) NSLayoutConstraint *labelTopSpace;
@property (nonatomic, strong) NSLayoutConstraint *width;
@property (nonatomic, strong) NSLayoutConstraint *height;
@property (nonatomic) BOOL large;
@property (nonatomic, readwrite) CGFloat radius;
@property (nonatomic, strong) NSDate *date;

@end

@implementation PBCalendarEndPointView

- (id)initSmall {

    self = [self init];
    
    if (self != nil) {
        self.radius = kPBCalendarEndPointViewSmallRadius;
        self.large = NO;
        [self commonInit];
    }
    
    return self;
}

- (id)initLarge {
    
    self = [self init];
    
    if (self != nil) {
        self.radius = kPBCalendarEndPointViewLargeRadius;
        self.large = YES;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    
    self.alpha = .9f;
    self.clipsToBounds = YES;
    
    self.layer.cornerRadius = self.radius;
    
    self.endPointLabel = [[UILabel alloc] init];
    self.endPointLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.endPointLabel.textAlignment = NSTextAlignmentCenter;
    self.endPointLabel.textColor = [UIColor whiteColor];
    
    [self addSubview:self.endPointLabel];
    
    [NSLayoutConstraint expandToSuperview:self.endPointLabel];
}

#pragma mark - Public

- (void)beSmall {
    self.large = NO;
    self.radius = kPBCalendarEndPointViewSmallRadius;
    [self updateEndPointLabel:self.date];
}

- (void)updateEndPointLabel:(NSDate *)date {
    
    self.date = date;
    
    CGFloat size = self.large ? 32.0f : 16.0f;
    
    if ([date.midnight isEqualToDate:[[NSDate date] midnight]]) {
        self.endPointLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
    } else {
        self.endPointLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
    }
    
    NSDateComponents *day = [date components:NSCalendarUnitDay];
    
    self.endPointLabel.text = [NSString stringWithFormat:@"%ld", (long)day.day];
}

@end
