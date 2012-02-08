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

//@property (nonatomic, readonly) CGRect boundsDrawing;
//@property (nonatomic, readonly) CGRect frameDrawing;

@property (nonatomic) CGFloat iconDistanceFromBottom;
@property (nonatomic, readonly) CGFloat iconFlipDistance;
@property (nonatomic) CGFloat iconFlipDistanceAdjustment;
@property (nonatomic) CFTimeInterval iconFlipAnimationDuration;
@property (nonatomic) BOOL iconFlipped;

@property (nonatomic) BOOL angledShapes;
@property (nonatomic) BOOL pullOutSides;
@property (nonatomic) BOOL pullOutMiddle;
@property (nonatomic) CGFloat pulledOutDistance;
@property (nonatomic) CGFloat pullOutDistanceAllowedForAll;

- (void) setIconFlipped:(BOOL)flipped animated:(BOOL)animated;

//- (void) resetStripePositions;
- (void) startAnimatingStripes;
- (void) stopAnimatingStripes;

@end
