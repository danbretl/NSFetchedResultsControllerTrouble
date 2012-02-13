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

@implementation SubmitPhotoViewController

@synthesize topBar=_topBar, feelingTextField=_feelingTextField, photoView=_photoView, bottomBar=_bottomBar;
@synthesize feelingImage=_feelingImage, feelingWord=_feelingWord, userName=_userName;

@synthesize shouldPushImagePicker=_shouldPushImagePicker;
@synthesize imagePickerControllerCamera=_imagePickerControllerCamera, imagePickerControllerLibrary=_imagePickerControllerLibrary, cameraOverlayViewHandler=_cameraOverlayViewHandler, addPhotoImage=_addPhotoImage;
@synthesize delegate=_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    self.photoView.frame = CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, 0, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL * 2, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM + PC_PHOTO_CELL_LABEL_HEIGHT + PC_PHOTO_CELL_PADDING_BOTTOM);
    
    self.feelingTextField.frame = CGRectMake(self.photoView.frame.origin.x + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, CGRectGetMaxY(self.topBar.frame), PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, CGRectGetMinY(self.photoView.frame) - CGRectGetMaxY(self.topBar.frame));
    
    self.photoView.photoImageView.image = self.feelingImage;
    self.photoView.photoCaptionLabel.text = self.userName;
    self.feelingTextField.text = self.feelingWord;
    
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
            [cameraOverlayView setFeelingText:self.feelingWord.lowercaseString];
        }
        //        self.imagePickerControllerCamera.cameraOverlayView = cameraOverlayView;
        
        self.cameraOverlayViewHandler = [[CameraOverlayViewHandler alloc] init];
        self.cameraOverlayViewHandler.delegate = self;
        self.cameraOverlayViewHandler.imagePickerController = self.imagePickerControllerCamera;
        self.cameraOverlayViewHandler.cameraOverlayView = cameraOverlayView;
        
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
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }    
    if (picker == self.imagePickerControllerCamera) {
        //    [self.cameraOverlayViewHandler showImageReview:[image imageWithEmotishCrop]];
        NSLog(@"captured camera media, showing for review");
        [self.cameraOverlayViewHandler showImageReview:image];
    } else {
        NSLog(@"picked library media, should move on");
        [self dismissModalViewControllerAnimated:NO];
        self.imagePickerControllerLibrary = nil;
        self.addPhotoImage = image;
        NSString * feelingText = self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField.text;
        NSLog(@"image size:%@, feeling text:%@", NSStringFromCGSize(self.addPhotoImage.size), feelingText && feelingText.length > 0 ? feelingText : @"(none)");

        [self.delegate submitPhotoViewControllerDidSubmitPhoto:self];
        
        //        SubmitPhotoViewController * submitPhotoViewController = [[SubmitPhotoViewController alloc] initWithNibName:@"SubmitPhotoViewController" bundle:[NSBundle mainBundle]];
        //        submitPhotoViewController.feelingImage = image;
        //        submitPhotoViewController.feelingWord = feelingText;
        //        submitPhotoViewController.userName = @"unknown user";
        //        [self.navigationController pushViewController:submitPhotoViewController animated:NO];
        
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
    
    [self dismissModalViewControllerAnimated:NO];
    self.imagePickerControllerCamera = nil;
    self.cameraOverlayViewHandler = nil;
    self.addPhotoImage = [image imageWithEmotishCrop];
    NSLog(@"image size:%@, feeling text:%@", NSStringFromCGSize(self.addPhotoImage.size), feelingText && feelingText.length > 0 ? feelingText : @"(none)");
    
    [self.delegate submitPhotoViewControllerDidSubmitPhoto:self];
    
    //    SubmitPhotoViewController * submitPhotoViewController = [[SubmitPhotoViewController alloc] initWithNibName:@"SubmitPhotoViewController" bundle:[NSBundle mainBundle]];
    //    submitPhotoViewController.feelingImage = image;
    //    submitPhotoViewController.feelingWord = feelingText;
    //    submitPhotoViewController.userName = @"unknown user";
    //    [self.navigationController pushViewController:submitPhotoViewController animated:NO];
    
}

@end
