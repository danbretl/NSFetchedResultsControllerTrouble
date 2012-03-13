//
//  CameraOverlayViewHandler.m
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraOverlayViewHandler.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "CameraConstants.h"

@interface CameraOverlayViewHandler()
//- (void) linkViewAndController;
- (void) cameraOverlayViewButtonTouched:(UIButton *)button;
@end

@implementation CameraOverlayViewHandler

@synthesize cameraOverlayView=_cameraOverlayView;
@synthesize imagePickerController=_imagePickerController;
@synthesize delegate=_delegate;

- (void)setCameraOverlayView:(CameraOverlayView *)cameraOverlayView {
    if (_cameraOverlayView != cameraOverlayView) {
        _cameraOverlayView = cameraOverlayView;
        [self.cameraOverlayView.cancelButton addTarget:self action:@selector(cameraOverlayViewButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.cameraOverlayView.photoButton addTarget:self action:@selector(cameraOverlayViewButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.cameraOverlayView.acceptButton addTarget:self action:@selector(cameraOverlayViewButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.cameraOverlayView.libraryButton addTarget:self action:@selector(cameraOverlayViewButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.cameraOverlayView.swapCamerasButton addTarget:self action:@selector(cameraOverlayViewButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)cameraOverlayViewButtonTouched:(UIButton *)button {
    if (button == self.cameraOverlayView.cancelButton) {
        if (self.inReview) {
            [self hideImageReview];
        } else {
            [self.imagePickerController.delegate imagePickerControllerDidCancel:self.imagePickerController];
        }
    } else if (button == self.cameraOverlayView.photoButton) {
        [self.imagePickerController takePicture];
    } else if (button == self.cameraOverlayView.acceptButton) {
        [self.delegate cameraOverlayViewHandler:self acceptedImage:self.cameraOverlayView.imageOverlay.image withFeelingText:self.cameraOverlayView.feelingTextField.text];
    } else if (button == self.cameraOverlayView.libraryButton) {
        [self.delegate cameraOverlayViewHandlerRequestedLibraryPicker:self];
    } else if (button == self.cameraOverlayView.swapCamerasButton) {
        self.imagePickerController.cameraDevice = self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront ? UIImagePickerControllerCameraDeviceRear : UIImagePickerControllerCameraDeviceFront;
        [[NSUserDefaults standardUserDefaults] setInteger:self.imagePickerController.cameraDevice forKey:CAMERA_DEVICE_LAST_USED_USER_DEFAULTS_KEY];
    }
}

- (void)showImageReview:(UIImage *)image {
    NSLog(@"CameraOverlayViewHandler showImageReview");
    self.cameraOverlayView.imageOverlay.image = image;
    self.cameraOverlayView.imageOverlay.hidden = NO;
    self.cameraOverlayView.imageOverlay.userInteractionEnabled = YES;
    self.cameraOverlayView.photoButton.hidden = YES;
    self.cameraOverlayView.acceptButton.hidden = NO;
    self.cameraOverlayView.swapCamerasButton.hidden = YES;
    self.cameraOverlayView.libraryButton.enabled = NO;
}

- (void)hideImageReview {
    NSLog(@"CameraOverlayViewHandler hideImageReview");
    self.cameraOverlayView.imageOverlay.hidden = YES;
    self.cameraOverlayView.imageOverlay.image = nil;
    self.cameraOverlayView.imageOverlay.userInteractionEnabled = NO;
    self.cameraOverlayView.photoButton.hidden = NO;
    self.cameraOverlayView.acceptButton.hidden = YES;
    self.cameraOverlayView.swapCamerasButton.hidden = NO;
    self.cameraOverlayView.libraryButton.enabled = YES;
}

- (BOOL)inReview {
    return !self.cameraOverlayView.imageOverlay.hidden;
}

@end
