//
//  GalleryViewController.m
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryViewController.h"
#import "ViewConstants.h"
#import "GalleryConstants.h"
#import "GalleryFeelingCell.h"
#import "GalleryFeelingImageCell.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "CameraOverlayView.h"
#import "UIImage+Crop.h"

@interface GalleryViewController()
@property (strong, nonatomic) IBOutlet UITableView * feelingsTableView;
- (void) emotishLogoTouched:(UIButton *)button;
- (IBAction)addPhotoButtonTouched:(id)sender;
@end

@implementation GalleryViewController

@synthesize coreDataManager=_coreDataManager;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize feelingsTableView=_feelingsTableView;
@synthesize feelingsTableViewContentOffsetPreserved=_feelingsTableViewContentOffsetPreserved;
@synthesize activeFeelingCell=_activeFeelingCell;
@synthesize activeFeelingCellIndexRow=_activeFeelingCellIndexRow;
@synthesize activeFeelingCellContentOffsetPreserved=_activeFeelingCellContentOffsetPreserved;
@synthesize flagStretchView = _flagStretchView;
@synthesize floatingImageView=_floatingImageView;
@synthesize topBar=_topBar;
@synthesize bottomBar = _bottomBar;
@synthesize addPhotoButton = _addPhotoButton;
// THE FOLLOWING SYNTHESIZED PROPERTIES ARE DUPLICATED IN GalleryViewController.m AND PhotosStripViewController.m
@synthesize imagePickerControllerCamera=_imagePickerControllerCamera, imagePickerControllerLibrary=_imagePickerControllerLibrary, cameraOverlayViewHandler=_cameraOverlayViewHandler, addPhotoImage=_addPhotoImage;
// THE PREVIOUS SYNTHESIZED PROPERTIES ARE DUPLICATED IN GalleryViewController.m AND PhotosStripViewController.m

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        debugging = NO;
        self.feelingsTableViewContentOffsetPreserved = CGPointMake(0, -(VC_TOP_BAR_HEIGHT + GC_FEELING_IMAGE_MARGIN_VERTICAL));
        self.activeFeelingCellIndexRow = -1;
        self.activeFeelingCellContentOffsetPreserved = CGPointZero;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"GalleryViewController self.view.frame = %@", NSStringFromCGRect(self.view.frame));
    
    CGSize addPhotoButtonSize = CGSizeMake(VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_LEFT_EDGE + VC_ADD_PHOTO_BUTTON_WIDTH + VC_ADD_PHOTO_BUTTON_PADDING_RIGHT, VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_BOTTOM_EDGE + VC_ADD_PHOTO_BUTTON_HEIGHT + VC_ADD_PHOTO_BUTTON_PADDING_TOP);
    self.addPhotoButton.frame = CGRectMake(0, self.view.frame.size.height - VC_BOTTOM_BAR_HEIGHT - addPhotoButtonSize.height, addPhotoButtonSize.width, addPhotoButtonSize.height);
    self.addPhotoButton.contentEdgeInsets = UIEdgeInsetsMake(0, VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_LEFT_EDGE, VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_BOTTOM_EDGE, 0);
    NSLog(@"%@", NSStringFromCGRect(self.addPhotoButton.frame));
//    self.addPhotoButton.frame = CGRectMake(VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_LEFT_EDGE, self.view.frame.size.height - VC_BOTTOM_BAR_HEIGHT - self.addPhotoButton.frame.size.height - VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_BOTTOM_EDGE, self.addPhotoButton.frame.size.width, self.addPhotoButton.frame.size.height);
    
    [self.topBar.buttonBranding addTarget:self action:@selector(emotishLogoTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar showButtonType:ProfileButton inPosition:LeftSpecial animated:NO];
        
    self.feelingsTableView.rowHeight = GC_FEELING_IMAGE_SIDE_LENGTH + 2 * GC_FEELING_IMAGE_MARGIN_VERTICAL;
    self.feelingsTableView.contentInset = UIEdgeInsetsMake(VC_TOP_BAR_HEIGHT, 0, GC_FEELING_IMAGE_MARGIN_VERTICAL + VC_BOTTOM_BAR_HEIGHT, 0);
    self.feelingsTableView.scrollsToTop = YES;

    CGFloat tableHeaderViewFlagVisibleHeight = 3.0;
    UIView * tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.feelingsTableView.frame.size.width, tableHeaderViewFlagVisibleHeight + GC_FEELING_IMAGE_MARGIN_VERTICAL)];
    
    self.feelingsTableView.tableHeaderView = tableHeaderView;
    
    self.flagStretchView = [[FlagStretchView alloc] initWithFrame:CGRectMake(0, tableHeaderViewFlagVisibleHeight - [UIScreen mainScreen].bounds.size.height, self.feelingsTableView.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.flagStretchView.icon.opacity = 0.75;
    self.flagStretchView.iconDistanceFromBottom = floorf(self.feelingsTableView.rowHeight / 3.0);
    self.flagStretchView.activationDistanceEnd = 2 * self.flagStretchView.iconDistanceFromBottom + self.flagStretchView.icon.frame.size.height;
    self.flagStretchView.angledShapes = NO;
    self.flagStretchView.activationAffectsIcon = YES;
    self.flagStretchView.activationAffectsAlpha = NO;
    [tableHeaderView addSubview:self.flagStretchView];
    
    self.floatingImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.floatingImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.floatingImageView belowSubview:self.topBar];
    self.floatingImageView.alpha = 0.0;
    self.floatingImageView.userInteractionEnabled = NO;
    self.floatingImageView.backgroundColor = [UIColor clearColor];
    
    if (debugging) {
        self.feelingsTableView.backgroundColor = [UIColor greenColor];
    }
    
    NSError * error;
	if (![self.fetchedResultsController performFetch:&error]) {
		// Handle the error appropriately...
		NSLog(@"GalleryViewController - Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
}

- (void)viewDidUnload {
    [self setAddPhotoButton:nil];
    [self setFlagStretchView:nil];
    [self setBottomBar:nil];
    [super viewDidUnload];
    self.feelingsTableView = nil;
    self.activeFeelingCell = nil; // Not retained, but should nil this pointer.
    self.floatingImageView = nil;
    self.topBar = nil;
    self.fetchedResultsController = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.feelingsTableViewContentOffsetPreserved = self.feelingsTableView.contentOffset;
    self.activeFeelingCellContentOffsetPreserved = self.activeFeelingCell != nil ? self.activeFeelingCell.imagesTableView.contentOffset : CGPointZero;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    self.feelingsTableView.contentOffset = self.feelingsTableViewContentOffsetPreserved;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    if (tableView == self.feelingsTableView) {
        rowCount = [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.feelingsTableView) {
        
//        NSLog(@"feelingCell forIndexPath.row:%d", indexPath.row);
        
        // Get / Create the cell
        static NSString * FeelingCellID = @"FeelingCellID";
        GalleryFeelingCell * cell = (GalleryFeelingCell *)[tableView dequeueReusableCellWithIdentifier:FeelingCellID];
        if (cell == nil) {
//            NSLog(@"Brand new cell");
            cell = [[GalleryFeelingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeelingCellID];
            cell.imagesTableView.delegate = self;
//            cell.imagesTableView.dataSource = self;
            cell.delegate = self;
        } else {
            if (cell.feelingIndex == self.activeFeelingCellIndexRow) {
                self.activeFeelingCellContentOffsetPreserved = cell.imagesTableView.contentOffset;
                self.activeFeelingCell = nil;
            }
        }
        
        // Configure the cell
        Feeling * feeling = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.feelingLabel.text = feeling.word.lowercaseString;
        cell.feelingIndex = indexPath.row;
        cell.photos = feeling.mostRecentPhotos;
        [cell.imagesTableView reloadData];

        // Update active cell view object
        if (indexPath.row == self.activeFeelingCellIndexRow) {
            self.activeFeelingCell = cell;
            [cell highlightLabel:YES];
            [cell.imagesTableView setContentOffset:self.activeFeelingCellContentOffsetPreserved animated:NO];
        } else {
            [cell scrollToOriginAnimated:NO]; // Can not figure out how to fix the problem where if a row is scrolling horizontally while it goes off screen, then when that row is reused, the starting content offset is all messed up.            
        }
        
        // Return the cell
        return cell;
        
    }
    
    return nil;
    
}

- (void) feelingCellSelected:(GalleryFeelingCell *)feelingCell fromImageCell:(GalleryFeelingImageCell *)imageCell {
    
    if (!(self.activeFeelingCell != nil &&
          self.activeFeelingCell.imagesTableView.isTracking)) {
        NSLog(@"Feeling button touched, should push view controller for feeling '%@', focused on %@.", feelingCell.feelingLabel.text, imageCell != nil ? [NSString stringWithFormat:@"the image that was located at index %d)",  imageCell.imageIndex] : @"the first image");
            
        // Old behavior, arguably 'slicker' - if a feeling cell is pulled out (and is thus the active feeling cell), but the user then taps the label or image from a different (not pulled out) feeling cell, while that new tapped feeling cell is being pushed to a view controller etc, the old active cell is deactivated (and starts to scroll towards the origin), and the new tapped cell is offically the new active one.
//        GalleryFeelingCell * oldActiveFeelingCell = self.activeFeelingCell;
//        GalleryFeelingCell * newActiveFeelingCell = feelingCell;
//        if (oldActiveFeelingCell != newActiveFeelingCell) {
//            self.activeFeelingCell = nil;
//            if (oldActiveFeelingCell.imagesTableView.contentOffset.y > 0) {
//                [oldActiveFeelingCell scrollToOriginAnimated:YES];
//            } else {
//                [oldActiveFeelingCell highlightLabel:NO];
//            }
//            self.activeFeelingCell = newActiveFeelingCell;
//            self.activeFeelingCellIndexRow = newActiveFeelingCell.feelingIndex;
//            [self.activeFeelingCell highlightLabel:YES];
//        }
        // New behavior, works with my galleryScreenshot technique - in the situation described above, the new tapped feeling cell does not become the new official active cell. In all other situations, it does. (The problem was that the screenshot would be taken before the potentially old active feeling cell was finished scrolling back to its origin, and thus the transition back to the Gallery, whenever that might happen, would not look right.)
        GalleryFeelingCell * oldActiveFeelingCell = self.activeFeelingCell;
        GalleryFeelingCell * newActiveFeelingCell = feelingCell;
        if (oldActiveFeelingCell != newActiveFeelingCell) {
            if (oldActiveFeelingCell.imagesTableView.isDecelerating) {
                NSLog(@"oldActiveFeelingCell.imagesTableView.isDecelerating");
                [oldActiveFeelingCell.imagesTableView scrollRectToVisible:CGRectMake(0, oldActiveFeelingCell.imagesTableView.contentOffset.y-1, 1, 1) animated:NO];
            }
            if (oldActiveFeelingCell.imagesTableView.contentOffset.y <= 0) {
                self.activeFeelingCell = nil;
                [oldActiveFeelingCell highlightLabel:NO];
                self.activeFeelingCell = newActiveFeelingCell;
                self.activeFeelingCellIndexRow = newActiveFeelingCell.feelingIndex;
                [self.activeFeelingCell highlightLabel:YES];
            }
        }
    
        if (imageCell == nil) {   
            imageCell = [feelingCell.imagesTableView.visibleCells objectAtIndex:0];
        }
        
        PhotosStripViewController * feelingStripViewController = [[PhotosStripViewController alloc] initWithNibName:@"PhotosStripViewController" bundle:[NSBundle mainBundle]];
        feelingStripViewController.delegate = self;
        feelingStripViewController.coreDataManager = self.coreDataManager;
        feelingStripViewController.fetchedResultsControllerFeelings = self.fetchedResultsController;
        Feeling * feeling = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:feelingCell.feelingIndex inSection:0]];
        [feelingStripViewController setFocusToFeeling:feeling photo:[feelingCell.photos objectAtIndex:(imageCell != nil ? imageCell.imageIndex : 0)]];
        [feelingStripViewController setShouldAnimateIn:YES fromSource:Gallery withPersistentImage:imageCell.button.imageView.image];
        
        // Render the view layer of this view controller, for fading back to it from other views
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
        } else {
            UIGraphicsBeginImageContext(self.view.bounds.size);
        }
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        feelingStripViewController.galleryScreenshot = image;
                
        self.floatingImageView.frame = [imageCell.button convertRect:imageCell.button.imageView.frame toView:self.floatingImageView.superview];
        self.floatingImageView.image = imageCell.button.imageView.image;
        self.floatingImageView.alpha = 1.0;
        imageCell.alpha = 0.0;
        
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.floatingImageView.frame = /*[self.floatingImageView.superview convertRect:*/CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X, PC_PHOTO_CELL_IMAGE_ORIGIN_Y, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH)/* fromView:nil]*/;
            NSLog(@"self.floatingImageView.frame = %@", NSStringFromCGRect(self.floatingImageView.frame));
            NSLog(@"galleryViewController.view.frame = %@", NSStringFromCGRect(self.view.frame));
            self.feelingsTableView.alpha = 0.0;
            self.floatingImageView.userInteractionEnabled = YES;
            self.feelingsTableView.userInteractionEnabled = NO;
        } completion:^(BOOL finished){
            [self.navigationController pushViewController:feelingStripViewController animated:NO];
            imageCell.alpha = 1.0;
        }];
    
    }
    
}

- (void)photosStripViewControllerFinished:(PhotosStripViewController *)photosStripViewController {
    self.floatingImageView.alpha = 0.0;
    self.feelingsTableView.alpha = 1.0;
    self.floatingImageView.userInteractionEnabled = NO;
    self.feelingsTableView.userInteractionEnabled = YES;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)photosStripViewController:(PhotosStripViewController *)photosStripViewController requestedReplacementWithPhotosStripViewController:(PhotosStripViewController *)replacementPhotosStripViewController {
    NSLog(@"photosStripViewController:requestedReplacementWithPhotosStripViewController:");
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:replacementPhotosStripViewController animated:NO];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.feelingsTableView &&
        self.activeFeelingCell.imagesTableView != scrollView &&
        scrollView.contentOffset.y > 0) {
        GalleryFeelingCell * cell = (GalleryFeelingCell *)scrollView.superview.superview; // Totally unsafe, based on insider knowledge that might become untrue at some point.
        [cell scrollToOriginAnimated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView != self.feelingsTableView) {
        if (self.activeFeelingCell.imagesTableView != scrollView) {
            if (!decelerate && scrollView.contentOffset.y > 0) {
                GalleryFeelingCell * cell = (GalleryFeelingCell *)scrollView.superview.superview; // Totally unsafe, based on insider knowledge that might become untrue at some point.
                [cell scrollToOriginAnimated:YES];
            }
        }
    } else {
        if (-scrollView.contentOffset.y >= scrollView.contentInset.top + self.flagStretchView.activationDistanceEnd) {
//            scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top + self.flagStretchView.arrowFlipDistance, scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
//            scrollView.userInteractionEnabled = NO;
//            [self.flagStretchView startAnimatingStripes];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.feelingsTableView) {
        GalleryFeelingCell * feelingCell = (GalleryFeelingCell *)scrollView.superview.superview; // Totally unsafe, based on insider knowledge that might become untrue at some point.
        feelingCell.flagStretchView.pulledOutDistance = MAX(0, -scrollView.contentOffset.y);
        [feelingCell.flagStretchView setActivated:scrollView.isTracking && feelingCell.flagStretchView.pulledOutDistance >= feelingCell.flagStretchView.activationDistanceEnd animated:YES];
        if (scrollView == self.activeFeelingCell.imagesTableView) {
            // ...
            // ...
            // ...
        } else {
            if (scrollView.isTracking) {
                if (!(self.activeFeelingCell != nil &&
                      self.activeFeelingCell.imagesTableView.isTracking)) {
                    GalleryFeelingCell * oldActiveFeelingCell = self.activeFeelingCell;
                    GalleryFeelingCell * newActiveFeelingCell = (GalleryFeelingCell *)scrollView.superview.superview; // Totally unsafe, based on insider knowledge that might become untrue at some point.
                    self.activeFeelingCell = nil;
                    if (oldActiveFeelingCell.imagesTableView.contentOffset.y > 0) {
                        [oldActiveFeelingCell scrollToOriginAnimated:YES];
                    } else {
                        [oldActiveFeelingCell highlightLabel:NO];
                    }
                    self.activeFeelingCell = newActiveFeelingCell;
                    self.activeFeelingCellIndexRow = newActiveFeelingCell.feelingIndex;
                    [self.activeFeelingCell highlightLabel:YES];
                }
            }
        }
    } else {
        [self.flagStretchView setActivated:scrollView.isTracking && -scrollView.contentOffset.y >= scrollView.contentInset.top + self.flagStretchView.activationDistanceEnd animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView != self.feelingsTableView) {
        if (/*self.activeFeelingCell.imagesTableView != scrollView &&*/
            scrollView.contentOffset.y != 0) {
            GalleryFeelingCell * cell = (GalleryFeelingCell *)scrollView.superview.superview; // Totally unsafe, based on insider knowledge that might become untrue at some point.
            if (self.activeFeelingCell == cell) { 
                self.activeFeelingCell = nil;
                self.activeFeelingCellIndexRow = -1;
            }
            [cell scrollToOriginAnimated:YES];
        }
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Feeling" inManagedObjectContext:self.coreDataManager.managedObjectContext];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"word" ascending:YES]];
    fetchRequest.fetchBatchSize = 20;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreDataManager.managedObjectContext sectionNameKeyPath:nil cacheName:@"Gallery"];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)emotishLogoTouched:(UIButton *)button {
    [self.feelingsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}



// THE FOLLOWING CODE IS DUPLICATED IN GalleryViewController.m AND PhotosStripViewController.m
// THE FOLLOWING CODE IS DUPLICATED IN GalleryViewController.m AND PhotosStripViewController.m
// THE FOLLOWING CODE IS DUPLICATED IN GalleryViewController.m AND PhotosStripViewController.m

- (IBAction)addPhotoButtonTouched:(id)sender {
    NSLog(@"addPhotoButtonTouched");
    
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
    } else {
        self.imagePickerControllerLibrary = nil;
        if (self.imagePickerControllerCamera != nil) {
            [self presentModalViewController:self.imagePickerControllerCamera animated:NO];
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
    
}

// THE PREVIOUS CODE IS DUPLICATED IN GalleryViewController.m AND PhotosStripViewController.m
// THE PREVIOUS CODE IS DUPLICATED IN GalleryViewController.m AND PhotosStripViewController.m
// THE PREVIOUS CODE IS DUPLICATED IN GalleryViewController.m AND PhotosStripViewController.m


@end
