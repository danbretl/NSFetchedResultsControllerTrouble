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
@property (nonatomic) CGFloat paddingHorizontal; // Does not apply to the point
@property (nonatomic) CGFloat visibleWidth;
@property (nonatomic) CGFloat drainPercentage;
@property (nonatomic) CGFloat drainedBorderWidth;
//@property (nonatomic) BOOL shouldFill;
@end
@implementation FSV_MiddleLayer
@synthesize paddingHorizontal=_paddingHorizontal, pointHeight=_pointHeight,/*shouldFill=_shouldFill,*/ visibleWidth=_visibleWidth, drainPercentage=_drainPercentage, drainedBorderWidth=_drainedBorderWidth;
- (void)setPointHeight:(CGFloat)pointHeight {
    if (_pointHeight != pointHeight) {
        _pointHeight = pointHeight; [self setNeedsDisplay];
    }
}
- (void)setPaddingHorizontal:(CGFloat)paddingHorizontal {
    if (_paddingHorizontal != paddingHorizontal) {
        _paddingHorizontal = paddingHorizontal; [self setNeedsDisplay];
    }
}
- (void)setVisibleWidth:(CGFloat)visibleWidth {
    if (_visibleWidth != visibleWidth) {
        _visibleWidth = visibleWidth;
    }
}
- (void)setDrainPercentage:(CGFloat)drainPercentage {
    if (_drainPercentage != drainPercentage) {
        _drainPercentage = drainPercentage; [self setNeedsDisplay];
    }
}
//- (void)setShouldFill:(BOOL)shouldFill {
//    if (_shouldFill != shouldFill) {
//        _shouldFill = shouldFill; [self setNeedsDisplay];
//    }
//}
- (void)setBorderWidth:(CGFloat)drainedBorderWidth {
    if (_drainedBorderWidth != drainedBorderWidth) {
        _drainedBorderWidth = drainedBorderWidth; [self setNeedsDisplay];
    }
}
- (void)drawInContext:(CGContextRef)ctx {
    
    CGMutablePathRef outerArrowPath = CGPathCreateMutable();
    CGPathMoveToPoint(outerArrowPath, NULL, self.paddingHorizontal, 0);
    CGPathAddLineToPoint(outerArrowPath, NULL, self.paddingHorizontal, self.bounds.size.height - self.pointHeight);
    CGPathAddLineToPoint(outerArrowPath, NULL, 0, self.bounds.size.height - self.pointHeight);
    CGPathAddLineToPoint(outerArrowPath, NULL, self.bounds.size.width / 2.0, self.bounds.size.height);
    CGPathAddLineToPoint(outerArrowPath, NULL, self.bounds.size.width, self.bounds.size.height - self.pointHeight);
    CGPathAddLineToPoint(outerArrowPath, NULL, self.bounds.size.width - self.paddingHorizontal, self.bounds.size.height - self.pointHeight);
    CGPathAddLineToPoint(outerArrowPath, NULL, self.bounds.size.width - self.paddingHorizontal, 0);
    CGPathCloseSubpath(outerArrowPath);
    
//    if (!self.shouldFill) {
        CGContextSaveGState(ctx);
        CGContextSetStrokeColorWithColor(ctx, [UIColor feelingColor].CGColor);
        CGContextSetMiterLimit(ctx, 10.0); // Doesn't seem to have any effect. Solved by using clipping instead.
        CGContextSetLineJoin(ctx, kCGLineJoinMiter); // Doesn't seem to have any effect. Solved by using clipping instead.
        CGContextSetLineCap(ctx, kCGLineCapSquare); // Doesn't seem to have any effect. Solved by using clipping instead.
        CGContextSetLineWidth(ctx, self.drainedBorderWidth);
        CGContextAddPath(ctx, outerArrowPath);
        CGContextClip(ctx);
        CGContextAddPath(ctx, outerArrowPath);
        CGContextDrawPath(ctx, kCGPathStroke);
        CGContextRestoreGState(ctx);
//    }
    
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - (self.visibleWidth * self.drainPercentage)));
    CGContextAddPath(ctx, outerArrowPath);
    CGContextSetFillColorWithColor(ctx, [UIColor feelingColor].CGColor);
    CGContextDrawPath(ctx, kCGPathFill);
    CGContextRestoreGState(ctx);
    
    CGPathRelease(outerArrowPath);
    
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
@property (nonatomic) BOOL shouldFill;
@end
@implementation FSV_SideLayer
@synthesize paddingBottom=_paddingBottom, wedgeHeight=_wedgeHeight, wedgeWidth=_wedgeWidth, side=_side, shouldFill=_shouldFill;
- (void)setPaddingBottom:(CGFloat)paddingBottom {
    _paddingBottom = paddingBottom; [self setNeedsDisplay];
}
- (void)setWedgeHeight:(CGFloat)wedgeHeight {
    _wedgeHeight = wedgeHeight; [self setNeedsDisplay];
}
- (void)setWedgeWidth:(CGFloat)wedgeWidth {
    _wedgeWidth = wedgeWidth; [self setNeedsDisplay];
}
- (void)setSide:(FSV_SideLayer_Side)side {
    _side = side; [self setNeedsDisplay];
}
- (void)setShouldFill:(BOOL)shouldFill {
    _shouldFill = shouldFill; [self setNeedsDisplay];
}
- (void)drawInContext:(CGContextRef)ctx {
    
    CGMutablePathRef shapePath = CGPathCreateMutable();
    CGPathMoveToPoint(shapePath, NULL, 0, 0);
    CGFloat drawingHeight = self.bounds.size.height - self.paddingBottom;
    CGPathAddLineToPoint(shapePath, NULL, 0, drawingHeight - (self.side == FSV_SideLayer_Left ? self.wedgeHeight : 0));
    CGPathAddLineToPoint(shapePath, NULL, self.wedgeWidth, drawingHeight);
    CGPathAddLineToPoint(shapePath, NULL, self.bounds.size.width - (self.side == FSV_SideLayer_Right ? self.wedgeWidth : 0), drawingHeight);
    CGPathAddLineToPoint(shapePath, NULL, self.bounds.size.width, drawingHeight - self.wedgeHeight);
    CGPathAddLineToPoint(shapePath, NULL, self.bounds.size.width, 0);
    CGPathCloseSubpath(shapePath);
    
    UIColor * shapeColor = self.side == FSV_SideLayer_Left ? [UIColor emotishColor] : [UIColor userColor];
    
    if (self.shouldFill) {
        CGContextSaveGState(ctx);
        CGContextAddPath(ctx, shapePath);
        CGContextSetFillColorWithColor(ctx, shapeColor.CGColor);
        CGContextDrawPath(ctx, kCGPathFill);
        CGContextRestoreGState(ctx);
    } else {
        CGContextSaveGState(ctx);
        CGContextSetStrokeColorWithColor(ctx, shapeColor.CGColor);
        CGContextSetLineWidth(ctx, 6.0);
        CGContextAddPath(ctx, shapePath);
        CGContextClip(ctx);
        CGContextAddPath(ctx, shapePath);
        CGContextDrawPath(ctx, kCGPathStroke);
        CGContextRestoreGState(ctx);        
    }
    
    CGPathRelease(shapePath);
    
}
@end

@interface FlagStretchView()
- (void) initWithFrameOrCoder;
@property (nonatomic, readonly) CGFloat stripeWidth;
@property (nonatomic, readonly) CGFloat arrowSideOverhangWidth;
@property (strong, nonatomic) FSV_MiddleLayer * stripeMiddleLayer;
@property (strong, nonatomic) FSV_SideLayer * stripeLeftLayer;
@property (strong, nonatomic) FSV_SideLayer * stripeRightLayer;
- (void) updateStripesAlpha;
@end

@implementation FlagStretchView

@synthesize icon=_icon;
@synthesize iconDistanceFromBottom=_iconDistanceFromBottom, activationDistanceStart=_activationDistanceStart, activationDistanceEnd=_activationDistanceEnd, activationAnimationDuration=_activationAnimationDuration, activated=_activated, activationAffectsIcon=_activationAffectsIcon;
@synthesize activationAffectsAlpha=_activationAffectsAlpha, sidesAlphaNormal=_sidesAlphaNormal, sidesAlphaActivated=_sidesAlphaActivated, middleAlphaNormal=_middleAlphaNormal, middleAlphaActivated=_middleAlphaActivated;

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
    
    _activated = YES;
    self.iconDistanceFromBottom = 20.0;
    self.activationAnimationDuration = 0.2;
    self.activationDistanceStart = 0.0;
    self.activationDistanceEnd = self.iconDistanceFromBottom + self.icon.frame.size.height + self.iconDistanceFromBottom;
    self.activationAffectsIcon = NO;
    self.activationAffectsAlpha = NO;
    self.sidesAlphaNormal = 1.0;
    self.sidesAlphaActivated = 1.0;
    self.middleAlphaNormal = 1.0;
    self.middleAlphaActivated = 1.0;
    
    self.pullOutSides = YES;
    self.pullOutMiddle = YES;
    self.pulledOutDistance = 0;
    
    self.stripeMiddleLayer = [FSV_MiddleLayer layer];
    CGFloat horizontalPaddingForStripeMiddleLayer = self.stripeWidth - self.arrowSideOverhangWidth;
    self.stripeMiddleLayer.frame = CGRectMake(horizontalPaddingForStripeMiddleLayer, 0, self.bounds.size.width - 2 * horizontalPaddingForStripeMiddleLayer, self.bounds.size.height);
    self.stripeMiddleLayer.contentsScale = [UIScreen mainScreen].scale;
//    self.stripeMiddleLayer.shouldFill = NO; // Testing
//    self.stripeMiddleLayer.shouldFill = YES;
    [self.layer addSublayer:self.stripeMiddleLayer];
    
    self.stripeLeftLayer = [FSV_SideLayer layer];
    self.stripeLeftLayer.frame = CGRectMake(0, 0, self.stripeWidth, self.bounds.size.height);
    self.stripeLeftLayer.side = FSV_SideLayer_Left;
    self.stripeLeftLayer.contentsScale = [UIScreen mainScreen].scale;
    self.stripeLeftLayer.shouldFill = YES;
    [self.layer addSublayer:self.stripeLeftLayer];
    
    self.stripeRightLayer = [FSV_SideLayer layer];
    self.stripeRightLayer.frame = CGRectMake(self.bounds.size.width - self.stripeWidth, 0, self.stripeWidth, self.bounds.size.height);
    self.stripeRightLayer.side = FSV_SideLayer_Right;
    self.stripeRightLayer.contentsScale = [UIScreen mainScreen].scale;
    self.stripeRightLayer.shouldFill = YES;
    [self.layer addSublayer:self.stripeRightLayer];
    
    self.icon = [CALayer layer];
    UIImage * iconImage = [UIImage imageNamed:@"pull_to_refresh_arrow.png"];
    self.icon.frame = CGRectMake(0, 0, iconImage.size.width, iconImage.size.height);
    self.icon.contents = (__bridge id)iconImage.CGImage;
    self.icon.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.icon];
   
    self.angledShapes = YES;
    self.activated = NO;
    
}

- (void)layoutSubviews {
    [CATransaction setAnimationDuration:0.0];
    if (!self.pullOutSides) {
        self.stripeLeftLayer.frame = CGRectMake(self.stripeLeftLayer.frame.origin.x, MIN(0, -self.pulledOutDistance + self.pullOutDistanceAllowedForAll), self.stripeLeftLayer.frame.size.width, self.stripeLeftLayer.frame.size.height);
        self.stripeRightLayer.frame = CGRectMake(self.stripeRightLayer.frame.origin.x, MIN(0, -self.pulledOutDistance + self.pullOutDistanceAllowedForAll), self.stripeRightLayer.frame.size.width, self.stripeRightLayer.frame.size.height);
    }
    if (!self.pullOutMiddle) {
        self.stripeMiddleLayer.frame = CGRectMake(self.stripeMiddleLayer.frame.origin.x, MIN(0, -self.pulledOutDistance + self.pullOutDistanceAllowedForAll), self.stripeMiddleLayer.frame.size.width, self.stripeMiddleLayer.frame.size.height);
    }
    self.icon.frame = CGRectMake((self.bounds.size.width - self.icon.frame.size.width) / 2.0, CGRectGetMaxY(self.stripeMiddleLayer.frame) - self.iconDistanceFromBottom - self.icon.frame.size.height, self.icon.frame.size.width, self.icon.frame.size.height);
}

- (void)setIconDistanceFromBottom:(CGFloat)iconDistanceFromBottom {
    _iconDistanceFromBottom=iconDistanceFromBottom;
    [self setNeedsLayout];
}

- (void)startAnimatingStripes {
    // ...
    // ...
    // ...
}

- (void)stopAnimatingStripes {
    // ...
    // ...
    // ...
}

- (void)setActivated:(BOOL)activated animated:(BOOL)animated {
    if (_activated != activated) {
        _activated = activated;
        [CATransaction setAnimationDuration:animated ? self.activationAnimationDuration : 0.0];
        if (self.activationAffectsIcon) {
            self.icon.transform = CATransform3DMakeRotation(self.activated ? M_PI : 0, 1.0, 0, 0);
        }
        if (self.activationAffectsAlpha) {
            [self updateStripesAlpha];
        }
    }
}

- (void)setActivated:(BOOL)activated {
    [self setActivated:activated animated:NO];
}

- (void)setPulledOutDistance:(CGFloat)pullOutDistance {
//    NSLog(@"setPullOutDistance:%f", pullOutDistance);
    if (_pulledOutDistance != pullOutDistance) {
//        NSLog(@"setPullOutDistance changed");
        _pulledOutDistance = pullOutDistance;
        [self setNeedsLayout];
        self.stripeMiddleLayer.visibleWidth = self.pulledOutDistance;
//        NSLog(@"\n%f\n%f\n%f\n%f", pullOutDistance, self.activationDistanceStart, self.activationDistanceEnd, MAX(0, pullOutDistance - self.activationDistanceStart) / (self.activationDistanceEnd - self.activationDistanceStart));
        self.stripeMiddleLayer.drainPercentage = MAX(0, pullOutDistance - self.activationDistanceStart) / (self.activationDistanceEnd - self.activationDistanceStart);
    }
}

- (void)setAngledShapes:(BOOL)angledShapes angleSeverity:(AngleSeverity)angleSeverity {
    
    if (_angledShapes != angledShapes) {
        _angledShapes = angledShapes;
    }
    //    self.stripeLeftLayer.shouldFill = !self.angledShapes;
    //    self.stripeRightLayer.shouldFill = !self.angledShapes;
    
    CGFloat middlePointHeightMultiplier = 0;
    CGFloat sidesWedgeHeightMultiplier = 0;
    
    if (angledShapes) {
        switch (angleSeverity) {
            case Subtle51213:
                // 5/12/13 Triangle
                sidesWedgeHeightMultiplier = 5.0 / 12.0;
                middlePointHeightMultiplier = 5.0 / 24.0;
                break;
            case Mild345:
                // 3/4/5 Triangle
                sidesWedgeHeightMultiplier = 3.0 / 4.0;
                middlePointHeightMultiplier = 3.0 / 8.0;
                break;
            case Sharp112:
            default:
                // 1/1/sq(2) Triangle
                middlePointHeightMultiplier = 1.0 / 2.0;
                sidesWedgeHeightMultiplier = 1.0 / 1.0;
                break;                
        }        
    } else {
        angleSeverity = None;
    }
    
    self.stripeMiddleLayer.pointHeight = self.angledShapes ? (2 * self.arrowSideOverhangWidth + self.stripeWidth) * middlePointHeightMultiplier : 0.0;
    self.stripeMiddleLayer.paddingHorizontal = self.arrowSideOverhangWidth;
    CGFloat sidesPaddingBottom = 0;
    CGFloat sidesWedgeWidth = 0;
    CGFloat sidesWedgeHeight = 0;
    if (self.angledShapes) {
        sidesPaddingBottom = self.stripeMiddleLayer.pointHeight;
        sidesWedgeWidth = self.stripeWidth - self.arrowSideOverhangWidth;
        sidesWedgeHeight = (self.stripeLeftLayer.wedgeWidth) * sidesWedgeHeightMultiplier;
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

- (void)setAngledShapes:(BOOL)angledShapes {
    [self setAngledShapes:angledShapes angleSeverity:angledShapes ? Sharp112 : None];
}

- (void) updateStripesAlpha {
    CGFloat sidesAlpha = self.sidesAlphaNormal;
    CGFloat middleAlpha = self.middleAlphaNormal;
    if (self.activated) {
        sidesAlpha = self.sidesAlphaActivated;
        middleAlpha = self.middleAlphaActivated;
    }
    self.stripeLeftLayer.opacity = sidesAlpha;
    self.stripeRightLayer.opacity = sidesAlpha;
    self.stripeMiddleLayer.opacity = middleAlpha;
}

- (void)setSidesAlphaNormal:(CGFloat)sidesAlphaNormal {
    if (_sidesAlphaNormal != sidesAlphaNormal) {
        _sidesAlphaNormal = sidesAlphaNormal;
        [self updateStripesAlpha];
    }
}
- (void)setSidesAlphaActivated:(CGFloat)sidesAlphaActivated {
    if (_sidesAlphaActivated != sidesAlphaActivated) {
        _sidesAlphaActivated = sidesAlphaActivated;
        [self updateStripesAlpha];
    }
}
- (void)setMiddleAlphaNormal:(CGFloat)middleAlphaNormal {
    if (_middleAlphaNormal != middleAlphaNormal) {
        _middleAlphaNormal = middleAlphaNormal;
        [self updateStripesAlpha];
    }
}
- (void)setMiddleAlphaActivated:(CGFloat)middleAlphaActivated {
    if (_middleAlphaActivated != middleAlphaActivated) {
        _middleAlphaActivated = middleAlphaActivated;
        [self updateStripesAlpha];
    }
}

- (CGFloat)stripeWidth { return floorf(self.bounds.size.width / 3.0); }
- (CGFloat)arrowSideOverhangWidth { return floorf(self.bounds.size.width / 4.0); }

- (void)setMiddleStripeBorderWidth:(CGFloat)middleStripeBorderWidth {
    self.stripeMiddleLayer.drainedBorderWidth = middleStripeBorderWidth;
}

@end
