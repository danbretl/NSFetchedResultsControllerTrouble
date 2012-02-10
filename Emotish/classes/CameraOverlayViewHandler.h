//
//  CameraOverlayViewHandler.h
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraOverlayView.h"

@protocol CameraOverlayViewHandlerDelegate;

@interface CameraOverlayViewHandler : NSObject

@property (unsafe_unretained, nonatomic) id<CameraOverlayViewHandlerDelegate> delegate;

@property (unsafe_unretained, nonatomic) CameraOverlayView * cameraOverlayView;
@property (unsafe_unretained, nonatomic) UIImagePickerController * imagePickerController;

- (void) showImageReview:(UIImage *)image;
- (void) hideImageReview;
@property (nonatomic, readonly) BOOL inReview;

@end

@protocol CameraOverlayViewHandlerDelegate <NSObject>
- (void) cameraOverlayViewHandlerRequestedLibraryPicker:(CameraOverlayViewHandler *)cameraOverlayViewHandler;
- (void) cameraOverlayViewHandler:(CameraOverlayViewHandler *)cameraOverlayViewHandler acceptedImage:(UIImage *)image withFeelingText:(NSString *)feelingText;
@end