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
#import "AccountViewController.h"

@protocol SubmitPhotoViewControllerDelegate;

@interface SubmitPhotoViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayViewHandlerDelegate, AccountViewControllerDelegate, UIAlertViewDelegate, PhotoViewDelegate, PF_FBRequestDelegate, UITableViewDelegate, UITableViewDataSource>

@property (unsafe_unretained, nonatomic) IBOutlet TopBarView * topBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView * bottomBar;
@property (unsafe_unretained, nonatomic) IBOutlet UITextFieldWithInset * feelingTextField;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView * photoView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView * shareContainer;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * shareLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton * twitterButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton * facebookButton;
@property (strong, nonatomic) UITableView * feelingsTableView;
@property (strong, nonatomic) UITableView * feelingsTableViewCamera;

@property (strong, nonatomic) NSArray * feelings;
@property (strong, nonatomic) NSArray * feelingsMatched;

//@property (strong, nonatomic) UIImage * feelingImageOriginal;
@property (strong, nonatomic) UIImage * feelingImageSquare;
@property (strong, nonatomic) NSString * feelingWord;
@property (strong, nonatomic) CoreDataManager * coreDataManager;

@property (nonatomic) BOOL shouldPushImagePicker;
@property (strong, nonatomic) UIImagePickerController * imagePickerControllerCamera;
@property (strong, nonatomic) UIImagePickerController * imagePickerControllerLibrary;
@property (strong, nonatomic) CameraOverlayViewHandler * cameraOverlayViewHandler;
- (void) pushImagePicker;
@property (unsafe_unretained, nonatomic) id<SubmitPhotoViewControllerDelegate> delegate;

// Social networks
@property (strong, nonatomic) PF_FBRequest * facebookPostPhotoRequest;

@end

@protocol SubmitPhotoViewControllerDelegate <NSObject>

- (void) submitPhotoViewControllerDidCancel:(SubmitPhotoViewController *)submitPhotoViewController;
- (void) submitPhotoViewController:(SubmitPhotoViewController *)submitPhotoViewController didSubmitPhoto:(Photo *)photo withImage:(UIImage *)image;

@end