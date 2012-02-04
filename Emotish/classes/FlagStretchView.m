//
//  FlagStretchView.m
//  Emotish
//
//  Created by Dan Bretl on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlagStretchView.h"
#import "UIColor+Emotish.h"

#define ARC4RANDOM_MAX 0x100000000

@interface FlagStretchView()
- (void) initWithFrameOrCoder;
//@property (unsafe_unretained, nonatomic, readonly) NSArray * randomPositionIncrements;
@end

@implementation FlagStretchView

@synthesize arrowDistanceFromBottom=_arrowDistanceFromBottom;
@synthesize paddingBottom=_paddingBottom;
@synthesize stripeLeft=_stripeLeft, stripeMiddle=_stripeMiddle, stripeRight=_stripeRight;
@synthesize arrow=_arrow;
@synthesize arrowFlipDistance=_arrowFlipDistance, arrowFlipped=_arrowFlipped, arrowFlipDistanceAdjustment=_arrowFlipDistanceAdjustment, arrowFlipAnimationDuration=_arrowFlipAnimationDuration;
//@synthesize randomPositionIncrements=_randomPositionIncrements;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) { [self initWithFrameOrCoder]; }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) { [self initWithFrameOrCoder]; }
    return self;
}

- (void) initWithFrameOrCoder {
    
    self.clipsToBounds = NO;
    self.paddingBottom = 0.0;
    self.arrowDistanceFromBottom = 20.0;
    _arrowFlipped = NO;
    self.arrowFlipDistanceAdjustment = -5.0;
    self.arrowFlipAnimationDuration = 0.2;
    
    self.stripeMiddle = [CALayer layer];
    self.stripeMiddle.backgroundColor = [UIColor feelingColor].CGColor;
    self.stripeLeft = [CALayer layer];
    self.stripeLeft.backgroundColor = [UIColor userColor].CGColor;
    self.stripeRight = [CALayer layer];
    self.stripeRight.backgroundColor = [UIColor emotishColor].CGColor;
    [self.layer addSublayer:self.stripeMiddle];
    [self.layer addSublayer:self.stripeLeft];
    [self.layer addSublayer:self.stripeRight];
    [self resetStripePositions];
    
    self.arrow = [CALayer layer];
    UIImage * arrowImage = [UIImage imageNamed:@"flag_stretch_arrow.png"];
    self.arrow.frame = CGRectMake(0, 0, arrowImage.size.width, arrowImage.size.height);
    self.arrow.contents = (__bridge id)arrowImage.CGImage;
    [self.stripeMiddle addSublayer:self.arrow];
    
}

- (void) resetStripePositions {
    
    CGFloat oneThirdWidthRoundedDown = floorf(self.frame.size.width / 3.0);
    self.stripeMiddle.frame = CGRectMake(0, self.stripeMiddle.frame.origin.y, self.frame.size.width, self.stripeMiddle.frame.size.height);
    self.stripeLeft.frame = CGRectMake(-self.frame.size.width + oneThirdWidthRoundedDown, self.stripeLeft.frame.origin.y, self.frame.size.width, self.stripeLeft.frame.size.height);
    self.stripeRight.frame = CGRectMake(self.frame.size.width - oneThirdWidthRoundedDown, self.stripeRight.frame.origin.y, self.frame.size.width, self.stripeRight.frame.size.height);
    [self layoutSubviews];
    
}

- (void)layoutSubviews {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat stripeHeight = screenHeight + self.frame.size.height - self.paddingBottom;
    self.stripeMiddle.frame = CGRectMake(self.stripeMiddle.frame.origin.x, -screenHeight, self.frame.size.width, stripeHeight);
    self.stripeLeft.frame = CGRectMake(self.stripeLeft.frame.origin.x, -screenHeight, self.frame.size.width, stripeHeight);
    self.stripeRight.frame = CGRectMake(self.stripeRight.frame.origin.x, -screenHeight, self.frame.size.width, stripeHeight);
    CGFloat stripeLeftMaxX = CGRectGetMaxX(self.stripeLeft.frame);
    CGFloat arrowX = stripeLeftMaxX + floorf((self.stripeRight.frame.origin.x - stripeLeftMaxX - self.arrow.frame.size.width) / 2.0);
    self.arrow.frame = CGRectMake(arrowX, self.stripeMiddle.frame.size.height - self.arrowDistanceFromBottom - self.arrow.frame.size.height, self.arrow.frame.size.width, self.arrow.frame.size.height);
}

- (void)setPaddingBottom:(CGFloat)paddingBottom {
    _paddingBottom = paddingBottom;
    [self setNeedsLayout];
}

- (void)setArrowDistanceFromBottom:(CGFloat)arrowDistanceFromBottom {
    _arrowDistanceFromBottom=arrowDistanceFromBottom;
    [self setNeedsLayout];
}

- (void)startAnimatingStripes {
//    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    animation.repeatCount = INFINITY;
//    animation.duration = 1.0;
//    animation.fillMode = kCAFillModeForwards;
//    animation.additive = YES;
//    animation.toValue = [NSNumber numberWithFloat:5.0];
//    [self.stripeLeft addAnimation:animation forKey:@"animatePosition"];
//    [self.stripeRight addAnimation:animation forKey:@"animatePosition"];
}

- (void)stopAnimatingStripes {
    
}

- (CGFloat)arrowFlipDistance {
    return self.arrowDistanceFromBottom + self.arrow.frame.size.height + self.arrowDistanceFromBottom + self.arrowFlipDistanceAdjustment;
}

- (void)setArrowFlipped:(BOOL)flipped animated:(BOOL)animated {
    if (_arrowFlipped != flipped) {
        _arrowFlipped = flipped;
        [CATransaction setAnimationDuration:animated ? self.arrowFlipAnimationDuration : 0.0]; 
        self.arrow.transform = CATransform3DMakeRotation(self.arrowFlipped ? M_PI : 0, 1.0, 0, 0);
    }
}

- (void)setArrowFlipped:(BOOL)flipped {
    [self setArrowFlipped:flipped animated:NO];
}

//- (NSArray *)randomPositionIncrements {
//    NSMutableArray * randomPositionIncrements = [NSMutableArray array];
//    for (int i=0; i<50; i++) {
//        CGFloat randomPositionIncrement = 
//    }
//}

@end
