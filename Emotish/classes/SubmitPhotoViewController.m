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

static NSString * SPVC_FEELING_PLACEHOLDER_TEXT = @"something";
static NSString * SPVC_USER_PLACEHOLDER_TEXT = @"username";

@interface SubmitPhotoViewController()
- (void) updateViewsWithCurrentData;
- (void) backButtonTouched:(UIButton *)button;
- (void) doneButtonTouched:(UIButton *)button;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
@end

@implementation SubmitPhotoViewController
@synthesize scrollView = _scrollView;

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
        PFUser * currentUser = [PFUser currentUser];
        self.userName = currentUser == nil ? SPVC_USER_PLACEHOLDER_TEXT : currentUser.username;
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
    self.photoView.photoCaptionTextField.userInteractionEnabled = YES;
    self.photoView.button.userInteractionEnabled = NO;
    self.photoView.photoCaptionTextField.delegate = self;
    
//    self.feelingTextField.frame = CGRectMake(self.photoView.frame.origin.x + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, CGRectGetMaxY(self.topBar.frame), PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, CGRectGetMinY(self.photoView.frame) - CGRectGetMaxY(self.topBar.frame));
//    self.feelingTextField.textFieldInsets = UIEdgeInsetsMake(0, 0, PC_PHOTO_CELL_MARGIN_TOP, 0);

    // The following is still not matching up perfectly with PhotosStripViewController headerButton when font size is being adjusted for a long string.
    self.feelingTextField.frame = CGRectMake(0, 0, 320, CGRectGetMinY(self.photoView.frame));
    self.feelingTextField.textFieldInsets = UIEdgeInsetsMake(0, self.photoView.frame.origin.x + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, PC_PHOTO_CELL_MARGIN_TOP, 320 - (CGRectGetMaxX(self.photoView.frame) - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL));
    
    self.scrollView.contentSize = self.view.bounds.size;
    
    self.feelingTextField.text = self.feelingWord;
    self.photoView.photoCaptionTextField.text = self.userName;
    
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
        self.userName = self.photoView.photoCaptionTextField.text;
        
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
    self.userName = self.photoView.photoCaptionTextField.text;
    [self updateViewsWithCurrentData];
    
    [self dismissModalViewControllerAnimated:NO];
    self.imagePickerControllerCamera = nil;
    self.cameraOverlayViewHandler = nil;
    
}

- (void)updateViewsWithCurrentData {
    self.feelingTextField.text = self.feelingWord && self.feelingWord.length > 0 ? self.feelingWord : SPVC_FEELING_PLACEHOLDER_TEXT;
    self.photoView.photoImageView.image = self.feelingImageSquare;
    self.photoView.photoCaptionTextField.text = self.userName && self.userName.length > 0 ? self.userName : SPVC_USER_PLACEHOLDER_TEXT;
    self.photoView.photoCaptionTextField.textColor = [UIColor userColor];
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
    self.userName = self.photoView.photoCaptionTextField.text;
    
}

- (void) backButtonTouched:(UIButton *)button {
    NSLog(@"backButtonTouched");
    [self.feelingTextField resignFirstResponder];
    [self.photoView.photoCaptionTextField resignFirstResponder];
    [self pushImagePicker];
}

- (void) doneButtonTouched:(UIButton *)button {
    NSLog(@"doneButtonTouched");
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self.feelingTextField resignFirstResponder];
    [self.photoView.photoCaptionTextField resignFirstResponder];
    
    if ([self.feelingWord isEqualToString:SPVC_FEELING_PLACEHOLDER_TEXT] ||
        [self.userName isEqualToString:SPVC_USER_PLACEHOLDER_TEXT]) {
        
        UIAlertView * missingSomethingAlertView = [[UIAlertView alloc] initWithTitle:@"Missing Info" message:@"Please enter a Feeling and a Username" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [missingSomethingAlertView show];
        
    } else {
        
        NSLog(@"setting up filename");
        NSString * nowString = [NSString stringWithFormat:@"%d", abs([[NSDate date] timeIntervalSince1970])];
        NSString * filename = [NSString stringWithFormat:@"%@-%@-%@.jpg", [self.feelingWord.lowercaseString  stringByReplacingOccurrencesOfString:@" " withString:@""], self.userName, nowString];
        NSLog(@"  filename set to %@", filename);
        
        NSLog(@"setting up imageFile");
        NSData * imageData = UIImageJPEGRepresentation([self.feelingImageSquare imageScaledDownToEmotishFull], 1.0);
        PFFile * imageFile = [PFFile fileWithName:filename data:imageData];    
        NSLog(@"  imageFile = %@", imageFile);
        
        NSLog(@"saving imageFile");
        BOOL savingSuccess = [imageFile save];
        NSLog(@"  saving imageFile success? %d", savingSuccess);
        
        NSLog(@"setting up feeling");
        BOOL objectMadeIndicator;
        Feeling * feelingLocal = (Feeling *)[self.coreDataManager getFirstObjectForEntityName:@"Feeling" matchingPredicate:[NSPredicate predicateWithFormat:@"word == %@", self.feelingWord.lowercaseString] usingSortDescriptors:nil shouldMakeObjectIfNoMatch:NO newObjectMadeIndicator:&objectMadeIndicator];
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
        
        NSLog(@"setting up user");
        PFUser * userServer = nil;
        PFUser * currentUser = [PFUser currentUser];
        if (currentUser == nil || ![currentUser.username isEqualToString:self.userName]) {
            NSLog(@"  currentUser is nil, or currentUser.username is same as given userName");
            if (currentUser != nil) { 
                NSLog(@"  currentUser is not nil, but currentUser.username is not the same as given userName");
                [PFUser logOut];
            }
            BOOL * objectMadeIndicator;
            User * userLocal = (User *)[self.coreDataManager getFirstObjectForEntityName:@"User" matchingPredicate:[NSPredicate predicateWithFormat:@"name == %@", self.userName] usingSortDescriptors:nil shouldMakeObjectIfNoMatch:NO newObjectMadeIndicator:objectMadeIndicator];
            if (userLocal != nil) {
                NSLog(@"  userLocal is not nil, userLocal.serverID = %@", userLocal.serverID);
                userServer = [PFQuery getUserObjectWithId:userLocal.serverID];
                userServer = [PFUser logInWithUsername:userServer.username password:userServer.username];
            } else {
                NSLog(@"  userLocal is nil");
                PFQuery * userQuery = [PFQuery queryForUser];
                [userQuery whereKey:@"username" equalTo:self.userName];
                NSArray * matchingUsers = [userQuery findObjects];
                if (matchingUsers != nil && matchingUsers.count > 0) {
                    userServer = [matchingUsers objectAtIndex:0];
                    userServer = [PFUser logInWithUsername:userServer.username password:userServer.username];
                } else {
                    userServer = [PFUser user];
                    userServer.username = self.userName;
                    userServer.email = [NSString stringWithFormat:@"fake%@@fakegmail.com", self.userName];
                    userServer.password = self.userName;
                    [userServer signUp];
                }
            }
        } else {
            NSLog(@"  currentUser is not nil, and currentUser.username is same as given userName");
            userServer = currentUser;
        }
        NSLog(@"  userServer = %@", userServer);
        
        NSLog(@"setting up photo");
        PFObject * photoServer = [PFObject objectWithClassName:@"Photo"];
        [photoServer setObject:feelingServer forKey:@"feeling"];
        [photoServer setObject:userServer forKey:@"user"];
        [photoServer setObject:imageFile forKey:@"image"];
        NSLog(@"  photoServer = %@", photoServer);
        
        NSLog(@"saving photoServer");
        savingSuccess = [photoServer save];
        NSLog(@"  saving photoServer success? %d", savingSuccess);
        
        Photo * photo = [self.coreDataManager addOrUpdatePhotoFromServer:photoServer feelingFromServer:feelingServer userFromServer:userServer];
        [self.coreDataManager saveCoreData];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        [self.delegate submitPhotoViewController:self didSubmitPhoto:photo withImage:self.feelingImageSquare];
        
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

@end
