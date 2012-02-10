//
//  CameraOverlayView.m
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraOverlayView.h"
#import "UIColor+Emotish.h"
#import "ViewConstants.h"

const CGFloat COV_TOP_BAR_PADDING_HORIZONTAL = 20.0;

@interface CameraOverlayView()
@end

@implementation CameraOverlayView

@synthesize topBar=_topBar, feelingTextField=_feelingTextField;
@synthesize imageOverlay=_imageOverlay, swapCamerasButton=_swapCamerasButton;
@synthesize bottomBar=_bottomBar, cancelButton=_cancelButton, photoButton=_photoButton, libraryButton=_libraryButton, acceptButton=_acceptButton;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        BOOL debugging = NO;
        
        CGRect imageFrame = [CameraOverlayView imageCropFrame];
        
        self.imageOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CAMERA_VIEW_SCREEN_WIDTH, CAMERA_VIEW_SCREEN_HEIGHT)];
        self.imageOverlay.contentMode = UIViewContentModeScaleAspectFill;
        self.imageOverlay.hidden = YES;
        self.imageOverlay.userInteractionEnabled = YES;
        [self addSubview:self.imageOverlay];
        
        self.swapCamerasButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat swapCamerasButtonWidth = 50.0;
        self.swapCamerasButton.frame = CGRectMake(CGRectGetMaxX(imageFrame) - swapCamerasButtonWidth, CGRectGetMinY(imageFrame), swapCamerasButtonWidth, swapCamerasButtonWidth);
        [self.swapCamerasButton setTitle:@"Swap" forState:UIControlStateNormal];
        [self.swapCamerasButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.swapCamerasButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        self.swapCamerasButton.backgroundColor = [UIColor colorWithWhite:0.75 alpha:0.40];
        [self insertSubview:self.swapCamerasButton belowSubview:self.imageOverlay];
        
        self.topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, CGRectGetMinY(imageFrame))];
        self.topBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"top_bar_camera_view.png"]];
        [self addSubview:self.topBar];

        self.feelingTextField = [[UITextField alloc] initWithFrame:CGRectMake(COV_TOP_BAR_PADDING_HORIZONTAL, 0, self.topBar.frame.size.width - 2 * COV_TOP_BAR_PADDING_HORIZONTAL, self.topBar.frame.size.height)];
        self.feelingTextField.placeholder = @"I'm feeling...";
        self.feelingTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.feelingTextField.adjustsFontSizeToFitWidth = YES;
        self.feelingTextField.font = [UIFont boldSystemFontOfSize:48.0];
        self.feelingTextField.textColor = [UIColor feelingColor];
        self.feelingTextField.returnKeyType = UIReturnKeyDone;
        self.feelingTextField.delegate = self;
        self.feelingTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.topBar addSubview:self.feelingTextField];
        
        self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageFrame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(imageFrame))];
        self.bottomBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bottom_bar_camera_view.png"]];
        [self addSubview:self.bottomBar];
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.frame = CGRectMake(0, 0, self.bottomBar.frame.size.height, self.bottomBar.frame.size.height);
        self.cancelButton.contentMode = UIViewContentModeCenter;
        [self.cancelButton setImage:[UIImage imageNamed:@"btn_camera_view_cancel.png"] forState:UIControlStateNormal];
        self.cancelButton.adjustsImageWhenHighlighted = NO;
        [self.bottomBar addSubview:self.cancelButton];
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake(floorf((self.bottomBar.frame.size.width - self.bottomBar.frame.size.height) / 2.0), 0, self.bottomBar.frame.size.height, self.bottomBar.frame.size.height);
        self.photoButton.contentMode = UIViewContentModeCenter;
        [self.photoButton setImage:[UIImage imageNamed:@"btn_camera_view_photo.png"] forState:UIControlStateNormal];
        self.photoButton.adjustsImageWhenHighlighted = NO;
        [self.bottomBar addSubview:self.photoButton];        
        
        self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.acceptButton.frame = CGRectMake(floorf((self.bottomBar.frame.size.width - self.bottomBar.frame.size.height) / 2.0), 0, self.bottomBar.frame.size.height, self.bottomBar.frame.size.height);
        self.acceptButton.contentMode = UIViewContentModeCenter;
        [self.acceptButton setImage:[UIImage imageNamed:@"btn_camera_view_accept.png"] forState:UIControlStateNormal];
        self.acceptButton.adjustsImageWhenHighlighted = NO;
        self.acceptButton.hidden = YES;
        [self.bottomBar addSubview:self.acceptButton];

        self.libraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.libraryButton.frame = CGRectMake(self.bottomBar.frame.size.width - self.bottomBar.frame.size.height, 0, self.bottomBar.frame.size.height, self.bottomBar.frame.size.height);
        self.libraryButton.contentMode = UIViewContentModeCenter;
        [self.libraryButton setImage:[UIImage imageNamed:@"btn_camera_view_library.png"] forState:UIControlStateNormal];
        [self.libraryButton setImage:[UIImage imageNamed:@"btn_camera_view_library_disabled.png"] forState:UIControlStateDisabled];
        self.libraryButton.adjustsImageWhenHighlighted = NO;
        [self.bottomBar addSubview:self.libraryButton];
        
        if (debugging) {
            self.topBar.backgroundColor = [UIColor greenColor];
            self.feelingTextField.backgroundColor = [UIColor blueColor];
            self.bottomBar.backgroundColor = [UIColor greenColor];
            self.cancelButton.backgroundColor = [UIColor blueColor];
            self.photoButton.backgroundColor = [UIColor blueColor];
            self.acceptButton.backgroundColor = [UIColor blueColor];
            self.libraryButton.backgroundColor = [UIColor blueColor];
        }
        
    }
    return self;
}

+ (CGRect) imageCropFrame {
//    CGSize hardCodedScreenSize = [UIScreen mainScreen].bounds.size;
//    CGFloat hardCodedBottomBarHeight = 54.0;
//    CGFloat minScreenSideLength = MIN(hardCodedScreenSize.width, hardCodedScreenSize.height);
//    CGSize imageSize = CGSizeMake(minScreenSideLength, minScreenSideLength);
    return CGRectMake(0, CAMERA_OVERLAY_TOP_BAR_HEIGHT, CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH, CAMERA_VIEW_SCREEN_DISPLAY_SIDE_LENGTH);
//    return CGRectMake(0, hardCodedScreenSize.height - imageSize.height - hardCodedBottomBarHeight, imageSize.width, imageSize.height);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
    if (textField == self.feelingTextField) {
        shouldReturn = NO;
        [textField resignFirstResponder];
    }
    return shouldReturn;
}

@end
