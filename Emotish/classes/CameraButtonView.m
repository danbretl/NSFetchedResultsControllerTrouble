//
//  CameraButtonView.m
//  Emotish
//
//  Created by Dan Bretl on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraButtonView.h"
#import "ViewConstants.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat CAMERA_BUTTON_IMAGE_WIDTH = 44.0;
const CGFloat CAMERA_BUTTON_IMAGE_HEIGHT = 44.0;
const CGFloat CAMERA_BUTTON_IMAGE_DISTANCE_FROM_LEFT_EDGE = 12.0;
const CGFloat CAMERA_BUTTON_IMAGE_DISTANCE_FROM_BOTTOM_EDGE = 8.0;
const CGFloat CAMERA_BUTTON_PADDING_TOP = 8.0;
const CGFloat CAMERA_BUTTON_PADDING_RIGHT = 12.0;
const CGFloat CAMERA_BUTTON_PROMPT_PADDING_LEFT = -3.0;
const CGFloat CAMERA_BUTTON_PROMPT_PADDING_RIGHT = 12.0;
const CGFloat CAMERA_BUTTON_PROMPT_INSET_BOTTOM = 12.0;

const double CAMERA_BUTTON_VISIBILITY_ANIMATION_DURATION = 0.25;

@interface CameraButtonView ()
- (void) initWithFrameOrCoder;
@property (strong, nonatomic) UIButton * button;
- (void) updateWidthForPromptVisible:(BOOL)promptVisible;
- (void) updateWidthForPromptVisible:(BOOL)promptVisible promptText:(NSString *)promptText;
@property (strong, nonatomic) CALayer * buttonShadowLayer;
@end

@implementation CameraButtonView

@synthesize button=_button, buttonShadowLayer=_buttonShadowLayer;
@synthesize buttonPromptText=_buttonPromptText, buttonPromptVisible=_buttonPromptVisible;

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
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height = CAMERA_BUTTON_IMAGE_DISTANCE_FROM_BOTTOM_EDGE + CAMERA_BUTTON_IMAGE_HEIGHT + CAMERA_BUTTON_PADDING_TOP;
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = self.bounds;
    self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.button.contentMode = UIViewContentModeBottomLeft;
    self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.button.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.button.contentEdgeInsets = UIEdgeInsetsMake(0, CAMERA_BUTTON_IMAGE_DISTANCE_FROM_LEFT_EDGE, CAMERA_BUTTON_IMAGE_DISTANCE_FROM_BOTTOM_EDGE, 0);
    self.button.titleEdgeInsets = UIEdgeInsetsMake(0, CAMERA_BUTTON_PADDING_RIGHT + CAMERA_BUTTON_PROMPT_PADDING_LEFT, CAMERA_BUTTON_PROMPT_INSET_BOTTOM, 0);
    self.button.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.button.titleLabel.adjustsFontSizeToFitWidth = NO;
    [self.button setImage:[UIImage imageNamed:@"btn_camera.png"] forState:UIControlStateNormal];
    [self.button setImage:[UIImage imageNamed:@"btn_camera_touch.png"] forState:UIControlStateHighlighted];
    [self.button setTitleColor:[UIColor colorWithWhite:184.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor colorWithWhite:161.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [self addSubview:self.button];
    
    self.buttonShadowLayer = [CALayer layer];
    self.buttonShadowLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.button.imageView.frame cornerRadius:self.button.imageView.frame.size.width / 2.0].CGPath;
    self.buttonShadowLayer.shadowOpacity = 0.4;
    self.buttonShadowLayer.shadowOffset = CGSizeMake(0, 0);
    self.buttonShadowLayer.shadowColor = [UIColor colorWithWhite:120.0/255.0 alpha:1.0].CGColor;
    [self.button.layer insertSublayer:self.buttonShadowLayer below:self.button.imageView.layer];
    
    self.buttonPromptText = nil;
    self.buttonPromptVisible = NO;
    
    [self updateWidthForPromptVisible:self.buttonPromptVisible promptText:self.buttonPromptText];
    
    self.backgroundColor = [UIColor clearColor];
    self.button.backgroundColor = [UIColor clearColor];
    
}

- (void)setButtonPromptText:(NSString *)buttonPromptText {
    _buttonPromptText = buttonPromptText;
    [self.button setTitle:self.buttonPromptText forState:UIControlStateNormal];
    [self.button setTitle:self.buttonPromptText forState:UIControlStateHighlighted];
    [self updateWidthForPromptVisible:self.buttonPromptVisible promptText:self.buttonPromptText];
}

- (void)setButtonPromptVisible:(BOOL)buttonPromptVisible {
    [self setButtonPromptVisible:buttonPromptVisible animated:NO];
}

- (void)setButtonPromptVisible:(BOOL)buttonPromptVisible animated:(BOOL)animated {
    
    [self setButtonPromptVisible:buttonPromptVisible animated:animated animationDuration:CAMERA_BUTTON_VISIBILITY_ANIMATION_DURATION];

}

- (void)setButtonPromptVisible:(BOOL)buttonPromptVisible animated:(BOOL)animated animationDuration:(double)animationDuration {
    
    _buttonPromptVisible = buttonPromptVisible;
    
    [self updateWidthForPromptVisible:self.buttonPromptVisible promptText:self.buttonPromptText];
    
    if (animated && animationDuration > 0.0) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.button.titleLabel.alpha = self.buttonPromptVisible ? 1.0 : 0.0;
        }]; 
    } else {
        self.button.titleLabel.alpha = self.buttonPromptVisible ? 1.0 : 0.0;
    }
    
}

- (void) updateWidthForPromptVisible:(BOOL)promptVisible {
    [self updateWidthForPromptVisible:promptVisible promptText:nil];
}

- (void) updateWidthForPromptVisible:(BOOL)promptVisible promptText:(NSString *)promptText {
    
    CGFloat widthRightOfImage = CAMERA_BUTTON_PADDING_RIGHT;
    if (promptVisible || (promptText != nil && promptText.length > 0)) {
        widthRightOfImage += CAMERA_BUTTON_PROMPT_PADDING_LEFT;
        widthRightOfImage += [promptText sizeWithFont:self.button.titleLabel.font].width;
        widthRightOfImage += CAMERA_BUTTON_PROMPT_PADDING_RIGHT;
    }
    
    CGFloat cameraButtonWidth = CAMERA_BUTTON_IMAGE_DISTANCE_FROM_LEFT_EDGE + CAMERA_BUTTON_IMAGE_WIDTH + widthRightOfImage;
                                        
    CGRect selfFrame = self.frame;
    selfFrame.size.width = cameraButtonWidth;
    self.frame = selfFrame;
    
}

- (void)positionInSuperview:(UIView *)superview {
    CGRect cameraButtonFrame = self.frame;
    cameraButtonFrame.origin = CGPointMake(0, superview.frame.size.height - VC_BOTTOM_BAR_HEIGHT - cameraButtonFrame.size.height);
    self.frame = cameraButtonFrame;
}

@end
