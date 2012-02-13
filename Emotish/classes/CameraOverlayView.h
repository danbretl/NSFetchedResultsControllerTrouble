//
//  CameraOverlayView.h
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBarView.h"

@interface CameraOverlayView : UIView <UITextFieldDelegate>

@property (strong, nonatomic) TopBarView * topBar;
@property (strong, nonatomic) UITextField * feelingTextField;
- (void) setFeelingText:(NSString *)feelingText;

@property (strong, nonatomic) UIImageView * imageOverlay;
@property (strong, nonatomic) UIButton * swapCamerasButton;

@property (strong, nonatomic) UIView * bottomBar;
@property (strong, nonatomic) UIButton * cancelButton;
@property (strong, nonatomic) UIButton * photoButton;
@property (strong, nonatomic) UIButton * libraryButton;
@property (strong, nonatomic) UIButton * acceptButton;

//+ (CGRect) imageCropFrame;

@end