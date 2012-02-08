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
const CGFloat FSV_PULL_OUT_DISTANCE_FOR_ALL_BASE = 10.0;

@interface FSV_MiddleLayer : CALayer
@property (nonatomic) CGFloat pointHeight;
@end
@implementation FSV_MiddleLayer
@synthesize pointHeight=_pointHeight;
- (void)setPointHeight:(CGFloat)pointHeight {
    if (_pointHeight != pointHeight) {
        _pointHeight = pointHeight;
        [self setNeedsDisplay];
    }
}
- (void)drawInContext:(CGContextRef)ctx {
    NSLog(@"FSV_MiddleLayer drawInContext");
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, 0, self.bounds.size.height - self.pointHeight);
    CGContextAddLineToPoint(ctx, self.bounds.size.width / 2.0, self.bounds.size.height);
    CGContextAddLineToPoint(ctx, self.bounds.size.width, self.bounds.size.height - self.pointHeight);
    CGContextAddLineToPoint(ctx, self.bounds.size.width, 0);
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor feelingColor].CGColor);
    CGContextFillPath(ctx);
}
@end

typedef enum {
    FSV_SideLayer_Left = 1,
    FSV_SideLayer_Right = 2,
} FSV_SideLayer_Side;
@interface FSV_SideLayer : CALayer
@property (nonatomic) CGFloat paddingBottom;
@property (nonatomic) CGFloat wedgeHeight;
@property (nonatomic) CGFloat wedgeWidth;
@property (nonatomic) FSV_SideLayer_Side side;
@end
@implementation FSV_SideLayer
@synthesize paddingBottom=_paddingBottom, wedgeHeight=_wedgeHeight, wedgeWidth=_wedgeWidth, side=_side;
- (void)setPaddingBottom:(CGFloat)paddingBottom {
    _paddingBottom = paddingBottom;
    [self setNeedsDisplay];
}
- (void)setWedgeHeight:(CGFloat)wedgeHeight {
    _wedgeHeight = wedgeHeight;
    [self setNeedsDisplay];
}
- (void)setWedgeWidth:(CGFloat)wedgeWidth {
    _wedgeWidth = wedgeWidth;
    [self setNeedsDisplay];
}
- (void)setSide:(FSV_SideLayer_Side)side {
    _side = side;
    [self setNeedsDisplay];
}
- (void)drawInContext:(CGContextRef)ctx {
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 0, 0);
    CGFloat drawingHeight = self.bounds.size.height - self.paddingBottom;
    CGContextAddLineToPoint(ctx, 0, drawingHeight - (self.side == FSV_SideLayer_Left ? self.wedgeHeight : 0));
    CGContextAddLineToPoint(ctx, self.wedgeWidth, drawingHeight);
    CGContextAddLineToPoint(ctx, self.bounds.size.width - (self.side == FSV_SideLayer_Right ? self.wedgeWidth : 0), drawingHeight);
    CGContextAddLineToPoint(ctx, self.bounds.size.width, drawingHeight - self.wedgeHeight);
    CGContextAddLineToPoint(ctx, self.bounds.size.width, 0);
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, self.side == FSV_SideLayer_Left ? [UIColor emotishColor].CGColor : [UIColor userColor].CGColor);
    CGContextFillPath(ctx);
}
@end

@interface FlagStretchView()
- (void) initWithFrameOrCoder;
//@property (unsafe_unretained, nonatomic, readonly) NSArray * randomPositionIncrements;
@property (nonatomic, readonly) CGFloat oneThirdWidth;
@property (nonatomic, readonly) CGFloat oneFifthWidth;
@property (strong, nonatomic) FSV_MiddleLayer * stripeMiddleLayer;
@property (strong, nonatomic) FSV_SideLayer * stripeLeftLayer;
@property (strong, nonatomic) FSV_SideLayer * stripeRightLayer;
@end

@implementation FlagStretchView

@synthesize icon=_icon;
@synthesize iconDistanceFromBottom=_iconDistanceFromBottom, iconFlipDistance=_iconFlipDistance, iconFlipDistanceAdjustment=_iconFlipDistanceAdjustment, iconFlipAnimationDuration=_iconFlipAnimationDuration, iconFlipped=_iconFlipped;
@synthesize angledShapes=_angledShapes, pullOutSides=_pullOutSides, pullOutMiddle=_pullOutMiddle;
@synthesize pulledOutDistance=_pulledOutDistance, pullOutDistanceAllowedForAll=_pullOutDistanceAllowedForAll;
@synthesize stripeMiddleLayer=_stripeMiddleLayer, stripeLeftLayer=_stripeLeftLayer, stripeRightLayer=_stripeRightLayer;

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
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.clipsToBounds = NO;
    
    self.iconFlipped = NO;
    self.iconDistanceFromBottom = 20.0;
    self.iconFlipDistanceAdjustment = 0.0;
    self.iconFlipAnimationDuration = 0.2;
    
    self.pullOutSides = YES;
    self.pullOutMiddle = YES;
    self.pulledOutDistance = 0;
    
    self.stripeMiddleLayer = [FSV_MiddleLayer layer];
    CGFloat horizontalPaddingForStripeMiddleLayer = self.oneThirdWidth - self.oneFifthWidth;
    self.stripeMiddleLayer.frame = CGRectMake(horizontalPaddingForStripeMiddleLayer, 0, self.bounds.size.width - 2 * horizontalPaddingForStripeMiddleLayer, self.bounds.size.height);
    self.stripeMiddleLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.stripeMiddleLayer];
    
    self.stripeLeftLayer = [FSV_SideLayer layer];
    self.stripeLeftLayer.frame = CGRectMake(0, 0, self.oneThirdWidth, self.bounds.size.height);
    self.stripeLeftLayer.side = FSV_SideLayer_Left;
    self.stripeLeftLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.stripeLeftLayer];
    
    self.stripeRightLayer = [FSV_SideLayer layer];
    self.stripeRightLayer.frame = CGRectMake(self.bounds.size.width - self.oneThirdWidth, 0, self.oneThirdWidth, self.bounds.size.height);
    self.stripeRightLayer.side = FSV_SideLayer_Right;
    self.stripeRightLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.stripeRightLayer];
    
    self.icon = [CALayer layer];
    UIImage * iconImage = [UIImage imageNamed:@"flag_stretch_arrow.png"];
    self.icon.frame = CGRectMake(0, 0, iconImage.size.width, iconImage.size.height);
    self.icon.contents = (__bridge id)iconImage.CGImage;
    self.icon.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.icon];
   
    self.angledShapes = YES;
    
}

//- (void) resetStripePositions {
//    
//    CGFloat oneThirdWidthRoundedDown = floorf(self.frame.size.width / 3.0);
//    self.stripeLeft.frame = CGRectMake(-self.frame.size.width + oneThirdWidthRoundedDown, self.stripeLeft.frame.origin.y, self.frame.size.width, self.stripeLeft.frame.size.height);
//    self.stripeRight.frame = CGRectMake(self.frame.size.width - oneThirdWidthRoundedDown, self.stripeRight.frame.origin.y, self.frame.size.width, self.stripeRight.frame.size.height);
//    [self layoutSubviews];
//    
//}

- (void)layoutSubviews {
//    CGRect boundsDrawing = self.boundsDrawing;
//    CGFloat screenHeight = self.maximumPullOutDistance;
//    CGFloat stripeHeight = screenHeight + self.frame.size.height - self.paddingBottom;
//    self.stripeLeft.frame = CGRectMake(self.stripeLeft.frame.origin.x, -screenHeight, self.frame.size.width, stripeHeight);
//    self.stripeRight.frame = CGRectMake(self.stripeRight.frame.origin.x, -screenHeight, self.frame.size.width, stripeHeight);
////    CGFloat stripeLeftMaxX = CGRectGetMaxX(self.stripeLeft.frame);
////    CGFloat arrowX = stripeLeftMaxX + floorf((self.stripeRight.frame.origin.x - stripeLeftMaxX - self.icon.frame.size.width) / 2.0);
////    self.icon.frame = CGRectMake(arrowX, self.stripeMiddle.frame.size.height - self.iconDistanceFromBottom - self.icon.frame.size.height, self.icon.frame.size.width, self.icon.frame.size.height);
    [CATransaction setAnimationDuration:0.0];
    if (!self.pullOutSides) {
        self.stripeLeftLayer.frame = CGRectMake(self.stripeLeftLayer.frame.origin.x, MIN(0, -self.pulledOutDistance + self.pullOutDistanceAllowedForAll), self.stripeLeftLayer.frame.size.width, self.stripeLeftLayer.frame.size.height);
        self.stripeRightLayer.frame = CGRectMake(self.stripeRightLayer.frame.origin.x, MIN(0, -self.pulledOutDistance + self.pullOutDistanceAllowedForAll), self.stripeRightLayer.frame.size.width, self.stripeRightLayer.frame.size.height);
//        NSLog(@"pulledOutDistance = %f", self.pulledOutDistance);
//        NSLog(@"pullOutDistanceAllowedForAll = %f", self.pullOutDistanceAllowedForAll);
//        NSLog(@"%@", NSStringFromCGRect(self.stripeLeftLayer.frame));
    }
    if (!self.pullOutMiddle) {
        self.stripeMiddleLayer.frame = CGRectMake(self.stripeMiddleLayer.frame.origin.x, MIN(0, -self.pulledOutDistance + self.pullOutDistanceAllowedForAll), self.stripeMiddleLayer.frame.size.width, self.stripeMiddleLayer.frame.size.height);
    }
    self.icon.frame = CGRectMake((self.bounds.size.width - self.icon.frame.size.width) / 2.0, CGRectGetMaxY(self.stripeMiddleLayer.frame) - self.iconDistanceFromBottom - self.icon.frame.size.height, self.icon.frame.size.width, self.icon.frame.size.height);
}

//- (CGRect)boundsDrawing {
//    return CGRectMake(self.paddingSides, 0, self.frame.size.width - 2 * self.paddingSides, self.frame.size.height - self.paddingBottom);
//}
//
//- (CGRect)frameDrawing {
//    return CGRectOffset(self.boundsDrawing, self.frame.origin.x, self.frame.origin.y);
//}

//- (void)setPaddingBottom:(CGFloat)paddingBottom {
//    _paddingBottom = paddingBottom;
//    [self setNeedsLayout];
//}

- (void)setIconDistanceFromBottom:(CGFloat)iconDistanceFromBottom {
    _iconDistanceFromBottom=iconDistanceFromBottom;
    [self setNeedsLayout];
}

- (void)startAnimatingStripes {
    // ...
    // ...
    // ...
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
    // ...
    // ...
    // ...
}

- (CGFloat)iconFlipDistance {
//    NSLog(@"iconFlipDistance = self.iconDistanceFromBottom (%f) + self.icon.frame.size.height (%f) + self.iconDistanceFromBottom (%f) + self.iconFlipDistanceAdjustment (%f) = %f", self.iconDistanceFromBottom, self.icon.frame.size.height, self.iconDistanceFromBottom, self.iconFlipDistanceAdjustment, self.iconDistanceFromBottom + self.icon.frame.size.height + self.iconDistanceFromBottom + self.iconFlipDistanceAdjustment);
    return self.iconDistanceFromBottom + self.icon.frame.size.height + self.iconDistanceFromBottom + self.iconFlipDistanceAdjustment;
}

- (void)setIconFlipped:(BOOL)iconFlipped animated:(BOOL)animated {
    if (_iconFlipped != iconFlipped) {
        _iconFlipped = iconFlipped;
        [CATransaction setAnimationDuration:animated ? self.iconFlipAnimationDuration : 0.0]; 
        self.icon.transform = CATransform3DMakeRotation(self.iconFlipped ? M_PI : 0, 1.0, 0, 0);
    }
}

- (void)setIconFlipped:(BOOL)iconFlipped {
    [self setIconFlipped:iconFlipped animated:NO];
}

- (void)setPulledOutDistance:(CGFloat)pullOutDistance {
//    NSLog(@"setPullOutDistance:%f", pullOutDistance);
    if (_pulledOutDistance != pullOutDistance) {
//        NSLog(@"setPullOutDistance changed");
        _pulledOutDistance = pullOutDistance;
        [self setNeedsLayout];
    }
}

- (void)setAngledShapes:(BOOL)angledShapes {
    if (_angledShapes != angledShapes) {
        _angledShapes = angledShapes;
    }
    self.stripeMiddleLayer.pointHeight = self.angledShapes ? (2 * self.oneFifthWidth + self.oneThirdWidth) * 3.0 / 8.0 : 0.0;
    CGFloat sidesPaddingBottom = 0;
    CGFloat sidesWedgeWidth = 0;
    CGFloat sidesWedgeHeight = 0;
    if (self.angledShapes) {
        sidesPaddingBottom = self.stripeMiddleLayer.pointHeight;
        sidesWedgeWidth = self.oneThirdWidth - self.oneFifthWidth;
        sidesWedgeHeight = (self.stripeLeftLayer.wedgeWidth) * 3.0 / 4.0;
    }
    self.stripeLeftLayer.paddingBottom = sidesPaddingBottom;
    self.stripeLeftLayer.wedgeWidth = sidesWedgeWidth;
    self.stripeLeftLayer.wedgeHeight = sidesWedgeHeight;
    self.stripeRightLayer.paddingBottom = sidesPaddingBottom;
    self.stripeRightLayer.wedgeWidth = sidesWedgeWidth;
    self.stripeRightLayer.wedgeHeight = sidesWedgeHeight;
    self.pullOutDistanceAllowedForAll = self.stripeMiddleLayer.pointHeight + sidesWedgeHeight + FSV_PULL_OUT_DISTANCE_FOR_ALL_BASE;
    // THE FOLLOWING IS TO FIX AN ANIMATION STUTTER WHEN FLIPPING THE ICON OVER A CUSTOM DRAWN CALayer. NOT SURE WHY IT'S HAPPENING. HIDING IT IN MOST CASES BY HIDING THE MIDDLE CUSTOM DRAWN LAYER WHEN NOT USING ANGLED SHAPES (AND USING A BACKGROUND COLOR ON THE VIEW FOR THE MIDDLE STRIPE INSTEAD).
    self.stripeMiddleLayer.hidden = !self.angledShapes;
    self.backgroundColor = self.angledShapes ? [UIColor whiteColor] : [UIColor feelingColor];
}

- (CGFloat)oneThirdWidth { return floorf(self.bounds.size.width / 3.0); }
- (CGFloat)oneFifthWidth { return floorf(self.bounds.size.width / 5.0); }

@end
