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
#import "Photo.h"
#import "CoreDataManager.h"
#import "UITextFieldWithInset.h"

@protocol SubmitPhotoViewControllerDelegate;

@interface SubmitPhotoViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayViewHandlerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet TopBarView * topBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView * bottomBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView * scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextFieldWithInset * feelingTextField;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView * photoView;

//@property (strong, nonatomic) UIImage * feelingImageOriginal;
@property (strong, nonatomic) UIImage * feelingImageSquare;
@property (strong, nonatomic) NSString * feelingWord;
@property (strong, nonatomic) NSString * userName;
@property (strong, nonatomic) CoreDataManager * coreDataManager;

@property (nonatomic) BOOL shouldPushImagePicker;
@property (strong, nonatomic) UIImagePickerController * imagePickerControllerCamera;
@property (strong, nonatomic) UIImagePickerController * imagePickerControllerLibrary;
@property (strong, nonatomic) CameraOverlayViewHandler * cameraOverlayViewHandler;
- (void) pushImagePicker;
@property (unsafe_unretained, nonatomic) id<SubmitPhotoViewControllerDelegate> delegate;

@end

@protocol SubmitPhotoViewControllerDelegate <NSObject>

- (void) submitPhotoViewControllerDidCancel:(SubmitPhotoViewController *)submitPhotoViewController;
- (void) submitPhotoViewController:(SubmitPhotoViewController *)submitPhotoViewController didSubmitPhoto:(Photo *)photo withImage:(UIImage *)image;

@end