//
//  SubmitPhotoViewController.h
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBarView.h"
#import "PhotoView.h"
#import "CameraOverlayViewHandler.h"

@protocol SubmitPhotoViewControllerDelegate;

@interface SubmitPhotoViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayViewHandlerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet TopBarView * topBar;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField * feelingTextField;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView * photoView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView * bottomBar;

@property (strong, nonatomic) UIImage * feelingImage;
@property (strong, nonatomic) NSString * feelingWord;
@property (strong, nonatomic) NSString * userName;

@property (nonatomic) BOOL shouldPushImagePicker;
@property (strong, nonatomic) UIImagePickerController * imagePickerControllerCamera;
@property (strong, nonatomic) UIImagePickerController * imagePickerControllerLibrary;
@property (strong, nonatomic) CameraOverlayViewHandler * cameraOverlayViewHandler;
@property (strong, nonatomic) UIImage * addPhotoImage;
- (void) pushImagePicker;
@property (unsafe_unretained, nonatomic) id<SubmitPhotoViewControllerDelegate> delegate;

@end

@protocol SubmitPhotoViewControllerDelegate <NSObject>

- (void) submitPhotoViewControllerDidCancel:(SubmitPhotoViewController *)submitPhotoViewController;
- (void) submitPhotoViewControllerDidSubmitPhoto:(SubmitPhotoViewController *)submitPhotoViewController;

@end