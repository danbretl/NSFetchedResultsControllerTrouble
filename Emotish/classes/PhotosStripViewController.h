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

typedef enum {
    NoFocus = 0,
    FeelingFocus = 1,
    UserFocus = 2,
} PhotosStripFocus;

typedef enum {
    NoSource = 0,
    Gallery = 1,
    PhotosStripOpposite = 2,
} PhotosStripAnimationInSource;

@protocol PhotosStripViewControllerDelegate;

@interface PhotosStripViewController : UIViewController <UIScrollViewDelegate, NSFetchedResultsControllerDelegate/*, PhotoViewDelegate*/>

- (void) setFocusToFeeling:(Feeling *)feeling photo:(Photo *)photo;
- (void) setFocusToUser:(User *)user photo:(Photo *)photo;

- (void) setShouldAnimateIn:(BOOL)shouldAnimateIn fromSource:(PhotosStripAnimationInSource)source withPersistentImage:(UIImage *)image;

@property (strong, nonatomic) UIImage * galleryScreenshot;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *galleryImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *backgroundView;

@property (strong, nonatomic) CoreDataManager * coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultsControllerFeeling;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultsControllerUser;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView * topBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton * headerButton;
@property (unsafe_unretained, nonatomic) IBOutlet ClipView * photosClipView;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView * photosScrollView;
@property (strong, nonatomic) IBOutlet UIView *photosContainer;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView *photoViewLeftmost;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView *photoViewLeftCenter;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView *photoViewCenter;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView *photoViewRightCenter;
@property (unsafe_unretained, nonatomic) IBOutlet PhotoView *photoViewRightmost;
@property (strong, nonatomic) UIImageView * floatingImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * addPhotoLabel;

@property (strong, nonatomic) UIPinchGestureRecognizer * zoomOutGestureRecognizer;

@property (unsafe_unretained, nonatomic) id<PhotosStripViewControllerDelegate> delegate;

@end

@protocol PhotosStripViewControllerDelegate <NSObject>
- (void) photosStripViewControllerFinished:(PhotosStripViewController *)photosStripViewController;
- (void) photosStripViewController:(PhotosStripViewController *)photosStripViewController requestedReplacementWithPhotosStripViewController:(PhotosStripViewController *)replacementPhotosStripViewController;
@end
