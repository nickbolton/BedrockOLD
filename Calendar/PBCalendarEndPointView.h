//
//  PBCalendarEndPointView.h
//  Pods
//
//  Created by Nick Bolton on 4/23/14.
//
//

#import <UIKit/UIKit.h>

@interface PBCalendarEndPointView : UIView

@property (nonatomic, readonly) CGFloat radius;

- (id)initSmall;
- (id)initLarge;

@property (nonatomic, strong) NSLayoutConstraint *leadingSpace;
@property (nonatomic, strong) NSLayoutConstraint *topSpace;
@property (nonatomic, readonly) NSLayoutConstraint *labelLeadingSpace;

- (void)updateEndPointLabel:(NSDate *)date;
- (void)beSmall;

@end
