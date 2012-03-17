//
//  SubmitPhotoViewController.m
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubmitPhotoViewController.h"
#import "SubmitPhotoShared.h"
#import "ViewConstants.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+Crop.h"
#import "UIColor+Emotish.h"
#import "NotificationConstants.h"
#import "EmotishAlertViews.h"
#import "FeelingWordCell.h"
#import "CameraConstants.h"
#import "SDImageCache.h"
#import "SDNetworkActivityIndicator.h"

static NSString * SPVC_USER_PLACEHOLDER_TEXT = @"log in / create account";
const CGFloat SPVC_SHARE_CONTAINER_MARGIN_TOP = 0.0;
const CGFloat SPVC_SHARE_CONTAINER_HEIGHT = 44.0;
const CGFloat SPVC_FEELINGS_TABLE_VIEW_ROW_HEIGHT_SUBMISSION = 40.0;
const CGFloat SPVC_FEELINGS_TABLE_VIEW_ROW_HEIGHT_CAMERA = 40.0;
const CGFloat SPVC_FEELINGS_TABLE_VIEW_MARGIN_TOP = -8.0;
const CGFloat SPVC_FEELINGS_TABLE_VIEW_PADDING_BOTTOM = 5.0;
const CGFloat APPLE_SCROLL_INDICATOR_THICKNESS = 5.0; // HARD-CODED, COULD CHANGE SOMEDAY
const CGFloat SPVC_FEELINGS_TABLE_VIEW_CAMERA_PADDING_VERTICAL = 10.0;

@interface SubmitPhotoViewController()
- (void) updateViewsWithCurrentData;
- (void) backButtonTouched:(UIButton *)button;
- (void) doneButtonTouched:(UIButton *)button;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
@property (strong, nonatomic, readonly) UIAlertView * logOutConfirmAlertView;
@property (strong, nonatomic, readonly) UIAlertView * noFeelingAlertView;
@property (strong, nonatomic, readonly) UIAlertView * noUserAlertView;
- (void) showAccountViewController;
- (void) showAccountViewControllerAndAttemptConnectionVia:(AccountConnectMethod)connectMethod;
- (IBAction)shareButtonTouchedDown:(UIButton *)shareButton;
- (IBAction)shareButtonTouched:(UIButton *)shareButton;
@property (nonatomic) BOOL facebookShareEnabled;
@property (nonatomic) BOOL twitterShareEnabled;
@property (nonatomic) BOOL waitingForFacebookPost;
@property (nonatomic) BOOL waitingForTwitterPost;
- (void) attemptSubmissionCompletion;
@property (nonatomic, strong) Photo * submittedPhoto;
@property (nonatomic, strong) UIImage * submittedImage;
- (NSArray *) feelingsFrom:(NSArray *)arrayOfFeelings matchingString:(NSString *)inputString;
- (BOOL)feelingInputExistsForTableView:(UITableView *)tableView;
//- (BOOL)feelingInputIsSubstantial:(NSString *)feelingInput;
//@property (nonatomic) BOOL feelingInputExists;
- (void) textFieldDidChangeText:(UITextField *)textField;
@end

@implementation SubmitPhotoViewController
@synthesize shareContainer = _shareContainer;
@synthesize shareLabel = _shareLabel;
@synthesize twitterButton = _twitterButton;
@synthesize facebookButton = _facebookButton;
@synthesize feelingsTableView=_feelingsTableView, feelingsTableViewCamera=_feelingsTableViewCamera, feelings=_feelings, feelingsMatched=_feelingsMatched;
//@synthesize feelingInputExists=_feelingInputExists;

@synthesize topBar=_topBar, feelingTextField=_feelingTextField, photoView=_photoView, bottomBar=_bottomBar;
@synthesize /*feelingImageOriginal=_feelingImageOriginal,*/ feelingImageSquare=_feelingImageSquare, feelingWord=_feelingWord;
@synthesize coreDataManager=_coreDataManager;

@synthesize shouldPushImagePicker=_shouldPushImagePicker;
@synthesize imagePickerControllerCamera=_imagePickerControllerCamera, imagePickerControllerLibrary=_imagePickerControllerLibrary, cameraOverlayViewHandler=_cameraOverlayViewHandler;
@synthesize logOutConfirmAlertView=_logOutConfirmAlertView, noFeelingAlertView=_noFeelingAlertView, noUserAlertView=_noUserAlertView;
@synthesize facebookShareEnabled=_facebookShareEnabled, twitterShareEnabled=_twitterShareEnabled;
@synthesize facebookPostPhotoRequest=_facebookPostPhotoRequest;
@synthesize waitingForFacebookPost=_waitingForFacebookPost, waitingForTwitterPost=_waitingForTwitterPost, submittedPhoto=_submittedPhoto, submittedImage=_submittedImage;
@synthesize delegate=_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.feelingImageOriginal = nil;
        self.feelingImageSquare = nil;
        self.feelingWord = SUBMIT_PHOTO_FEELING_PLACEHOLDER_TEXT;
        self.feelings = nil;
        self.feelingsMatched = nil;
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
    self.photoView.userInteractionEnabled = YES;
    self.photoView.photoCaptionTextField.textColor = [UIColor userColor];
    self.photoView.delegate = self;
    self.photoView.actionButtonsEnabled = NO;
    [self.photoView showInfo:NO animated:NO];
    
//    self.feelingTextField.frame = CGRectMake(self.photoView.frame.origin.x + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, CGRectGetMaxY(self.topBar.frame), PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, CGRectGetMinY(self.photoView.frame) - CGRectGetMaxY(self.topBar.frame));
//    self.feelingTextField.textFieldInsets = UIEdgeInsetsMake(0, 0, PC_PHOTO_CELL_MARGIN_TOP, 0);
    self.topBar.backgroundFlagView.overlayImageViewVisibleHangOutDistance = 4.0;

    // The following is still not matching up perfectly with PhotosStripViewController headerButton when font size is being adjusted for a long string.
    self.feelingTextField.frame = CGRectMake(0, 0, 320, CGRectGetMinY(self.photoView.frame));
    self.feelingTextField.textFieldInsets = UIEdgeInsetsMake(0, self.photoView.frame.origin.x + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, PC_PHOTO_CELL_MARGIN_TOP, 320 - (CGRectGetMaxX(self.photoView.frame) - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL));
    self.feelingTextField.backgroundColor = [UIColor clearColor];
    CAGradientLayer * feelingTextFieldGradientLayer = [CAGradientLayer layer];
    feelingTextFieldGradientLayer.frame = self.feelingTextField.bounds;
    feelingTextFieldGradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor, nil];
    feelingTextFieldGradientLayer.locations = [NSArray arrayWithObjects:(id)[NSNumber numberWithFloat:0.95], (id)[NSNumber numberWithFloat:1.0], nil];
    [self.feelingTextField.layer addSublayer:feelingTextFieldGradientLayer];
    
    self.shareContainer.frame = CGRectMake(self.feelingTextField.textFieldInsets.left, CGRectGetMaxY(self.photoView.frame) + SPVC_SHARE_CONTAINER_MARGIN_TOP, self.feelingTextField.frame.size.width - (self.feelingTextField.textFieldInsets.left + self.feelingTextField.textFieldInsets.right), SPVC_SHARE_CONTAINER_HEIGHT);
    self.shareContainer.backgroundColor = [UIColor whiteColor];
    self.shareLabel.textColor = [UIColor colorWithRed:140.0/255.0 green:142.0/255.0 blue:143.0/255.0 alpha:1.0];
    [self.facebookButton setImage:[UIImage imageNamed:@"btn_share_facebook_touch.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
    [self.twitterButton setImage:[UIImage imageNamed:@"btn_share_twitter_touch.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
    
    // Init
    self.feelingsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - floorf(((self.view.bounds.size.width - (PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X + PC_PHOTO_CELL_IMAGE_SIDE_LENGTH)) - APPLE_SCROLL_INDICATOR_THICKNESS) / 2.0), self.view.bounds.size.height) style:UITableViewStylePlain];
    // Basic setup
    self.feelingsTableView.backgroundColor = [UIColor whiteColor];
    self.feelingsTableView.opaque = YES;
    self.feelingsTableView.delegate = self;
    self.feelingsTableView.dataSource = self;
    self.feelingsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.feelingsTableView.alpha = 0.0;
    self.feelingsTableView.showsVerticalScrollIndicator = NO;
    // More setup
    self.feelingsTableView.rowHeight = SPVC_FEELINGS_TABLE_VIEW_ROW_HEIGHT_SUBMISSION;
    UIEdgeInsets feelingsTableViewInsets = UIEdgeInsetsMake(CGRectGetMaxY(self.feelingTextField.frame) + SPVC_FEELINGS_TABLE_VIEW_MARGIN_TOP, 0, self.bottomBar.frame.size.height + SPVC_FEELINGS_TABLE_VIEW_PADDING_BOTTOM, 0);
    self.feelingsTableView.contentInset = feelingsTableViewInsets;
    self.feelingsTableView.scrollIndicatorInsets = feelingsTableViewInsets;
    // Add subview
    [self.view insertSubview:self.feelingsTableView belowSubview:self.feelingTextField];
    
    // Init
    self.feelingsTableViewCamera = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain]; // Frame will be updated later when cameraOverlayView is set up
    // Basic setup
    self.feelingsTableViewCamera.backgroundColor = [UIColor whiteColor];
    self.feelingsTableViewCamera.opaque = YES;
    self.feelingsTableViewCamera.delegate = self;
    self.feelingsTableViewCamera.dataSource = self;
    self.feelingsTableViewCamera.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.feelingsTableViewCamera.alpha = 0.0;
    self.feelingsTableViewCamera.showsVerticalScrollIndicator = NO;
    // More setup
    // The rest is set up later when cameraOverlayView has been set up
    // Add subview
    // This table view is added to the cameraOverlayView's subviews later
    
    self.feelings = [self.coreDataManager getAllObjectsForEntityName:@"Feeling" predicate:[NSPredicate predicateWithFormat:@"ANY photos.hidden == NO"] sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"word" ascending:YES]]];
    self.feelingsMatched = self.feelings;
    
    // Register for keyboard events
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewDidUnload {
    [self setTopBar:nil];
    [self setFeelingTextField:nil];
    [self setBottomBar:nil];
    [self setPhotoView:nil];
    [self setShareContainer:nil];
    [self setShareLabel:nil];
    [self setTwitterButton:nil];
    [self setFacebookButton:nil];
    [self setFeelingsTableView:nil];
    [self setFeelingsTableViewCamera:nil];
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
        
        UIImagePickerControllerCameraDevice cameraDevice;
        NSNumber * cameraDeviceLastUsed = [[NSUserDefaults standardUserDefaults] objectForKey:CAMERA_DEVICE_LAST_USED_USER_DEFAULTS_KEY];
        if (cameraDeviceLastUsed != nil && 
            [UIImagePickerController isCameraDeviceAvailable:cameraDeviceLastUsed.intValue]) {
            cameraDevice = cameraDeviceLastUsed.intValue;
        } else {
            cameraDevice = frontCameraAvailable ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
        }
        self.imagePickerControllerCamera.cameraDevice = cameraDevice;
        [[NSUserDefaults standardUserDefaults] setInteger:cameraDevice forKey:CAMERA_DEVICE_LAST_USED_USER_DEFAULTS_KEY];
        
        self.imagePickerControllerCamera.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff; // Not even going to give the option to use flash for now. People at bars might get angry...
        
        cameraOverlayView = [[CameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cameraOverlayView.swapCamerasButton.hidden = !(frontCameraAvailable && rearCameraAvailable);
        if (self.feelingWord && self.feelingWord.length > 0) {
            [cameraOverlayView setFeelingText:self.feelingWord];//.lowercaseString];
        }
        self.feelingsTableViewCamera.alpha = 0.0;
        [cameraOverlayView insertSubview:self.feelingsTableViewCamera belowSubview:cameraOverlayView.topBar];
        self.feelingsTableViewCamera.frame = cameraOverlayView.bounds;
        self.feelingsTableViewCamera.rowHeight = SPVC_FEELINGS_TABLE_VIEW_ROW_HEIGHT_CAMERA;
        UIEdgeInsets feelingsTableViewCameraInsets = UIEdgeInsetsMake(cameraOverlayView.topBar.frame.size.height + SPVC_FEELINGS_TABLE_VIEW_CAMERA_PADDING_VERTICAL, 0, cameraOverlayView.bottomBar.frame.size.height + SPVC_FEELINGS_TABLE_VIEW_CAMERA_PADDING_VERTICAL, 0);
        self.feelingsTableViewCamera.contentInset = feelingsTableViewCameraInsets;
        self.feelingsTableViewCamera.scrollIndicatorInsets = feelingsTableViewCameraInsets;
        //        self.imagePickerControllerCamera.cameraOverlayView = cameraOverlayView;
        
        self.cameraOverlayViewHandler = [[CameraOverlayViewHandler alloc] init];
        self.cameraOverlayViewHandler.delegate = self;
        self.cameraOverlayViewHandler.imagePickerController = self.imagePickerControllerCamera;
        self.cameraOverlayViewHandler.cameraOverlayView = cameraOverlayView;
        self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField.delegate = self;
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
        
        self.feelingImageSquare = image.imageScaledDownToEmotishFull;
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

        self.feelingImageSquare = image.imageScaledDownToEmotishFull;
        self.feelingWord = self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField.text;
        
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
    self.feelingImageSquare = image.imageScaledDownToEmotishFull;
    [self updateViewsWithCurrentData];
    
    [self dismissModalViewControllerAnimated:NO];
    self.imagePickerControllerCamera = nil;
    self.cameraOverlayViewHandler = nil;
    
}

- (void)updateViewsWithCurrentData {
    
    self.feelingTextField.text = self.feelingWord && self.feelingWord.length > 0 ? self.feelingWord : SUBMIT_PHOTO_FEELING_PLACEHOLDER_TEXT;
    
    self.photoView.photoImageView.image = self.feelingImageSquare;
    self.photoView.photoCaptionTextField.text = [PFUser currentUser] != nil ? ((PFUser *)[PFUser currentUser]).username : SPVC_USER_PLACEHOLDER_TEXT;
    
    self.facebookButton.selected = self.facebookShareEnabled;
    self.twitterButton.selected = self.twitterShareEnabled;
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == self.feelingTextField ||
        textField == self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField) {
        
        if ([textField.text isEqualToString:SUBMIT_PHOTO_FEELING_PLACEHOLDER_TEXT]) {
            textField.text = @"";
        }
        self.feelingsMatched = [self feelingsFrom:self.feelings matchingString:textField.text];
        
        UITableView * feelingsTableView = (textField == self.feelingTextField) ? self.feelingsTableView : self.feelingsTableViewCamera;
        [feelingsTableView reloadData];
        feelingsTableView.contentOffset = CGPointMake(0, -feelingsTableView.contentInset.top);
                
        [UIView animateWithDuration:0.25 animations:^{
            feelingsTableView.alpha = 1.0;
        }];
        
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
    if (textField == self.feelingTextField ||
        textField == self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField) {
        [textField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
//        [self.feelingTextField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
//        [cameraOverlayView.feelingTextField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
        // The following has been moved to textFieldShouldBeginEditing
//        if ([textField.text isEqualToString:SUBMIT_PHOTO_FEELING_PLACEHOLDER_TEXT]) {
//            textField.text = @"";
//        }
    }
}

- (NSArray *) feelingsFrom:(NSArray *)arrayOfFeelings matchingString:(NSString *)inputString {
    return inputString.length > 0 ? [[arrayOfFeelings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.word beginswith[cd] %@", inputString]] arrayByAddingObjectsFromArray:[arrayOfFeelings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF.word beginswith[cd] %@ AND SELF.word contains[cd] %@", inputString, inputString]]] : arrayOfFeelings;
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (textField == self.feelingTextField ||
//        textField == self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField) {
//        NSString * upcomingTextFieldString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        self.feelingsMatched = [self feelingsFrom:self.feelings matchingString:upcomingTextFieldString];
//        UITableView * feelingsTableView = (textField == self.feelingTextField) ? self.feelingsTableView : self.feelingsTableViewCamera;
//        [feelingsTableView reloadData];
//        [feelingsTableView setContentOffset:CGPointMake(0, -feelingsTableView.contentInset.top) animated:NO];
//        if (textField == self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField) {
//            [self.cameraOverlayViewHandler.cameraOverlayView adjustFeelingPromptLabelForFeelingString:upcomingTextFieldString];
//        }
//    }
//    return YES;
//}

- (void)textFieldDidChangeText:(UITextField *)textField {
    if (textField == self.feelingTextField ||
        textField == self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField) {
        self.feelingsMatched = [self feelingsFrom:self.feelings matchingString:textField.text];
        UITableView * feelingsTableView = (textField == self.feelingTextField) ? self.feelingsTableView : self.feelingsTableViewCamera;
        [feelingsTableView reloadData];
        [feelingsTableView setContentOffset:CGPointMake(0, -feelingsTableView.contentInset.top) animated:NO];
        if (textField == self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField) {
            [self.cameraOverlayViewHandler.cameraOverlayView adjustFeelingPromptLabelForFeelingString:textField.text];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
    if (textField == self.feelingTextField ||
        textField == self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField) {
        shouldReturn = NO;
        [textField resignFirstResponder];
    }
    return shouldReturn;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");
    [textField removeTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    if (textField == self.feelingTextField ||
        textField == self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField) {
        
        UITableView * feelingsTableView = (textField == self.feelingTextField) ? self.feelingsTableView : self.feelingsTableViewCamera;
        [UIView animateWithDuration:0.25 animations:^{
            feelingsTableView.alpha = 0.0;
        }];
        if ([textField.text isEqualToString:@""]) {
            textField.text = SUBMIT_PHOTO_FEELING_PLACEHOLDER_TEXT;
        } else {
            textField.text = [textField.text.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        if (textField == self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField) {
            [self.cameraOverlayViewHandler.cameraOverlayView adjustFeelingPromptLabelForFeelingString:textField.text];
        }
        self.feelingWord = textField.text;
    }
}

- (void)photoView:(PhotoView *)photoView photoCaptionButtonTouched:(UIButton *)photoCaptionButton {
    if ([PFUser currentUser]) {
        [self.logOutConfirmAlertView show];
    } else {
        [self showAccountViewController];
    }
}

- (IBAction)shareButtonTouchedDown:(UIButton *)shareButton {
    shareButton.selected = YES;
}

- (IBAction)shareButtonTouched:(UIButton *)shareButton {
    if ([PFUser currentUser] != nil) {
        if (shareButton == self.facebookButton) {
            if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
                self.facebookShareEnabled = !self.facebookShareEnabled;
                self.facebookButton.selected = self.facebookShareEnabled;
            } else {
                self.view.userInteractionEnabled = NO;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:NOTIFICATION_APPLICATION_DID_BECOME_ACTIVE object:nil];
                [[PFFacebookUtils facebook].sessionDelegate fbDidNotLogin:YES];
                [PFFacebookUtils linkUser:[PFUser currentUser] permissions:[NSArray arrayWithObjects:@"email", @"offline_access", @"publish_stream", nil] block:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        if (succeeded) {
                            NSLog(@"Woohoo, user logged in with Facebook!");
                            self.facebookShareEnabled = YES;
                        }
                    } else {
                        if (error.code == kPFErrorAccountAlreadyLinked) {
                            [[EmotishAlertViews facebookAccountTakenByOtherUserAlertView] show];
                        } else {
                            [[EmotishAlertViews facebookConnectionErrorAlertView] show];
                        }
                    }
                    self.facebookButton.selected = self.facebookShareEnabled;                    
                    self.view.userInteractionEnabled = YES;
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_APPLICATION_DID_BECOME_ACTIVE object:nil];
                }];
            }
        } else {
            if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
                self.twitterShareEnabled = !self.twitterShareEnabled;
                self.twitterButton.selected = self.twitterShareEnabled;
            } else {
                self.view.userInteractionEnabled = NO;
                [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        if (succeeded) {
                            NSLog(@"Woohoo, user logged in with Twitter!");
                            self.twitterShareEnabled = YES;
                        }
                    } else {
                        if (error.code == kPFErrorAccountAlreadyLinked) {
                            [[EmotishAlertViews twitterAccountTakenByOtherUserAlertView] show];
                        } else {
                            [[EmotishAlertViews twitterConnectionErrorAlertView] show];
                        }
                    }
                    self.twitterButton.selected = self.twitterShareEnabled;                    
                    self.view.userInteractionEnabled = YES;
                }];
            }
        }
    } else {
        [self showAccountViewControllerAndAttemptConnectionVia:(shareButton == self.facebookButton) ? FacebookAccountConnect : TwitterAccountConnect];
    }
}
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (![[notification.userInfo objectForKey:NOTIFICATION_USER_INFO_KEY_APPLICATION_OPENED_URL] boolValue]) {
        self.view.userInteractionEnabled = YES;
        self.facebookButton.selected = self.facebookShareEnabled;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_APPLICATION_DID_BECOME_ACTIVE object:nil];
}

- (void) backButtonTouched:(UIButton *)button {
    NSLog(@"backButtonTouched");
    [self.feelingTextField resignFirstResponder];
    [self pushImagePicker];
}

- (void) doneButtonTouched:(UIButton *)button {
    NSLog(@"doneButtonTouched");
        
    [self.feelingTextField resignFirstResponder];
        
    PFUser * currentUser = [PFUser currentUser];
    
    if ([self.feelingWord isEqualToString:SUBMIT_PHOTO_FEELING_PLACEHOLDER_TEXT]) {
        [self.noFeelingAlertView show];
    } else if (currentUser == nil) {
        [self.noUserAlertView show];
    } else {
        
        [[SDNetworkActivityIndicator sharedActivityIndicator] startActivity];
        [self.topBar.backgroundFlagView setOverlayImageViewVisible:YES animated:YES];
        
        NSLog(@"setting up filename");
        NSString * nowString = [NSString stringWithFormat:@"%d", abs([[NSDate date] timeIntervalSince1970])];
        NSString * filename = [NSString stringWithFormat:@"%@-%@-%@.jpg", [self.feelingWord.lowercaseString  stringByReplacingOccurrencesOfString:@" " withString:@""], ((PFUser *)[PFUser currentUser]).username, nowString];
        NSString * filenameThumb = [filename stringByReplacingOccurrencesOfString:@".jpg" withString:@"-thumb.jpg"];
        NSLog(@"  filename set to %@", filename);
        NSLog(@"  filename thumb set to %@", filename);
        
        NSLog(@"setting up imageFile");
        self.submittedImage = self.feelingImageSquare;
        NSData * imageData = UIImageJPEGRepresentation(self.submittedImage, 0.8);
        PFFile * imageFile = [PFFile fileWithName:filename data:imageData];    
        NSLog(@"  imageFile = %@", imageFile);
        
        NSLog(@"setting up imageFileThumb");
        UIImage * submittedImageThumb = self.submittedImage.imageScaledDownToEmotishThumb;
        NSData * imageThumbData = UIImageJPEGRepresentation(submittedImageThumb, 0.6);
        PFFile * imageThumbFile = [PFFile fileWithName:filenameThumb data:imageThumbData];
        NSLog(@"  imageThumbFile = %@", imageThumbFile);
        
        NSLog(@"saving imageFile");
        BOOL savingSuccess = [imageFile save];
        NSLog(@"  saving imageFile success? %d", savingSuccess);
        NSLog(@"  imageFile URL ? %@", imageFile.url);
        
        NSLog(@"saving imageFile");
        savingSuccess = [imageThumbFile save];
        NSLog(@"  saving imageThumbFile success? %d", savingSuccess);
        NSLog(@"  imageFile URL ? %@", imageThumbFile.url);
        
        NSLog(@"setting up feeling");
        Feeling * feelingLocal = (Feeling *)[self.coreDataManager getFirstObjectForEntityName:@"Feeling" matchingPredicate:[NSPredicate predicateWithFormat:@"word == %@", self.feelingWord.lowercaseString] usingSortDescriptors:nil];
        PFObject * feelingServer = nil;
        if (feelingLocal != nil) {
            feelingServer = [PFObject objectWithClassName:@"Feeling"];
            feelingServer.objectId = feelingLocal.serverID;
            [feelingServer setObject:feelingLocal.word forKey:@"word"];
        } else {
            PFQuery * feelingQuery = [PFQuery queryWithClassName:@"Feeling"];
            [feelingQuery whereKey:@"word" equalTo:self.feelingWord.lowercaseString];
            feelingServer = [feelingQuery getFirstObject];
            if (feelingServer == nil) {
                feelingServer = [PFObject objectWithClassName:@"Feeling"];
                [feelingServer setObject:self.feelingWord.lowercaseString forKey:@"word"];
            }
        }
        NSLog(@"  feelingServer = %@", feelingServer);
        
        NSLog(@"saving feelingServer");
        savingSuccess = [feelingServer save];
        NSLog(@"  saving feelingServer success? %d", savingSuccess);
        
        NSLog(@"setting up photo");
        PFObject * photoServer = [PFObject objectWithClassName:@"Photo"];
        [photoServer setObject:feelingServer forKey:@"feeling"];
        [photoServer setObject:currentUser forKey:@"user"];
        [photoServer setObject:imageFile forKey:@"image"];
        [photoServer setObject:imageThumbFile forKey:@"thumb"];
        NSLog(@"  photoServer = %@", photoServer);
        
        NSLog(@"saving photoServer");
        savingSuccess = [photoServer save];
        NSLog(@"  saving photoServer success? %d", savingSuccess);
        
        NSLog(@"getting full saved photo");
        photoServer = [PFQuery getObjectOfClass:@"Photo" objectId:photoServer.objectId];
        NSLog(@"  photo retrieved = %@", photoServer);
        
        self.submittedPhoto = [self.coreDataManager addOrUpdatePhotoFromServer:photoServer feelingFromServer:feelingServer userFromServer:currentUser];
//        self.submittedPhoto.shouldHighlight = [NSNumber numberWithBool:NO];
        [self.coreDataManager saveCoreData];
        
        // Facebook?
        if (self.facebookShareEnabled) {
            self.waitingForFacebookPost = YES;
            NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
            [parameters setObject:[NSString stringWithFormat:@"feeling %@", self.feelingWord.lowercaseString] forKey:@"message"];
            [parameters setObject:imageData forKey:@"source"];
            self.facebookPostPhotoRequest = [[PFFacebookUtils facebook] requestWithGraphPath:@"me/photos" andParams:parameters andHttpMethod:@"POST" andDelegate:self];
        }
        
        // Twitter?
        if (self.twitterShareEnabled) {
            self.waitingForTwitterPost = YES;
            // ...
            // ...
            // ...
            self.waitingForTwitterPost = NO;
        }
        
        self.submittedImage = [UIImage imageWithData:imageData];
        [[SDImageCache sharedImageCache] storeImage:self.submittedImage forKey:self.submittedPhoto.imageURL];
        [[SDImageCache sharedImageCache] storeImage:[UIImage imageWithData:imageThumbData] forKey:self.submittedPhoto.thumbURL];
        [self attemptSubmissionCompletion];
        
    }
    
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    NSLog(@"Successfully posted to Facebook");
    self.waitingForFacebookPost = NO;
    [self attemptSubmissionCompletion];
}

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to post to Facebook");
    self.waitingForFacebookPost = NO;
    [self attemptSubmissionCompletion];
}

- (void)attemptSubmissionCompletion {
    if (!(self.waitingForFacebookPost ||
          self.waitingForTwitterPost ||
          self.submittedImage == nil ||
          self.submittedPhoto == nil)) {
        [[SDNetworkActivityIndicator sharedActivityIndicator] stopActivity];
        [self.topBar.backgroundFlagView setOverlayImageViewVisible:NO animated:YES];
        [self.delegate submitPhotoViewController:self didSubmitPhoto:self.submittedPhoto withImage:self.submittedImage];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboardWillShow");
    NSDictionary * info = [notification userInfo];
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        // Submission Screen
        UIEdgeInsets feelingsTableContentInset = self.feelingsTableView.contentInset;
        feelingsTableContentInset.bottom = keyboardSize.height + SPVC_FEELINGS_TABLE_VIEW_PADDING_BOTTOM;
        self.feelingsTableView.contentInset = feelingsTableContentInset;
        UIEdgeInsets feelingsTableScrollInsets = self.feelingsTableView.scrollIndicatorInsets;
        feelingsTableScrollInsets.bottom = keyboardSize.height + SPVC_FEELINGS_TABLE_VIEW_PADDING_BOTTOM;
        self.feelingsTableView.scrollIndicatorInsets = feelingsTableScrollInsets;
        // Camera Screen
        UIEdgeInsets feelingsTableCameraContentInset = self.feelingsTableViewCamera.contentInset;
        feelingsTableCameraContentInset.bottom = keyboardSize.height + SPVC_FEELINGS_TABLE_VIEW_CAMERA_PADDING_VERTICAL;
        self.feelingsTableViewCamera.contentInset = feelingsTableCameraContentInset;
        UIEdgeInsets feelingsTableCameraScrollInsets = self.feelingsTableViewCamera.scrollIndicatorInsets;
        feelingsTableCameraScrollInsets.bottom = keyboardSize.height + SPVC_FEELINGS_TABLE_VIEW_CAMERA_PADDING_VERTICAL;
        self.feelingsTableViewCamera.scrollIndicatorInsets = feelingsTableCameraScrollInsets;
    } completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"keyboardWillHide");
    NSDictionary * info = [notification userInfo];
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        // Submission Screen
        UIEdgeInsets feelingsTableContentInset = self.feelingsTableView.contentInset;
        feelingsTableContentInset.bottom = self.bottomBar.frame.size.height + SPVC_FEELINGS_TABLE_VIEW_PADDING_BOTTOM;
        self.feelingsTableView.contentInset = feelingsTableContentInset;
        UIEdgeInsets feelingsTableScrollInsets = self.feelingsTableView.scrollIndicatorInsets;
        feelingsTableScrollInsets.bottom = self.bottomBar.frame.size.height + SPVC_FEELINGS_TABLE_VIEW_PADDING_BOTTOM;
        self.feelingsTableView.scrollIndicatorInsets = feelingsTableScrollInsets;    
        // Camera Screen
        UIEdgeInsets feelingsTableCameraContentInset = self.feelingsTableViewCamera.contentInset;
        feelingsTableCameraContentInset.bottom = self.cameraOverlayViewHandler.cameraOverlayView.bottomBar.frame.size.height + SPVC_FEELINGS_TABLE_VIEW_CAMERA_PADDING_VERTICAL;
        self.feelingsTableViewCamera.contentInset = feelingsTableCameraContentInset;
        UIEdgeInsets feelingsTableCameraScrollInsets = self.feelingsTableViewCamera.scrollIndicatorInsets;
        feelingsTableCameraScrollInsets.bottom = self.cameraOverlayViewHandler.cameraOverlayView.bottomBar.frame.size.height + SPVC_FEELINGS_TABLE_VIEW_CAMERA_PADDING_VERTICAL;
        self.feelingsTableViewCamera.scrollIndicatorInsets = feelingsTableCameraScrollInsets;
    } completion:NULL];
}

- (UIAlertView *)logOutConfirmAlertView {
    if (_logOutConfirmAlertView == nil) {
        _logOutConfirmAlertView = [[UIAlertView alloc] initWithTitle:@"Change Users?" message:@"Do you want to sign in to a different Emotish account?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change Users", nil];
        _logOutConfirmAlertView.delegate = self;
    }
    return _logOutConfirmAlertView;
}

- (UIAlertView *)noFeelingAlertView {
    if (_noFeelingAlertView == nil) {
        _noFeelingAlertView = [[UIAlertView alloc] initWithTitle:@"Enter Feeling" message:@"Please enter your Feeling for this Photo!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        _noFeelingAlertView.delegate = self;
    }
    return _noFeelingAlertView;
}

- (UIAlertView *)noUserAlertView {
    if (_noUserAlertView == nil) {
        _noUserAlertView = [[UIAlertView alloc] initWithTitle:@"Sign In" message:@"You must connect to an Emotish account to submit a Photo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        _noUserAlertView.delegate = self;
    }
    return _noUserAlertView;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.logOutConfirmAlertView) {
        if (buttonIndex != self.logOutConfirmAlertView.cancelButtonIndex) {
            [self showAccountViewController];
        }
    } else if (alertView == self.noFeelingAlertView) {
        [self.feelingTextField becomeFirstResponder];
    } else if (alertView == self.noUserAlertView) {
        [self showAccountViewController];
    }
}

- (void) showAccountViewController {
    [self showAccountViewControllerAndAttemptConnectionVia:0];
}

- (void) showAccountViewControllerAndAttemptConnectionVia:(AccountConnectMethod)connectMethod {
    AccountViewController * accountViewController = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:[NSBundle mainBundle]];
    accountViewController.delegate = self;
    accountViewController.coreDataManager = self.coreDataManager;
    accountViewController.swipeDownToCancelEnabled = YES;
    if (connectMethod != 0) {
        accountViewController.shouldImmediatelyAttemptFacebookConnect = connectMethod == FacebookAccountConnect;
        accountViewController.shouldImmediatelyAttemptTwitterConnect = connectMethod == TwitterAccountConnect;
    }
    [self presentModalViewController:accountViewController animated:YES];
}

- (void)accountViewController:(AccountViewController *)accountViewController didFinishWithConnection:(BOOL)finishedWithConnection viaConnectMethod:(AccountConnectMethod)connectMethod {
    if (finishedWithConnection) {
        self.facebookShareEnabled = connectMethod == FacebookAccountConnect;
        self.twitterShareEnabled = connectMethod == TwitterAccountConnect;
    }
    PFUser * currentUser = [PFUser currentUser];
    if (currentUser) {
        self.photoView.photoCaptionTextField.text = currentUser.username;
    } else {
        self.photoView.photoCaptionTextField.text = SPVC_USER_PLACEHOLDER_TEXT;
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    if ([self feelingInputExistsForTableView:tableView]) {
        rowCount = self.feelingsMatched.count + 1;
    } else {
        rowCount = self.feelingsMatched.count;
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get / Create the cell
    static NSString * CellID = @"FeelingWordCellID";
    FeelingWordCell * cell = (FeelingWordCell *)[tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[FeelingWordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:24.0];
    if (tableView == self.feelingsTableView) {
        cell.textLabelPadding = UIEdgeInsetsMake(0, PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X, 0, tableView.bounds.size.width - PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X - PC_PHOTO_CELL_IMAGE_SIDE_LENGTH);
//        cell.textLabel.font = self.feelingTextField.font;
    } else if (tableView == self.feelingsTableViewCamera) {
        cell.textLabelPadding = UIEdgeInsetsMake(0, CAMERA_VIEW_TOP_BAR_PADDING_HORIZONTAL, 0, CAMERA_VIEW_TOP_BAR_PADDING_HORIZONTAL);
//        cell.textLabel.font = self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField.font;
    }

    int feelingIndex = indexPath.row;
    UITextField * textField = tableView == self.feelingsTableView ? self.feelingTextField : self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField;
    if ([self feelingInputExistsForTableView:tableView] && indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:/*@"+*/@"%@", textField.text];
        cell.textLabel.textColor = [UIColor emotishColor];
    } else {
        cell.textLabel.textColor = [UIColor feelingColor];
        if ([self feelingInputExistsForTableView:tableView]) {
            feelingIndex--;
        }
        Feeling * feeling = [self.feelingsMatched objectAtIndex:feelingIndex];
        cell.textLabel.text = feeling.word;
    }
    
    // Return the cell
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * selectedString = nil;
    UITextField * textField = tableView == self.feelingsTableView ? self.feelingTextField : self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField;
    [textField removeTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    if ([self feelingInputExistsForTableView:tableView] && indexPath.row == 0) {
        selectedString = textField.text;
    } else {
        int selectedFeelingIndex = indexPath.row;
        if ([self feelingInputExistsForTableView:tableView]) {
            selectedFeelingIndex--;
        }
        Feeling * feeling = [self.feelingsMatched objectAtIndex:selectedFeelingIndex];
        textField.text = feeling.word;
    }
    [textField resignFirstResponder];
}

- (BOOL)feelingInputExistsForTableView:(UITableView *)tableView {
    UITextField * textField = tableView == self.feelingsTableView ? self.feelingTextField : self.cameraOverlayViewHandler.cameraOverlayView.feelingTextField;
    return textField.text.length > 0 && ![textField.text isEqualToString:SUBMIT_PHOTO_FEELING_PLACEHOLDER_TEXT];
}

@end
