//
//  FlagStretchView.h
//  Emotish
//
//  Created by Dan Bretl on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FlagStretchView : UIView

@property (nonatomic) CGFloat paddingBottom;
@property (nonatomic) CGFloat arrowDistanceFromBottom;
@property (readonly, nonatomic) CGFloat arrowFlipDistance;
@property (nonatomic) CGFloat arrowFlipDistanceAdjustment;
@property (nonatomic) CFTimeInterval arrowFlipAnimationDuration;

@property (strong, nonatomic) CALayer * stripeLeft;
@property (strong, nonatomic) CALayer * stripeMiddle;
@property (strong, nonatomic) CALayer * stripeRight;

@property (strong, nonatomic) CALayer * arrow;
@property (nonatomic) BOOL arrowFlipped;

- (void) setArrowFlipped:(BOOL)flipped animated:(BOOL)animated;

- (void) resetStripePositions;
- (void) startAnimatingStripes;
- (void) stopAnimatingStripes;

@end
