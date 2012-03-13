//
//  CameraButtonView.h
//  Emotish
//
//  Created by Dan Bretl on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  CameraButtonView may adjust its own width in response to changes to the text or visibility of the button prompt.

#import <UIKit/UIKit.h>

extern const CGFloat CAMERA_BUTTON_IMAGE_WIDTH;
extern const CGFloat CAMERA_BUTTON_IMAGE_HEIGHT;
extern const CGFloat CAMERA_BUTTON_IMAGE_DISTANCE_FROM_LEFT_EDGE;
extern const CGFloat CAMERA_BUTTON_IMAGE_DISTANCE_FROM_BOTTOM_EDGE;
extern const CGFloat CAMERA_BUTTON_PADDING_TOP;
extern const CGFloat CAMERA_BUTTON_PADDING_RIGHT;
extern const CGFloat CAMERA_BUTTON_PROMPT_PADDING_LEFT;
extern const CGFloat CAMERA_BUTTON_PROMPT_PADDING_RIGHT;
extern const CGFloat CAMERA_BUTTON_PROMPT_INSET_BOTTOM;


@interface CameraButtonView : UIView

@property (strong, nonatomic, readonly) UIButton * button;
@property (strong, nonatomic, readonly) CALayer * buttonShadowLayer;
@property (strong, nonatomic) NSString * buttonPromptText;
@property (nonatomic) BOOL buttonPromptVisible;
- (void) setButtonPromptVisible:(BOOL)buttonPromptVisible animated:(BOOL)animated;
- (void) setButtonPromptVisible:(BOOL)buttonPromptVisible animated:(BOOL)animated animationDuration:(double)animationDuration;

- (void) positionInSuperview:(UIView *)superview;

@end
