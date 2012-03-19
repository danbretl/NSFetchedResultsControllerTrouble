//
//  PhotosStripViewController.h
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataManager.h"
#import "Feeling.h"
#import "User.h"
#import "PhotoView.h"
#import "ClipView.h"
#import "TopBarView.h"
#import "CameraButtonView.h"
#import "SubmitPhotoViewController.h"
#import "FlagStretchView.h"
#import "SettingsViewController.h"
#import "GalleryConstants.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"
#import "SDNetworkActivityIndicator.h"
#import "WebGetPhotos.h"

typedef enum {
    NoFocus = 0,
    FeelingFocus = 1,
    UserFocus = 2,
} PhotosStripFocus;

typedef enum {
    NoSource = 0,
    Gallery = 1,
    PhotosStripOpposite = 2,
    PhotosStripUnrelated = 4,
    SubmitPhoto = 3,
} PhotosStripAnimationInSource;

@protocol PhotosStripViewControllerDelegate;

@interface PhotosStripViewController : UIViewController <UIScrollViewDelegate, NSFetchedResultsControllerDelegate, PhotoViewDelegate, SettingsViewControllerDelegate, AccountViewControllerDelegate, UIAlertViewDelegate, SDWebImageDownloaderDelegate/*, WebTaskDelegate*/, WebGetPhotosDelegate>

- (void) setFocusToFeeling:(Feeling *)feeling photo:(Photo *)photo;
- (void) setFocusToUser:(User *)user photo:(Photo *)photo;

- (void) setShouldAnimateIn:(BOOL)shouldAnimateIn fromSource:(PhotosStripAnimationInSource)source withPersistentImage:(UIImage *)image;

@property (strong, nonatomic) CoreDataManager * coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultsControllerFeeling;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultsControllerUser;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultsControllerFeelings;
@property (nonatomic) GalleryMode galleryMode; // Sort of weird.
@property (unsafe_unretained, nonatomic) IBOutlet TopBarView * topBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView * bottomBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *contentView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton * headerButton;
@property (unsafe_unretained, nonatomic) IBOutlet ClipView * photosClipView;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView * photosScrollView;
@property (strong, nonatomic) FlagStretchView * flagStretchView;
@property (strong, nonatomic) IBOutlet UIView *photosContainer;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView *photoViewLeftmost;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView *photoViewLeftCenter;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView *photoViewCenter;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView *photoViewRightCenter;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView *photoViewRightmost;
@property (strong, nonatomic) UIImageView * floatingImageView;

@property (unsafe_unretained, nonatomic) IBOutlet CameraButtonView *cameraButtonView;

@property (strong, nonatomic) UIPinchGestureRecognizer * zoomOutGestureRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer * swipeUpGestureRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer * swipeDownGestureRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer * swipeRightHeaderGestureRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer * swipeLeftHeaderGestureRecognizer;

@property (unsafe_unretained, nonatomic) id<PhotosStripViewControllerDelegate, SubmitPhotoViewControllerDelegate> delegate;

@property (strong, nonatomic, readonly) Feeling * feelingFocus;
@property (strong, nonatomic, readonly) User * userFocus;
@property (nonatomic, readonly) PhotosStripFocus focus;

- (void)getPhotosFromServerForFeeling:(Feeling *)feeling;
- (void)getPhotosFromServerForUser:(User *)user;
//- (void)getUpdateFromServerForPhoto:(Photo *)photo;

@property (nonatomic) BOOL swipingInVertically; // This is to fix the bug that is occurring due to the fact that viewWillDisappear is being called on the new PhotosStripViewController that comes in when swiping vertically. It is called because the new PhotosStripViewController view is animated on screen, then the view controller (the old PhotosStripViewController) that essentially contains it is popped (thus also "popping" the new) and then the new is placed back on screen immediately. Bad explanation, but this makes sense. Anyway, I am dealing with the situation by disabling the web image downloader cancels that occur on viewWillDisappear when this property is set to true. This is hackish, for sure, but it is OK for now.

@end

@protocol PhotosStripViewControllerDelegate <NSObject>
- (void) photosStripViewControllerFinished:(PhotosStripViewController *)photosStripViewController withNoMorePhotos:(BOOL)noMorePhotos;
- (void) photosStripViewController:(PhotosStripViewController *)photosStripViewController requestedReplacementWithPhotosStripViewController:(PhotosStripViewController *)replacementPhotosStripViewController;
@end
