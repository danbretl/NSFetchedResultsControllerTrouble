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

@property (strong, nonatomic) CALayer * icon;
@property (nonatomic) CGFloat iconDistanceFromBottom;

@property (nonatomic) BOOL activated;
@property (nonatomic) BOOL activationAffectsAlpha;
@property (nonatomic) CGFloat sidesAlphaNormal;
@property (nonatomic) CGFloat sidesAlphaActivated;
@property (nonatomic) CGFloat middleAlphaNormal;
@property (nonatomic) CGFloat middleAlphaActivated;
@property (nonatomic) BOOL activationAffectsIcon;
@property (nonatomic) CGFloat activationDistanceStart;
@property (nonatomic) CGFloat activationDistanceEnd;
@property (nonatomic) CFTimeInterval activationAnimationDuration;

@property (nonatomic) BOOL angledShapes;
@property (nonatomic) BOOL pullOutSides;
@property (nonatomic) BOOL pullOutMiddle;
@property (nonatomic) CGFloat pulledOutDistance;
@property (nonatomic) CGFloat pullOutDistanceAllowedForAll;

- (void) setActivated:(BOOL)flipped animated:(BOOL)animated;

//- (void) resetStripePositions;
- (void) startAnimatingStripes;
- (void) stopAnimatingStripes;

@end
