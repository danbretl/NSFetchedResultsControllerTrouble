//
//  TopBarView.m
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopBarView.h"
#import <QuartzCore/QuartzCore.h>

@interface TBV_DividerLayer : CALayer
@end
@implementation TBV_DividerLayer
- (void)drawInContext:(CGContextRef)ctx {
    CGContextSetRGBFillColor(ctx, 238.0/255.0, 240.0/255.0, 240.0/255.0, 1.0);
    CGContextFillRect(ctx, CGRectMake(0, 0, self.frame.size.width / 2.0, self.frame.size.height));
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(ctx, CGRectMake(self.frame.size.width / 2.0, 0, self.frame.size.width / 2.0, self.frame.size.height));
}
@end

const CGFloat TBV_BUTTON_BRANDING_PADDING_HORIZONTAL = 10.0;
const CGFloat TBV_BUTTON_NORMAL_WIDTH = 62.0;
const CGFloat TBV_BUTTON_MARGIN_HORIZONTAL = 10.0;
const double  TBV_ANIMATION_DURATION = 0.25;

@interface TopBarView()
@property (strong, nonatomic, readonly) NSMutableDictionary * buttonsDictionary;
@property (strong, nonatomic) TBV_DividerLayer * dividerLayer;
- (void) initWithFrameOrCoder;
@property (nonatomic) TopBarViewMode viewMode;
- (UIButton *)buttonCurrentForPosition:(TopBarButtonPosition)buttonPosition;
- (UIButton *)buttonSpareForPosition:(TopBarButtonPosition)buttonPosition;
- (SEL)buttonCurrentSetterForPosition:(TopBarButtonPosition)buttonPosition;
- (void) setButtonCurrent:(UIButton *)button forPosition:(TopBarButtonPosition)buttonPosition;
@property (strong, nonatomic) UIButton * buttonLeftSpecialA;
@property (strong, nonatomic) UIButton * buttonLeftSpecialB;
@property (strong, nonatomic) UIButton * buttonLeftNormalA;
@property (strong, nonatomic) UIButton * buttonLeftNormalB;
@property (strong, nonatomic) UIButton * buttonRightNormalA;
@property (strong, nonatomic) UIButton * buttonRightNormalB;
@end

@implementation TopBarView

@synthesize buttonsDictionary=_buttonsDictionary;
@synthesize buttonBranding=_buttonBranding, buttonLeftSpecial=_buttonLeftSpecial, buttonLeftSpecialA=_buttonLeftSpecialA, buttonLeftSpecialB=_buttonLeftSpecialB, buttonLeftNormal=_buttonLeftNormal, buttonLeftNormalA=_buttonLeftNormalA, buttonLeftNormalB=_buttonLeftNormalB, buttonRightNormal=_buttonRightNormal, buttonRightNormalA=_buttonRightNormalA, buttonRightNormalB=_buttonRightNormalB, dividerLayer=_dividerLayer;
@synthesize viewMode=_viewMode;
@synthesize backgroundView=_backgroundView, backgroundFlagView=_backgroundFlagView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithFrameOrCoder];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initWithFrameOrCoder];
    }
    return self;
}

- (void)initWithFrameOrCoder {
    
    self.backgroundColor = [UIColor blackColor];
    
    UIImage * backgroundViewImage = [UIImage imageNamed:@"top_bar.png"];
    self.backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];// CGRectMake(0, 0, backgroundViewImage.size.width, backgroundViewImage.size.height)];
    self.backgroundView.image = backgroundViewImage;
    self.backgroundView.contentMode = UIViewContentModeTop;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.backgroundView];
    
    self.backgroundFlagView = [[FlagStretchView alloc] initWithFrame:CGRectMake(0, 10, self.bounds.size.width, self.bounds.size.height - 10)];
    self.backgroundFlagView.angledShapes = NO;
    self.backgroundFlagView.icon.hidden = YES;
    self.backgroundFlagView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:self.backgroundFlagView belowSubview:self.backgroundView];
    
    _viewMode = BrandingRight;
    self.buttonBranding = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * brandingImage = [UIImage imageNamed:@"top_bar_branding.png"];
    [self.buttonBranding setImage:brandingImage forState:UIControlStateNormal];
    self.buttonBranding.adjustsImageWhenHighlighted = NO;
    self.buttonBranding.adjustsImageWhenDisabled = NO;
    CGFloat buttonBrandingWidth = brandingImage.size.width + 2 * TBV_BUTTON_BRANDING_PADDING_HORIZONTAL;
    self.buttonBranding.frame = CGRectMake(self.bounds.size.width - buttonBrandingWidth, 0, buttonBrandingWidth, self.bounds.size.height);
    self.buttonBranding.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    self.buttonBranding.imageView.backgroundColor = [UIColor redColor];
    self.buttonBranding.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.buttonBranding.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.buttonBranding.backgroundColor = [UIColor clearColor];
//    self.buttonBranding.backgroundColor = [UIColor yellowColor];
    self.buttonBranding.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 10, TBV_BUTTON_BRANDING_PADDING_HORIZONTAL);
    [self addSubview:self.buttonBranding];
    
    self.buttonLeftSpecialA = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonLeftSpecialA.frame = CGRectMake(0, 0, 50.0, self.bounds.size.height);
    self.buttonLeftSpecialA.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.buttonLeftSpecialA.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self addSubview:self.buttonLeftSpecialA];
    self.buttonLeftSpecialA.alpha = 0.0;
    self.buttonLeftSpecialB = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonLeftSpecialB.frame = CGRectMake(0, 0, 50.0, self.bounds.size.height);
    self.buttonLeftSpecialB.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.buttonLeftSpecialB.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self addSubview:self.buttonLeftSpecialB];
    self.buttonLeftSpecialB.alpha = 0.0;
    
    self.buttonLeftNormalA = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonLeftNormalA.frame = CGRectMake(TBV_BUTTON_MARGIN_HORIZONTAL, 0, TBV_BUTTON_NORMAL_WIDTH, self.bounds.size.height);
    self.buttonLeftNormalA.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.buttonLeftNormalA.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self addSubview:self.buttonLeftNormalA];
    self.buttonLeftNormalA.alpha = 0.0;
    self.buttonLeftNormalB = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonLeftNormalB.frame = CGRectMake(TBV_BUTTON_MARGIN_HORIZONTAL, 0, TBV_BUTTON_NORMAL_WIDTH, self.bounds.size.height);
    self.buttonLeftNormalB.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.buttonLeftNormalB.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self addSubview:self.buttonLeftNormalB];
    self.buttonLeftNormalB.alpha = 0.0;

    self.buttonRightNormalA = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonRightNormalA.frame = CGRectMake(self.frame.size.width - TBV_BUTTON_NORMAL_WIDTH - TBV_BUTTON_MARGIN_HORIZONTAL, 0, TBV_BUTTON_NORMAL_WIDTH, self.bounds.size.height);
    self.buttonRightNormalA.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.buttonRightNormalA.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self addSubview:self.buttonRightNormalA];
    self.buttonRightNormalA.alpha = 0.0;
    self.buttonRightNormalB = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonRightNormalB.frame = CGRectMake(self.frame.size.width - TBV_BUTTON_NORMAL_WIDTH - TBV_BUTTON_MARGIN_HORIZONTAL, 0, TBV_BUTTON_NORMAL_WIDTH, self.bounds.size.height);
    self.buttonRightNormalB.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.buttonRightNormalB.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self addSubview:self.buttonRightNormalB];
    self.buttonRightNormalB.alpha = 0.0;

    self.dividerLayer = [TBV_DividerLayer layer];
    self.dividerLayer.frame = CGRectMake(CGRectGetMaxX(self.buttonLeftSpecialA.frame), 0, 2, self.frame.size.height - 1);
    self.dividerLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.dividerLayer];
    [self.dividerLayer setNeedsDisplay];
    self.dividerLayer.opacity = 0.0;
    
}

- (void)setViewMode:(TopBarViewMode)viewMode {
    [self setViewMode:viewMode animated:NO];
}

- (void)setViewMode:(TopBarViewMode)viewMode animated:(BOOL)animated {
    if (_viewMode != viewMode) {
        _viewMode = viewMode;
        [UIView animateWithDuration:animated ? TBV_ANIMATION_DURATION : 0 animations:^{
            CGRect buttonBrandingFrame = self.buttonBranding.frame;
            buttonBrandingFrame.origin.x = self.viewMode == BrandingCenter ? floorf((self.frame.size.width - buttonBrandingFrame.size.width) / 2.0) : self.frame.size.width - buttonBrandingFrame.size.width;
            self.buttonBranding.frame = buttonBrandingFrame;
        }];
    }
}

- (void)showButtonType:(TopBarButtonType)buttonType inPosition:(TopBarButtonPosition)buttonPosition animated:(BOOL)animated {
    
    UIButton * buttonCurrent = [self buttonCurrentForPosition:buttonPosition];
    NSNumber * buttonCurrentButtonType = [self.buttonsDictionary valueForKey:[NSString stringWithFormat:@"%d", buttonPosition]];
    if (buttonCurrentButtonType == nil ||
        buttonCurrentButtonType.intValue != buttonType) {
        NSLog(@"buttonCurrentButtonType == nil || buttonCurrentButtonType.intValue != buttonType ---> YES");
          
        UIButton * buttonSpare = [self buttonSpareForPosition:buttonPosition];
        NSLog(@"buttonSpareForPosition:%d ---> %@", buttonPosition, buttonSpare);
        
        UIImage * buttonImage = nil;
        UIImage * buttonImageTouch = nil;
        if (buttonType == ProfileButton) {
            buttonImage = [UIImage imageNamed:@"icon_profile.png"];
            buttonImageTouch = [UIImage imageNamed:@"icon_profile_touch.png"];
        } else if (buttonType == SettingsButton) {
            buttonImage = [UIImage imageNamed:@"icon_settings.png"];
            buttonImageTouch = [UIImage imageNamed:@"icon_settings_touch.png"];        
        } else if (buttonType == BackButton) {
            buttonImage = [UIImage imageNamed:@"btn_back.png"];
            buttonImageTouch = [UIImage imageNamed:@"btn_back_touch.png"];
        } else if (buttonType == CancelButton) {
            buttonImage = [UIImage imageNamed:@"btn_cancel.png"];
            buttonImageTouch = [UIImage imageNamed:@"btn_cancel_touch.png"];
        } else if (buttonType == DoneButton) {
            buttonImage = [UIImage imageNamed:@"btn_done.png"];
            buttonImageTouch = [UIImage imageNamed:@"btn_done_touch.png"];
        } else if (buttonType == SendButton) {
            buttonImage = [UIImage imageNamed:@"btn_send.png"];
            buttonImageTouch = [UIImage imageNamed:@"btn_send_touch.png"];
        }
        [buttonSpare setImage:buttonImage forState:UIControlStateNormal];
        [buttonSpare setImage:buttonImageTouch forState:UIControlStateHighlighted];
        void(^buttonChanges)(UIButton *, UIButton *, TopBarButtonPosition) = ^(UIButton * buttonToHide, UIButton * buttonToShow, TopBarButtonPosition buttonsPosition) {
            buttonToHide.alpha = 0.0;
            buttonToShow.alpha = 1.0;
//            buttonCurrent.alpha = 0.0;
//            buttonSpare.alpha = 1.0;
            if (buttonsPosition == LeftSpecial) {
                self.dividerLayer.opacity = 1.0;
            }
        };
        [self setButtonCurrent:buttonSpare forPosition:buttonPosition];
        [self.buttonsDictionary setValue:[NSNumber numberWithInt:buttonType] forKey:[NSString stringWithFormat:@"%d", buttonPosition]];
        [UIView animateWithDuration:animated ? TBV_ANIMATION_DURATION : 0.0 animations:^{
            buttonChanges(buttonCurrent, buttonSpare, buttonPosition);
        }];
    }

}

- (void)hideButtonInPosition:(TopBarButtonPosition)buttonPosition animated:(BOOL)animated {
    UIButton * button = [self buttonCurrentForPosition:buttonPosition];
    UIButton * spareButton = [self buttonSpareForPosition:buttonPosition]; // Not sure why this is necessary. Something about my buttonCurrent is not working.
    [UIView animateWithDuration:animated ? TBV_ANIMATION_DURATION : 0.0 animations:^{
        button.alpha = 0.0;
        spareButton.alpha = 0.0;
        if (buttonPosition == LeftSpecial) {
            self.dividerLayer.opacity = 0.0;
        }
    } completion:^(BOOL finished){
        [self setButtonCurrent:nil forPosition:buttonPosition];
        [self.buttonsDictionary removeObjectForKey:[NSString stringWithFormat:@"%d", buttonPosition]];
    }];
}

- (UIButton *)buttonCurrentForPosition:(TopBarButtonPosition)buttonPosition {
    UIButton * button = nil;
    if (buttonPosition == LeftSpecial) {
        button = self.buttonLeftSpecial;
    } else if (buttonPosition == LeftNormal) {
        button = self.buttonLeftNormal;
    } else if (buttonPosition == RightNormal) {
        button = self.buttonRightNormal;
    }
    return button;
}

- (UIButton *)buttonSpareForPosition:(TopBarButtonPosition)buttonPosition {
    UIButton * buttonSpare = nil;
    if (buttonPosition == LeftSpecial) {
        buttonSpare = self.buttonLeftSpecial == self.buttonLeftSpecialA ? self.buttonLeftSpecialB : self.buttonLeftSpecialA;
    } else if (buttonPosition == LeftNormal) {
        buttonSpare = self.buttonLeftNormal == self.buttonLeftNormalA ? self.buttonLeftNormalB : self.buttonLeftNormalA;
    } else if (buttonPosition == RightNormal) {
        buttonSpare = self.buttonRightNormal == self.buttonRightNormalA ? self.buttonRightNormalB : self.buttonRightNormalA;
    }
    return buttonSpare;
}

// To avoid a dumb ARC compiler warning "PerformSelector may cause a leak because its selector is unknown."
- (void) setButtonCurrent:(UIButton *)button forPosition:(TopBarButtonPosition)buttonPosition {
    NSLog(@"setButtonCurrent:(UIButton *)%@ forPosition:(TopBarButtonPosition)%d", button, buttonPosition);
    if (buttonPosition == LeftSpecial) {
        self.buttonLeftSpecial = button;
    } else if (buttonPosition == LeftNormal) {
        self.buttonLeftNormal = button;
    } else if (buttonPosition == RightNormal) {
        self.buttonRightNormal = button;
    }
}

// Not using this for now because of a dumb ARC compiler warning "PerformSelector may cause a leak because its selector is unknown."
- (SEL)buttonCurrentSetterForPosition:(TopBarButtonPosition)buttonPosition {
    SEL buttonSetter = NULL;
    if (buttonPosition == LeftSpecial) {
        buttonSetter = @selector(setButtonLeftSpecial:);
    } else if (buttonPosition == LeftNormal) {
        buttonSetter = @selector(setButtonLeftNormal:);
    } else if (buttonPosition == RightNormal) {
        buttonSetter = @selector(setButtonRightNormal:);
    }
    return buttonSetter;
}

- (NSMutableDictionary *)buttonsDictionary {
    if (_buttonsDictionary == nil) {
        _buttonsDictionary = [NSMutableDictionary dictionary];
    }
    return _buttonsDictionary;
}

- (void)addTarget:(id)target selector:(SEL)selector forButtonPosition:(TopBarButtonPosition)buttonPosition {
    if (buttonPosition == LeftSpecial) {
        [self.buttonLeftSpecialA addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        [self.buttonLeftSpecialB addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    } else if (buttonPosition == LeftNormal) {
        [self.buttonLeftNormalA addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        [self.buttonLeftNormalB addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    } else if (buttonPosition == RightNormal) {
        [self.buttonRightNormalA addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        [self.buttonRightNormalB addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}

@end
