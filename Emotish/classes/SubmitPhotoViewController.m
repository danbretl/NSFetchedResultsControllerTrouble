//
//  SubmitPhotoViewController.m
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubmitPhotoViewController.h"
#import "ViewConstants.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+Crop.h"
#import "UIColor+Emotish.h"
#import "UIImage+LocalStore.h"

static NSString * SPVC_FEELING_PLACEHOLDER_TEXT = @"something";
static NSString * SPVC_USER_PLACEHOLDER_TEXT = @"username";

@interface SubmitPhotoViewController()
- (void) updateViewsWithCurrentData;
- (void) backButtonTouched:(UIButton *)button;
- (void) doneButtonTouched:(UIButton *)button;
@end

@implementation SubmitPhotoViewController

@synthesize topBar=_topBar, feelingTextField=_feelingTextField, photoView=_photoView, bottomBar=_bottomBar;
@synthesize /*feelingImageOriginal=_feelingImageOriginal,*/ feelingImageSquare=_feelingImageSquare, feelingWord=_feelingWord, userName=_userName;
@synthesize coreDataManager=_coreDataManager;

@synthesize shouldPushImagePicker=_shouldPushImagePicker;
@synthesize imagePickerControllerCamera=_imagePickerControllerCamera, imagePickerControllerLibrary=_imagePickerControllerLibrary, cameraOverlayViewHandler=_cameraOverlayViewHandler;
@synthesize delegate=_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.feelingImageOriginal = nil;
        self.feelingImageSquare = nil;
        self.feelingWord = SPVC_FEELING_PLACEHOLDER_TEXT;
        self.userName = SPVC_USER_PLACEHOLDER_TEXT;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.photoView.frame = CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, PC_PHOTO_CELL_IMAGE_ORIGIN_Y, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL * 2, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM + PC_PHOTO_CELL_LABEL_HEIGHT + PC_PHOTO_CELL_PADDING_BOTTOM);
    self.photoView.photoImageView.clipsToBounds = YES;
    
    self.feelingTextField.frame = CGRectMake(self.photoView.frame.origin.x + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, CGRectGetMaxY(self.topBar.frame), PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, CGRectGetMinY(self.photoView.frame) - CGRectGetMaxY(self.topBar.frame));
    self.feelingTextField.textFieldInsets = UIEdgeInsetsMake(0, 0, PC_PHOTO_CELL_MARGIN_TOP, 0);
    
}

- (void)viewDidUnload {
    [self setTopBar:nil];
    [self setFeelingTextField:nil];
    [self setBottomBar:nil];
    [self setPhotoView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    [self.topBar setViewMode:BrandingCenter animated:NO];
    [self.topBar showButtonType:DoneButton inPosition:RightNormal animated:NO];
    [self.topBar addTarget:self selector:@selector(doneButtonTouched:) forButtonPosition:RightNormal];
    if (self.feelingImageSquare != nil) {
        [self.topBar showButtonType:BackButton inPosition:LeftNormal animated:NO];
        [self.topBar addTarget:self selector:@selector(backButtonTouched:) forButtonPosition:LeftNormal];
    } else {
        // Shouldn't ever get here...
//        [self.topBar showButtonType:CancelButton inPosition:LeftNormal animated:NO];
        NSLog(@"LOGIC ERROR in SubmitPhotoViewController - viewWillAppear");
    }
    [self updateViewsWithCurrentData];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.shouldPushImagePicker) {
        [self pushImagePicker];
        self.shouldPushImagePicker = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) pushImagePicker {
    
    UIImagePickerController * imagePickerControllerToPresent = nil;
    CameraOverlayView * cameraOverlayView = nil;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        self.imagePickerControllerCamera = [[UIImagePickerController alloc] init];
        self.imagePickerControllerCamera.delegate = self;
        self.imagePickerControllerCamera.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        self.imagePickerControllerCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerControllerCamera.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        self.imagePickerControllerCamera.showsCameraControls = NO;
        self.imagePickerControllerCamera.allowsEditing = NO;
        
        BOOL frontCameraAvailable = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
        BOOL rearCameraAvailable = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
        self.imagePickerControllerCamera.cameraDevice = frontCameraAvailable ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
        
        cameraOverlayView = [[CameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cameraOverlayView.swapCamerasButton.hidden = !(frontCameraAvailable && rearCameraAvailable);
        if (self.feelingWord && self.feelingWord.length > 0) {
            [cameraOverlayView setFeelingText:self.feelingWord];//.lowercaseString];
        }
        //        self.imagePickerControllerCamera.cameraOverlayView = cameraOverlayView;
        
        self.cameraOverlayViewHandler = [[CameraOverlayViewHandler alloc] init];
        self.cameraOverlayViewHandler.delegate = self;
        self.cameraOverlayViewHandler.imagePickerController = self.imagePickerControllerCamera;
        self.cameraOverlayViewHandler.cameraOverlayView = cameraOverlayView;
        if (self.feelingImageSquare != nil) {
            [self.cameraOverlayViewHandler showImageReview:self.feelingImageSquare];
        }
//        if (self.feelingImageOriginal != nil) {
//            [self.cameraOverlayViewHandler showImageReview:self.feelingImageOriginal];
//        }
        
        imagePickerControllerToPresent = self.imagePickerControllerCamera;
        
    } else {
        
        self.imagePickerControllerLibrary = [[UIImagePickerController alloc] init];
        self.imagePickerControllerLibrary.delegate = self;
        self.imagePickerControllerLibrary.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        self.imagePickerControllerLibrary.sourceType = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        self.imagePickerControllerLibrary.allowsEditing = YES;
        
        imagePickerControllerToPresent = self.imagePickerControllerLibrary;
    }
    
    [self presentModalViewController:imagePickerControllerToPresent animated:NO];
    if (cameraOverlayView != nil) {
        [imagePickerControllerToPresent.view addSubview:cameraOverlayView];//.window addSubview:cameraOverlayView];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:NO];
    if (picker == self.imagePickerControllerCamera) {
        self.imagePickerControllerCamera = nil;
        self.cameraOverlayViewHandler = nil;
        [self.delegate submitPhotoViewControllerDidCancel:self];
    } else {
        self.imagePickerControllerLibrary = nil;
        if (self.imagePickerControllerCamera != nil) {
            [self presentModalViewController:self.imagePickerControllerCamera animated:NO];
        } else {
            [self.delegate submitPhotoViewControllerDidCancel:self];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"imagePickerController didFinishPickingMedia");
    
    if (picker == self.imagePickerControllerCamera) {
        
        NSLog(@"captured camera media, showing for review");
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];

        NSLog(@"  image size (to start) = %@", NSStringFromCGSize(image.size));
        if (image.size.width != image.size.height) {
            image = [image imageWithEmotishCameraViewCrop];
        }
        NSLog(@"  image size (cropped)  = %@", NSStringFromCGSize(image.size));
        
        self.feelingImageSquare = image;
        [self.cameraOverlayViewHandler showImageReview:self.feelingImageSquare];
        
    } else {
        
        NSLog(@"picked library media, should move on");
        
        UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
        NSLog(@"  image size = %@", NSStringFromCGSize(image.size));
        NSLog(@"  image orientation = %@", [UIImage stringForImageOrientation:image.imageOrientation]);
        if (image.size.width != image.size.height) {
            CGFloat minSideLength = MIN(image.size.width, image.size.height);
            image = [image imageWithCrop:CGRectMake(floorf((image.size.width - minSideLength) / 2.0), floorf((image.size.height - minSideLength) / 2.0), minSideLength, minSideLength)];
        }
        
        // I CAN NOT FOR THE LIFE OF ME FIGURE OUT CROPPING UIIMAGES...
//        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
////        UIImage * imageEdited = [info objectForKey:UIImagePickerControllerEditedImage];
//        CGRect imageCropRect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
//        NSLog(@"  imageCropRect (to start) = %@", NSStringFromCGRect(imageCropRect));
//
//        imageCropRect.size.width = MIN(image.size.width, imageCropRect.size.width);
//        imageCropRect.size.height = MIN(image.size.height, imageCropRect.size.height);
//        BOOL specialCaseShouldCenterCropRect = CGSizeEqualToSize(image.size, imageCropRect.size);
//        CGFloat minSideLength = MAX(imageCropRect.size.width, imageCropRect.size.height);
//        minSideLength = MIN(image.size.width - imageCropRect.origin.x, minSideLength);
//        minSideLength = MIN(image.size.height - imageCropRect.origin.y, minSideLength);
//        imageCropRect.size = CGSizeMake(minSideLength, minSideLength);
//        if (specialCaseShouldCenterCropRect) {
//            imageCropRect.origin.x = floorf((image.size.width  - imageCropRect.size.width)  / 2.0);
//            imageCropRect.origin.y = floorf((image.size.height - imageCropRect.size.height) / 2.0);
//        }
//        
//        NSLog(@"  imageCropRect (adjusted) = %@", NSStringFromCGRect(imageCropRect));
//        NSLog(@"  image.size (to start)    = %@", NSStringFromCGSize(image.size));
//        image = [image imageWithCrop:imageCropRect];
//        NSLog(@"  image.size (cropped)     = %@", NSStringFromCGSize(image.size));

        self.feelingImageSquare = image;
        self.feelingWord = self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField.text;
        self.userName = self.photoView.photoCaptionLabel.text;
        
        [self updateViewsWithCurrentData];
        [self dismissModalViewControllerAnimated:NO];
        self.imagePickerControllerLibrary = nil;
        
    }
}

- (void)cameraOverlayViewHandlerRequestedLibraryPicker:(CameraOverlayViewHandler *)cameraOverlayViewHandler {
    
    self.imagePickerControllerLibrary = [[UIImagePickerController alloc] init];
    self.imagePickerControllerLibrary.delegate = self;
    self.imagePickerControllerLibrary.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    self.imagePickerControllerLibrary.sourceType = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    self.imagePickerControllerLibrary.allowsEditing = YES;
    [self dismissModalViewControllerAnimated:NO];
    [self presentModalViewController:self.imagePickerControllerLibrary animated:NO];
    
}

- (void)cameraOverlayViewHandler:(CameraOverlayViewHandler *)cameraOverlayViewHandler acceptedImage:(UIImage *)image withFeelingText:(NSString *)feelingText {
    
    NSLog(@"captured camera media, should move on");
    
    self.feelingWord = feelingText;
    self.feelingImageSquare = image;
    self.userName = self.photoView.photoCaptionLabel.text;
    [self updateViewsWithCurrentData];
    
    [self dismissModalViewControllerAnimated:NO];
    self.imagePickerControllerCamera = nil;
    self.cameraOverlayViewHandler = nil;
    
}

- (void)updateViewsWithCurrentData {
    self.feelingTextField.text = self.feelingWord && self.feelingWord.length > 0 ? self.feelingWord : SPVC_FEELING_PLACEHOLDER_TEXT;
    self.photoView.photoImageView.image = self.feelingImageSquare;
    self.photoView.photoCaptionLabel.text = self.userName && self.userName.length > 0 ? self.userName : SPVC_USER_PLACEHOLDER_TEXT;
    self.photoView.photoCaptionLabel.textColor = [UIColor userColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
    if (textField == self.feelingTextField) {
        shouldReturn = NO;
        [textField resignFirstResponder];
    }
    return shouldReturn;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.feelingTextField) {
        if ([textField.text isEqualToString:SPVC_FEELING_PLACEHOLDER_TEXT]) {
            textField.text = @"";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        textField.text = SPVC_FEELING_PLACEHOLDER_TEXT;
    }
}

- (void) backButtonTouched:(UIButton *)button {
    NSLog(@"backButtonTouched");
    [self pushImagePicker];
}

- (void) doneButtonTouched:(UIButton *)button {
    NSLog(@"doneButtonTouched");
//    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"yyyyMMdd";
    NSDate * now = [NSDate date];
//    NSString * todayFormatted = [dateFormatter stringFromDate:now];
    NSString * nowString = [NSString stringWithFormat:@"%d", abs([now timeIntervalSince1970])];
    NSString * filename = [NSString stringWithFormat:@"%@-%@-%@", self.feelingWord, self.userName, nowString];
    NSLog(@"Going to use local filename : %@", filename);
    [UIImage saveImage:self.feelingImageSquare withFilename:filename];
    Photo * photoAdded = [self.coreDataManager addPhotoWithFilename:filename forFeelingWord:self.feelingWord fromUsername:self.userName];
    [self.delegate submitPhotoViewController:self didSubmitPhoto:photoAdded withImage:self.feelingImageSquare];
}

@end
