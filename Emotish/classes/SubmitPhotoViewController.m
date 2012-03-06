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
#import "NotificationConstants.h"
#import "EmotishAlertViews.h"

static NSString * SPVC_FEELING_PLACEHOLDER_TEXT = @"something";
static NSString * SPVC_USER_PLACEHOLDER_TEXT = @"log in / create account";
const CGFloat SPVC_SHARE_CONTAINER_MARGIN_TOP = 0.0;
const CGFloat SPVC_SHARE_CONTAINER_HEIGHT = 44.0;

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

@end

@implementation SubmitPhotoViewController
@synthesize shareContainer = _shareContainer;
@synthesize shareLabel = _shareLabel;
@synthesize twitterButton = _twitterButton;
@synthesize facebookButton = _facebookButton;
@synthesize scrollView = _scrollView;

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
        self.feelingWord = SPVC_FEELING_PLACEHOLDER_TEXT;
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
//    self.photoView.photoCaptionTextField.userInteractionEnabled = YES;
//    self.photoView.button.userInteractionEnabled = NO;
//    self.photoView.photoCaptionTextField.delegate = self;
    self.photoView.photoCaptionTextField.textColor = [UIColor userColor];
    self.photoView.delegate = self;
    self.photoView.actionButtonsEnabled = NO;
    [self.photoView showLikes:NO animated:NO];
    
//    self.feelingTextField.frame = CGRectMake(self.photoView.frame.origin.x + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, CGRectGetMaxY(self.topBar.frame), PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, CGRectGetMinY(self.photoView.frame) - CGRectGetMaxY(self.topBar.frame));
//    self.feelingTextField.textFieldInsets = UIEdgeInsetsMake(0, 0, PC_PHOTO_CELL_MARGIN_TOP, 0);

    // The following is still not matching up perfectly with PhotosStripViewController headerButton when font size is being adjusted for a long string.
    self.feelingTextField.frame = CGRectMake(0, 0, 320, CGRectGetMinY(self.photoView.frame));
    self.feelingTextField.textFieldInsets = UIEdgeInsetsMake(0, self.photoView.frame.origin.x + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, PC_PHOTO_CELL_MARGIN_TOP, 320 - (CGRectGetMaxX(self.photoView.frame) - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL));
    
    self.shareContainer.frame = CGRectMake(self.feelingTextField.textFieldInsets.left, CGRectGetMaxY(self.photoView.frame) + SPVC_SHARE_CONTAINER_MARGIN_TOP, self.feelingTextField.frame.size.width - (self.feelingTextField.textFieldInsets.left + self.feelingTextField.textFieldInsets.right), SPVC_SHARE_CONTAINER_HEIGHT);
    self.shareContainer.backgroundColor = [UIColor whiteColor];
    self.shareLabel.textColor = [UIColor colorWithRed:140.0/255.0 green:142.0/255.0 blue:143.0/255.0 alpha:1.0];
    [self.facebookButton setImage:[UIImage imageNamed:@"btn_share_facebook_touch.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
    [self.twitterButton setImage:[UIImage imageNamed:@"btn_share_twitter_touch.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
    
    self.scrollView.contentSize = self.view.bounds.size;
    
    // Register for keyboard events
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewDidUnload {
    [self setTopBar:nil];
    [self setFeelingTextField:nil];
    [self setBottomBar:nil];
    [self setPhotoView:nil];
    [self setScrollView:nil];
    [self setShareContainer:nil];
    [self setShareLabel:nil];
    [self setTwitterButton:nil];
    [self setFacebookButton:nil];
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
    
    self.feelingTextField.text = self.feelingWord && self.feelingWord.length > 0 ? self.feelingWord : SPVC_FEELING_PLACEHOLDER_TEXT;
    
    self.photoView.photoImageView.image = self.feelingImageSquare;
    self.photoView.photoCaptionTextField.text = [PFUser currentUser] != nil ? ((PFUser *)[PFUser currentUser]).username : SPVC_USER_PLACEHOLDER_TEXT;
    
    self.facebookButton.selected = self.facebookShareEnabled;
    self.twitterButton.selected = self.twitterShareEnabled;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
    if (textField == self.feelingTextField ||
        textField == self.photoView.photoCaptionTextField) {
        shouldReturn = NO;
        [textField resignFirstResponder];
    }
    return shouldReturn;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
    if (textField == self.feelingTextField) {
        if ([textField.text isEqualToString:SPVC_FEELING_PLACEHOLDER_TEXT]) {
            textField.text = @"";
        }
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    } else if (textField == self.photoView.photoCaptionTextField) {
        if ([textField.text isEqualToString:SPVC_USER_PLACEHOLDER_TEXT]) {
            textField.text = @"";
        }
        [self.scrollView scrollRectToVisible:[self.scrollView convertRect:self.photoView.photoCaptionTextField.frame fromView:self.photoView.photoCaptionTextField.superview] animated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");
    if ([textField.text isEqualToString:@""]) {
        if (textField == self.feelingTextField) {
            textField.text = SPVC_FEELING_PLACEHOLDER_TEXT;
        } else if (textField == self.photoView.photoCaptionTextField) {
            textField.text = SPVC_USER_PLACEHOLDER_TEXT;
        }
    }
    self.feelingTextField.text = [self.feelingTextField.text.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.photoView.photoCaptionTextField.text = [self.photoView.photoCaptionTextField.text.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.feelingWord = self.feelingTextField.text;
    
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
    [self.photoView.photoCaptionTextField resignFirstResponder];
    [self pushImagePicker];
}

- (void) doneButtonTouched:(UIButton *)button {
    NSLog(@"doneButtonTouched");
        
    [self.feelingTextField resignFirstResponder];
    [self.photoView.photoCaptionTextField resignFirstResponder];
    
    PFUser * currentUser = [PFUser currentUser];
    
    if ([self.feelingWord isEqualToString:SPVC_FEELING_PLACEHOLDER_TEXT]) {
        [self.noFeelingAlertView show];
    } else if (currentUser == nil) {
        [self.noUserAlertView show];
    } else {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
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
        
        self.submittedPhoto = [self.coreDataManager addOrUpdatePhotoFromServer:photoServer feelingFromServer:feelingServer userFromServer:currentUser];
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
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.delegate submitPhotoViewController:self didSubmitPhoto:self.submittedPhoto withImage:self.submittedImage];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboardWillShow");
    NSDictionary * info = [notification userInfo];
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect rectToMakeVisible = [self.photoView.photoCaptionTextField isFirstResponder] ? [self.scrollView convertRect:self.photoView.photoCaptionTextField.frame fromView:self.photoView.photoCaptionTextField.superview] : CGRectMake(0, 0, 1, 1);
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
        [self.scrollView scrollRectToVisible:rectToMakeVisible animated:NO];
//        self.photoView.photoCaptionTextField.backgroundColor = [UIColor redColor];
    } completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"keyboardWillHide");
    NSDictionary * info = [notification userInfo];
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        self.scrollView.contentInset = UIEdgeInsetsZero;
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//        self.photoView.photoCaptionTextField.backgroundColor = [UIColor clearColor];
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

- (void)accountViewController:(AccountViewController *)accountViewController didFinishWithConnection:(BOOL)finishedWithConnection {
    if (finishedWithConnection) {
        self.facebookShareEnabled = NO;
        self.twitterShareEnabled = NO;
    }
    PFUser * currentUser = [PFUser currentUser];
    if (currentUser) {
        self.photoView.photoCaptionTextField.text = currentUser.username;
    } else {
        self.photoView.photoCaptionTextField.text = SPVC_USER_PLACEHOLDER_TEXT;
    }
    [self dismissModalViewControllerAnimated:YES];
}

@end
