//
//  PhotosStripViewController.m
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosStripViewController.h"
#import "PhotoCell.h"
#import "ViewConstants.h"
#import "UIColor+Emotish.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import <Parse/Parse.h>
#import "Like.h"
#import "PushConstants.h"
#import "SDImageCache.h"
#import "EmotishAlertViews.h"
#import "UIScrollView+StopScroll.h"

#ifdef DEBUG
#define unlimited_likes_allowed YES
#else
#define unlimited_likes_allowed NO
#endif

const CGFloat PSVC_LABELS_ANIMATION_EXTRA_DISTANCE_OFFSCREEN = 10.0;
const int PSVC_PHOTO_VIEWS_COUNT = 5;
const CGFloat PSVC_ADD_PHOTO_BUTTON_MARGIN_RIGHT = 8.0;
const CGFloat PSVC_FLAG_STRETCH_VIEW_ACTIVATION_DISTANCE_START = 35.0;
const CGFloat PSVC_FLAG_STRETCH_VIEW_ACTIVATION_DISTANCE_END = 65.0;
const CGFloat PSVC_FLAG_STRETCH_VIEW_HEIGHT_PERCENTAGE_OF_PHOTO_VIEW_IMAGE_HEIGHT = 0.66;

@interface PhotosStripViewController()
@property (nonatomic) PhotosStripFocus focus;
@property (strong, nonatomic) Feeling * feelingFocus;
@property (strong, nonatomic) User * userFocus;
@property (strong, nonatomic) Photo * photoCenter;
@property (nonatomic) NSUInteger photoCenterIndex;
- (void) setPhotoCenterIndex:(NSUInteger)photoCenterIndex forcePhotoViewsUpdate:(BOOL)forcePhotoViewsUpdate;
@property (nonatomic, readonly) NSUInteger photoViewCenterIndex; // The index of self.photoViewCenter in self.photoViews. self.photoViewCenter is guaranteed, by definition, to be in the middle of self.photoViews, with an even number of PhotoView objects to either side.
@property (strong, nonatomic, readonly) NSFetchedResultsController * fetchedResultsControllerForCurrentFocus;
- (NSFetchedResultsController *)fetchedResultsControllerForFocus:(PhotosStripFocus)focus;
- (void) performFetchForCurrentFocus;
- (void) updateViewsForCurrentFocus;
- (void) updatePhotoViewCaption:(PhotoView *)photoView withDataFromPhoto:(Photo *)photo oppositeOfFocus:(PhotosStripFocus)mainViewDataFocus;
- (void) pinchedToZoomOut:(UIPinchGestureRecognizer *)pinchGestureRecognizer;
- (void) swipedVertically:(UISwipeGestureRecognizer *)swipeGestureRecognizer;
- (void) swipedRightOnHeader:(UISwipeGestureRecognizer *)swipeGestureRecognizer;
- (void) photoViewSelected:(PhotoView *)photoView withPhoto:(Photo *)photo;
- (void) viewControllerFinishedWithNoMorePhotos:(BOOL)noMorePhotos;
- (IBAction)headerButtonTouched:(UIButton *)button;
@property (nonatomic) BOOL shouldAnimateIn;
@property (nonatomic) PhotosStripAnimationInSource animationInSource;
@property (strong, nonatomic) UIImage * animationInPersistentImage;
@property (nonatomic) BOOL finishing;
- (NSString *)photoViewNameForPhotoView:(PhotoView *)photoView;
- (void)emotishLogoTouched:(UIButton *)button;
- (IBAction)addPhotoButtonTouched:(id)sender;
- (void)getPhotosFromServerCallback:(NSArray *)results error:(NSError *)error;
@property (strong, nonatomic) PFQuery * getPhotosQuery;
@property (strong, nonatomic) NSMutableArray * photoUpdateQueries;
- (void) profileButtonTouched:(UIButton *)button;
- (void) settingsButtonTouched:(UIButton *)button;
- (void) userCurrent:(PFUser *)userCurrent likedPhotoAttempt:(Photo *)photoLiked;
- (void) userCurrent:(PFUser *)userCurrent likedPhoto:(Photo *)photoLiked;
- (void) userCurrent:(PFUser *)userCurrent deletedPhotoAttempt:(Photo *)photoDeleted;
- (void) userDeletedPhoto:(Photo *)photoDeleted;
@property (strong, nonatomic, readonly) UIAlertView * signInAlertView;
@property (strong, nonatomic, readonly) UIAlertView * confirmDeleteAlertView;
- (void) showAccountViewController;
- (void)showSettingsViewControllerForUserLocal:(User *)userLocal userServer:(PFUser *)userServer;
- (BOOL) deleteAllowedForCurrentUser:(PFUser *)currentUser withPhoto:(Photo *)photo;
@property (strong, nonatomic) Photo * photoToDelete;
- (int) indexForContentOffsetX:(CGFloat)contentOffsetX;
- (int) indexForScrollViewCenterWithContentOffsetX:(CGFloat)contentOffsetX;
- (void) updatePhotoViewsPositionsForPhotoCenterIndex:(int)photoCenterIndex;
- (void) updatePhotoViewsPhotosForPhotoCenterIndex:(int)photoCenterIndex;
- (void) updatePhotoViewsForPhotoCenterIndex:(int)photoCenterIndex;
- (void) updatePhotoView:(PhotoView *)photoView atPhotoViewIndex:(int)photoViewIndex withPhotoAtIndex:(int)photoIndex;
@property (strong, nonatomic) NSArray * photoViews;
@property (strong, nonatomic) NSMutableArray * photoViewsPhotoServerIDs;
@property (strong, nonatomic) NSMutableDictionary * photoWebImageManagersForPhotoServerIDs;
@property (nonatomic) BOOL refreshAllRequested;
@property (nonatomic) BOOL refreshAllInProgress;
@property (nonatomic) int refreshAllNetChangeBeforePreviousPhotoCenterIndex;
@property (nonatomic) BOOL controllerChangingContent;
@property BOOL blockViewControllerFinishing;
@end

@implementation PhotosStripViewController
@synthesize focus=_focus;
@synthesize feelingFocus=_feelingFocus, userFocus=_userFocus;
@synthesize photoCenter=_photoCenter;
@synthesize shouldAnimateIn=_shouldAnimateIn, animationInSource=_animationInSource, animationInPersistentImage=_animationInPersistentImage;
//@synthesize galleryScreenshot=_galleryScreenshot;
//@synthesize galleryImageView = _galleryImageView;
//@synthesize backgroundView = _backgroundView;
@synthesize coreDataManager=_coreDataManager;
@synthesize fetchedResultsControllerFeeling=_fetchedResultsControllerFeeling;
@synthesize fetchedResultsControllerUser=_fetchedResultsControllerUser;
@synthesize fetchedResultsControllerFeelings=_fetchedResultsControllerFeelings;
@synthesize bottomBar = _bottomBar;
@synthesize fetchedResultsControllerForCurrentFocus=_fetchedResultsControllerForCurrentFocus;
@synthesize topBar=_topBar;
@synthesize contentView = _contentView;
@synthesize headerButton=_headerButton;
@synthesize photosClipView=_photosClipView, photosScrollView=_photosScrollView, flagStretchView=_flagStretchView, photosContainer=_photosContainer, photoViews=_photoViews, photoViewLeftmost=_photoViewLeftmost, photoViewLeftCenter=_photoViewLeftCenter, photoViewCenter=_photoViewCenter, photoViewRightCenter=_photoViewRightCenter, photoViewRightmost=_photoViewRightmost;
@synthesize floatingImageView=_floatingImageView;
@synthesize addPhotoButton = _addPhotoButton, addPhotoLabel = _addPhotoLabel;
@synthesize zoomOutGestureRecognizer=_zoomOutGestureRecognizer, swipeUpGestureRecognizer=_swipeUpGestureRecognizer, swipeDownGestureRecognizer=_swipeDownGestureRecognizer, swipeRightHeaderGestureRecognizer=_swipeRightHeaderGestureRecognizer;
@synthesize finishing=_finishing;
@synthesize getPhotosQuery=_getPhotosQuery;
@synthesize signInAlertView=_signInAlertView, confirmDeleteAlertView=_confirmDeleteAlertView;
@synthesize photoToDelete=_photoToDelete;
@synthesize photoUpdateQueries=_photoUpdateQueries;
@synthesize photoCenterIndex=_photoCenterIndex;
@synthesize photoViewsPhotoServerIDs=_photoViewsPhotoServerIDs, photoWebImageManagersForPhotoServerIDs=_photoWebImageManagersForPhotoServerIDs;
@synthesize refreshAllRequested=_refreshAllRequested, refreshAllInProgress=_refreshAllInProgress, refreshAllNetChangeBeforePreviousPhotoCenterIndex=_refreshAllNetChangeBeforePreviousPhotoCenterIndex, controllerChangingContent=_controllerChangingContent;
@synthesize blockViewControllerFinishing=_blockViewControllerFinishing;
@synthesize delegate=_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _photoCenterIndex = NSNotFound;
        self.focus = NoFocus;
        self.photoUpdateQueries = [NSMutableArray array];
        self.photoViewsPhotoServerIDs = [NSMutableArray array];
        self.photoWebImageManagersForPhotoServerIDs = [NSMutableDictionary dictionary];
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
    NSLog(@"%@ PhotosStripViewController viewDidLoad", self.focus == FeelingFocus ? @"Feeling" : @"User");
    
    CGSize addPhotoButtonSize = CGSizeMake(VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_LEFT_EDGE + VC_ADD_PHOTO_BUTTON_WIDTH + VC_ADD_PHOTO_BUTTON_PADDING_RIGHT, VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_BOTTOM_EDGE + VC_ADD_PHOTO_BUTTON_HEIGHT + VC_ADD_PHOTO_BUTTON_PADDING_TOP);
    self.addPhotoButton.frame = CGRectMake(0, self.view.frame.size.height - VC_BOTTOM_BAR_HEIGHT - addPhotoButtonSize.height, addPhotoButtonSize.width, addPhotoButtonSize.height);
    self.addPhotoButton.contentEdgeInsets = UIEdgeInsetsMake(0, VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_LEFT_EDGE, VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_BOTTOM_EDGE, 0);
    //    self.addPhotoButton.frame = CGRectMake(VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_LEFT_EDGE, self.view.frame.size.height - VC_BOTTOM_BAR_HEIGHT - self.addPhotoButton.frame.size.height - VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_BOTTOM_EDGE, self.addPhotoButton.frame.size.width, self.addPhotoButton.frame.size.height);
    self.addPhotoLabel.frame = CGRectMake(CGRectGetMaxX(self.addPhotoButton.frame) + PSVC_ADD_PHOTO_BUTTON_MARGIN_RIGHT, self.addPhotoButton.frame.origin.y, self.view.frame.size.width - CGRectGetMaxX(self.addPhotoButton.frame), self.addPhotoButton.frame.size.height);
    
    [self.topBar.buttonBranding addTarget:self action:@selector(emotishLogoTouched:) forControlEvents:UIControlEventTouchUpInside];
    //    if (self.focus == FeelingFocus) {
    //        [self.topBar showButtonType:ProfileButton inPosition:LeftSpecial animated:NO];
    //    } else if (self.focus == UserFocus) {
    //        [self.topBar showButtonType:SettingsButton inPosition:LeftSpecial animated:NO];
    //    }
    
    self.headerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.photosClipView.scrollView = self.photosScrollView;
    self.photosClipView.frame = CGRectMake(0, PC_PHOTO_CELL_IMAGE_ORIGIN_Y, 320, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM + PC_PHOTO_CELL_LABEL_HEIGHT + PC_PHOTO_CELL_PADDING_BOTTOM);
    CGFloat photoViewWidth = PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL * 2;
    self.photosScrollView.frame = CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, 0, photoViewWidth, self.photosClipView.frame.size.height);
    self.photosScrollView.scrollsToTop = NO;
    self.photosContainer.frame = CGRectMake(0, 0, PSVC_PHOTO_VIEWS_COUNT * photoViewWidth, self.photosContainer.frame.size.height);
    self.photosScrollView.contentSize = self.photosContainer.frame.size;
    self.photosClipView.backgroundColor = [UIColor clearColor];
    self.photoViews = [NSArray arrayWithObjects:self.photoViewLeftmost, self.photoViewLeftCenter, self.photoViewCenter, self.photoViewRightCenter, self.photoViewRightmost, nil];
    for (PhotoView * photoView in self.photoViews) {
        photoView.delegate = self;
        [photoView showLikes:NO animated:NO];
        [self.photoViewsPhotoServerIDs addObject:[NSNull null]];
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    //    CGFloat flagStretchViewHeight = floorf(self.photoViewCenter.photoImageView.bounds.size.height / 2.0);
    CGFloat flagStretchViewHeight = floorf(self.photoViewCenter.photoImageView.bounds.size.height * PSVC_FLAG_STRETCH_VIEW_HEIGHT_PERCENTAGE_OF_PHOTO_VIEW_IMAGE_HEIGHT);
    CGRect photoViewRectInScrollView = [self.photosScrollView convertRect:self.photoViewCenter.photoImageView.frame fromView:self.photoViewCenter.superview];
    //    NSLog(@"photoViewRectInScrollView = %@", NSStringFromCGRect(photoViewRectInScrollView));
    self.flagStretchView = [[FlagStretchView alloc] initWithFrame:CGRectMake((photoViewRectInScrollView.size.height - flagStretchViewHeight) / 2.0, -screenWidth - self.photosScrollView.frame.origin.x, flagStretchViewHeight, screenWidth)];
    self.flagStretchView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
    self.flagStretchView.frame = CGRectMake(-screenWidth - self.photosScrollView.frame.origin.x, (photoViewRectInScrollView.size.height - flagStretchViewHeight) / 2.0, screenWidth, flagStretchViewHeight);
    //    NSLog(@"flagStretchView.frame = %@", NSStringFromCGRect(self.flagStretchView.frame));
    self.flagStretchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.flagStretchView setAngledShapes:YES angleSeverity:Subtle51213];
    [self.flagStretchView setMiddleStripeBorderWidth:10.0];
    //    self.flagStretchView.angledShapes = NO;
    self.flagStretchView.activationDistanceStart = PSVC_FLAG_STRETCH_VIEW_ACTIVATION_DISTANCE_START;
    self.flagStretchView.activationDistanceEnd = PSVC_FLAG_STRETCH_VIEW_ACTIVATION_DISTANCE_END;
    self.flagStretchView.activationAffectsAlpha = YES;
    self.flagStretchView.sidesAlphaNormal = 0.5;
    self.flagStretchView.sidesAlphaActivated = .9;
    self.flagStretchView.middleAlphaNormal = 0.5;
    self.flagStretchView.middleAlphaActivated = .9;
    //    self.flagStretchView.activationAffectsIcon = YES;
    //    self.flagStretchView.icon.opacity = 0.75;
    self.flagStretchView.icon.hidden = YES;
    //    self.flagStretchView.iconDistanceFromBottom = 20.0;
    //    self.flagStretchView.activationDistanceEnd = 2 * self.flagStretchView.iconDistanceFromBottom + self.flagStretchView.icon.frame.size.height;
    [self.photosScrollView insertSubview:self.flagStretchView aboveSubview:self.photosContainer];
    
    self.headerButton.frame = CGRectMake(0, 0, 320, CGRectGetMinY(self.photosClipView.frame));
    self.headerButton.contentEdgeInsets = UIEdgeInsetsMake(0, self.photosScrollView.frame.origin.x + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, PC_PHOTO_CELL_MARGIN_TOP, 320 - (CGRectGetMaxX(self.photosScrollView.frame) - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL));
    
    self.floatingImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.floatingImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.floatingImageView belowSubview:self.topBar];
    self.floatingImageView.alpha = 0.0;
    self.floatingImageView.userInteractionEnabled = NO;
    self.floatingImageView.backgroundColor = [UIColor clearColor];
    self.floatingImageView.clipsToBounds = YES;

    self.swipeRightHeaderGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRightOnHeader:)];
    self.swipeRightHeaderGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.headerButton addGestureRecognizer:self.swipeRightHeaderGestureRecognizer];
    
    self.zoomOutGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchedToZoomOut:)];
    [self.view addGestureRecognizer:self.zoomOutGestureRecognizer];
    
    self.swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedVertically:)];
    self.swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:self.swipeUpGestureRecognizer];
    self.swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedVertically:)];
    self.swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:self.swipeDownGestureRecognizer];
    
    [self updateViewsForCurrentFocus];
        
}

- (void)viewDidUnload {
    [self setHeaderButton:nil];
    [self setPhotosScrollView:nil];
    [self setFloatingImageView:nil];
    [self setFetchedResultsControllerFeeling:nil];
    [self setFetchedResultsControllerUser:nil];
    [self setFetchedResultsControllerFeelings:nil];
    [self setTopBar:nil];
    [self setAddPhotoLabel:nil];
    [self setPhotosContainer:nil];
    [self setPhotoViewLeftmost:nil];
    [self setPhotoViewLeftCenter:nil];
    [self setPhotoViewCenter:nil];
    [self setPhotoViewRightCenter:nil];
    [self setPhotoViewRightmost:nil];
    [self setPhotosClipView:nil];
//    [self setGalleryImageView:nil];
//    [self setBackgroundView:nil];
    [self setZoomOutGestureRecognizer:nil];
    [self setSwipeUpGestureRecognizer:nil];
    [self setSwipeDownGestureRecognizer:nil];
    [self setSwipeRightHeaderGestureRecognizer:nil];
    [self setContentView:nil];
    [self setAddPhotoButton:nil];
    [self setBottomBar:nil];
    [self setPhotoViews:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    NSLog(@"%@ PhotosStripViewController viewWillAppear", self.focus == FeelingFocus ? @"Feeling" : @"User");
    if (self.shouldAnimateIn) {
        
        self.floatingImageView.frame = CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X, PC_PHOTO_CELL_IMAGE_ORIGIN_Y, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH);
        self.floatingImageView.image = self.animationInPersistentImage;
        self.floatingImageView.alpha = 1.0;
        self.addPhotoLabel.alpha = 0.0;
        self.view.userInteractionEnabled = NO;
        self.photoViewLeftCenter.alpha = 0.0;
        self.photoViewRightCenter.alpha = 0.0;
        
        if (self.animationInSource == Gallery ||
            self.animationInSource == PhotosStripUnrelated) {
            
            self.headerButton.alpha = 0.0;
            self.photoViewCenter.alpha = 0.0;
            
            [self.topBar setViewMode:BrandingRight animated:NO];
            if (self.animationInSource == Gallery) {
                [self.topBar showButtonType:ProfileButton inPosition:LeftSpecial animated:NO];                
            } else {
                [self.topBar hideButtonInPosition:LeftSpecial animated:NO];
            }
            
        } else if (self.animationInSource == PhotosStripOpposite) {
            
            [self.topBar setViewMode:BrandingRight animated:NO];
            [self.topBar hideButtonInPosition:LeftSpecial animated:NO];
            CGRect headerFrame = self.headerButton.frame;
            CGRect captionFrame = self.photoViewCenter.photoCaptionTextField.frame;
            CGFloat headerTextWidth = MIN([self.headerButton.titleLabel.text sizeWithFont:self.headerButton.titleLabel.font].width, self.headerButton.frame.size.width - (self.headerButton.contentEdgeInsets.left + self.headerButton.contentEdgeInsets.right));
            CGFloat captionTextWidth = MIN([self.photoViewCenter.photoCaptionTextField.text sizeWithFont:self.photoViewCenter.photoCaptionTextField.font].width, self.photoViewCenter.photoCaptionTextField.frame.size.width);
            CGRect headerOffscreenFrame = CGRectMake(-(self.headerButton.contentEdgeInsets.left + headerTextWidth + PSVC_LABELS_ANIMATION_EXTRA_DISTANCE_OFFSCREEN), headerFrame.origin.y, headerFrame.size.width, headerFrame.size.height);
            CGPoint offscreenPointToCaptionLabel = [self.photoViewCenter.photoCaptionTextField.superview convertPoint:CGPointMake(self.view.frame.size.width, 0) fromView:self.view];
            CGRect captionOffscreenFrame = CGRectMake(offscreenPointToCaptionLabel.x + PSVC_LABELS_ANIMATION_EXTRA_DISTANCE_OFFSCREEN - (captionFrame.size.width - captionTextWidth), captionFrame.origin.y, captionFrame.size.width, captionFrame.size.height);
            self.headerButton.frame = headerOffscreenFrame;
            self.photoViewCenter.photoCaptionTextField.frame = captionOffscreenFrame;
            
        } else if (self.animationInSource == SubmitPhoto) {
            
            [self.topBar setViewMode:BrandingCenter animated:NO];
            [self.topBar showButtonType:BackButton inPosition:LeftNormal animated:NO];
            [self.topBar showButtonType:DoneButton inPosition:RightNormal animated:NO];
            self.addPhotoButton.alpha = 0.0;
            
        }
        
    } else {
        
        PFUser * currentUser = [PFUser currentUser];
        
        TopBarButtonType leftSpecialButtonType = 0;
        if (self.focus == FeelingFocus) {
            leftSpecialButtonType = ProfileButton;
        } else {
            leftSpecialButtonType = currentUser && [currentUser.objectId isEqualToString:self.userFocus.serverID] ? SettingsButton : ProfileButton;
        }
        [self.topBar showButtonType:leftSpecialButtonType inPosition:LeftSpecial animated:NO];
        [self.topBar.buttonLeftSpecial removeTarget:self action:@selector(profileButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.topBar.buttonLeftSpecial removeTarget:self action:@selector(settingsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.topBar.buttonLeftSpecial addTarget:self action:leftSpecialButtonType == ProfileButton ? @selector(profileButtonTouched:) : @selector(settingsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.photoViewCenter updateLikesCount:self.photoCenter.likesCount likedPersonally:[self.photoCenter likeExistsForUserServerID:currentUser.objectId]];
        
    }
    
    BOOL deleteAllowed = [self deleteAllowedForCurrentUser:[PFUser currentUser] withPhoto:self.photoCenter];
    [self.photoViewCenter setActionButtonWithCode:Delete enabled:deleteAllowed visible:deleteAllowed];
    [self.photoViewCenter showActionButtons:(self.photoViewCenter.actionButtonsVisible && [PFUser currentUser] != nil) animated:NO];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@ PhotosStripViewController viewDidAppear", self.focus == FeelingFocus ? @"Feeling" : @"User");
    if (self.shouldAnimateIn) {
        
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.addPhotoLabel.alpha = 1.0;
            self.photoViewLeftCenter.alpha = 1.0;
            self.photoViewRightCenter.alpha = 1.0;
            
            if (self.animationInSource == Gallery ||
                self.animationInSource == PhotosStripUnrelated) {
                self.headerButton.alpha = 1.0;
                self.photoViewCenter.alpha = 1.0;
            } else if (self.animationInSource == PhotosStripOpposite) {
                CGRect headerFrame = self.headerButton.frame;
                headerFrame.origin.x = 0;
                self.headerButton.frame = headerFrame;
                CGRect captionFrame = self.photoViewCenter.photoCaptionTextField.frame;
                captionFrame.origin.x = self.photoViewCenter.photoImageView.frame.origin.x;
                self.photoViewCenter.photoCaptionTextField.frame = captionFrame;
            } else if (self.animationInSource == SubmitPhoto) {
                [self.topBar setViewMode:BrandingRight animated:NO];
                [self.topBar hideButtonInPosition:LeftNormal animated:NO];
                [self.topBar hideButtonInPosition:RightNormal animated:NO];
                self.addPhotoButton.alpha = 1.0;
            }
            TopBarButtonType leftSpecialButtonType = 0;
            if (self.focus == FeelingFocus) {
                leftSpecialButtonType = ProfileButton;
            } else {
                PFUser * currentUser = [PFUser currentUser];
                leftSpecialButtonType = currentUser && [currentUser.objectId isEqualToString:self.userFocus.serverID] ? SettingsButton : ProfileButton;
            }
            [self.topBar showButtonType:leftSpecialButtonType inPosition:LeftSpecial animated:NO];
            [self.topBar.buttonLeftSpecial removeTarget:self action:@selector(profileButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            [self.topBar.buttonLeftSpecial removeTarget:self action:@selector(settingsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            [self.topBar.buttonLeftSpecial addTarget:self action:leftSpecialButtonType == ProfileButton ? @selector(profileButtonTouched:) : @selector(settingsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            
        } completion:^(BOOL finished){
            self.floatingImageView.alpha = 0.0;
            self.view.userInteractionEnabled = YES;
        }];
        
        self.shouldAnimateIn = NO;
        self.animationInSource = NoSource;
        self.animationInPersistentImage = nil;
        
    }
    NSLog(@"%@ PhotosStripViewController viewDidAppear finished", self.focus == FeelingFocus ? @"Feeling" : @"User");
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.coreDataManager saveCoreData];
    [self.getPhotosQuery cancel];
    for (NSString * photoServerID in self.photoWebImageManagersForPhotoServerIDs) {
        PhotoWebImageManager * manager = [self.photoWebImageManagersForPhotoServerIDs objectForKey:photoServerID];
        [[SDWebImageManager sharedManager] cancelForDelegate:manager];
    }
}

- (void) setPhotoCenterIndex:(NSUInteger)photoCenterIndex {
    [self setPhotoCenterIndex:photoCenterIndex forcePhotoViewsUpdate:NO];
}

- (void) setPhotoCenterIndex:(NSUInteger)photoCenterIndex forcePhotoViewsUpdate:(BOOL)forcePhotoViewsUpdate {
    if (_photoCenterIndex != photoCenterIndex) {
        NSLog(@"Change in photoCenterIndex (%d -> %d)", _photoCenterIndex, photoCenterIndex);
        _photoCenterIndex = photoCenterIndex;
        forcePhotoViewsUpdate = YES;
    }
    if (forcePhotoViewsUpdate) {
        self.photoCenter = [self.fetchedResultsControllerForCurrentFocus objectAtIndexPath:[NSIndexPath indexPathForRow:self.photoCenterIndex inSection:0]];
        [self updatePhotoViewsForPhotoCenterIndex:self.photoCenterIndex];
    }
}

- (void)setPhotoCenter:(Photo *)photoCenter {
    if (_photoCenter != photoCenter) {
        NSLog(@"Change in photoCenter (%@, %@'s %@ -> %@, %@'s %@)", _photoCenter.serverID, _photoCenter.user.name, _photoCenter.feeling.word, photoCenter.serverID, photoCenter.user.name, photoCenter.feeling.word);
        _photoCenter = photoCenter;
        if (self.photoCenter.shouldHighlight.boolValue) {
            self.photoCenter.shouldHighlight = [NSNumber numberWithBool:NO];
        }
    }
}

- (void)setFocusToFeeling:(Feeling *)feeling photo:(Photo *)photo {
    self.focus = FeelingFocus;
    self.feelingFocus = feeling;
    self.photoCenter = photo;
    if (self.view.window) {
        [self updateViewsForCurrentFocus];
    }
}

- (void)setFocusToUser:(User *)user photo:(Photo *)photo {
    self.focus = UserFocus;
    self.userFocus = user;
    self.photoCenter = photo;
    if (self.view.window) {
        [self updateViewsForCurrentFocus];
    }
}

- (void) setHeaderLabelText:(NSString *)headerString color:(UIColor *)headerColor {
    [self.headerButton setTitle:headerString forState:UIControlStateNormal];
    [self.headerButton setTitle:headerString forState:UIControlStateHighlighted];
    [self.headerButton setTitleColor:headerColor forState:UIControlStateNormal];
    [self.headerButton setTitleColor:headerColor forState:UIControlStateHighlighted];
}

- (void) updateViewsForCurrentFocus {
    
    NSString * headerString = nil;
    UIColor * headerColor = nil;
    NSString * addPhotoString = nil;
    if (self.focus == FeelingFocus) {
        headerString = self.feelingFocus.word;//.lowercaseString;
        headerColor = [UIColor feelingColor];
        addPhotoString = [NSString stringWithFormat:@"Do you feel %@?", self.feelingFocus.word];//.lowercaseString];
    } else if (self.focus == UserFocus) {
        headerString = self.userFocus.name;
        headerColor = [UIColor userColor];
        addPhotoString = @"What's your feeling?";
    } else {
        headerString = @"";
    }
    [self setHeaderLabelText:headerString color:headerColor];
    self.addPhotoLabel.text = addPhotoString;
    
    [NSFetchedResultsController deleteCacheWithName:self.fetchedResultsControllerForCurrentFocus.cacheName];
    NSPredicate * fetchPredicate = self.focus == FeelingFocus ? [NSPredicate predicateWithFormat:@"feeling == %@ && hidden == NO", self.feelingFocus] : [NSPredicate predicateWithFormat:@"user == %@ && hidden == NO", self.userFocus];
    self.fetchedResultsControllerForCurrentFocus.fetchRequest.predicate = fetchPredicate;
    [self performFetchForCurrentFocus];
    
    self.photosScrollView.contentSize = CGSizeMake(self.fetchedResultsControllerForCurrentFocus.fetchedObjects.count * self.photosScrollView.frame.size.width, self.photosScrollView.frame.size.height);
    
    [self setPhotoCenterIndex:[self.fetchedResultsControllerForCurrentFocus indexPathForObject:self.photoCenter].row forcePhotoViewsUpdate:YES];
    [self.photoViewCenter showLikes:self.photoCenter.likesCount.intValue > 0 animated:NO];
    [self.photosScrollView setContentOffset:CGPointMake(self.photoCenterIndex * self.photosScrollView.frame.size.width, 0) animated:NO];
    
}

- (void) updatePhotoViewsForPhotoCenterIndex:(int)photoCenterIndex {
    [self updatePhotoViewsPositionsForPhotoCenterIndex:photoCenterIndex];
    [self updatePhotoViewsPhotosForPhotoCenterIndex:photoCenterIndex];
}

- (void) updatePhotoViewsPositionsForPhotoCenterIndex:(int)photoCenterIndex {
    CGFloat photoViewCenterOriginX = self.photosScrollView.frame.size.width * photoCenterIndex;
    CGRect photosContainerFrame = self.photosContainer.frame;
    photosContainerFrame.origin.x = photoViewCenterOriginX - self.photoViewCenter.frame.origin.x; // Take the originX value for the point at which we want the photoViewCenter to be (in relation to the scrollView contentSize), and subtract from that the photoViewCenter's position within its superview. That is the point at which we want to place the photosContrainer
    self.photosContainer.frame = photosContainerFrame;
}

- (void) updatePhotoViewsPhotosForPhotoCenterIndex:(int)photoCenterIndex {
    int bumpDirection = -1;
    for (int n=0; n<self.photoViews.count; n++) {
        int bump = ((n + 1) / 2) * bumpDirection;
        int i = self.photoViewCenterIndex + bump;
//        NSLog(@"n    = %d", n);
//        NSLog(@"bump = %d", bump);
//        NSLog(@"i    = %d", i);
        PhotoView * photoView = [self.photoViews objectAtIndex:i];
        [self updatePhotoView:photoView atPhotoViewIndex:i withPhotoAtIndex:photoCenterIndex - self.photoViewCenterIndex + i];
        bumpDirection *= -1;
    }
}

- (void) updatePhotoView:(PhotoView *)photoView atPhotoViewIndex:(int)photoViewIndex withPhotoAtIndex:(int)photoIndex {
    
    Photo * photo = [self photoAtIndex:photoIndex];
    if (photo == nil) {
        [self.photoViewsPhotoServerIDs replaceObjectAtIndex:photoViewIndex withObject:[NSNull null]];
        photoView.photoImageView.image = nil;
    } else {
        [self.photoViewsPhotoServerIDs replaceObjectAtIndex:photoViewIndex withObject:photo.serverID];
        UIImage * cachedImageFull = [[SDImageCache sharedImageCache] imageFromKey:photo.imageURL];
        if (cachedImageFull != nil) {
            photoView.photoImageView.image = cachedImageFull;
        } else {
            UIImage * cachedImageThumb = [[SDImageCache sharedImageCache] imageFromKey:photo.thumbURL];
            if (cachedImageThumb != nil) {
                photoView.photoImageView.image = cachedImageThumb;
            } else {
                photoView.photoImageView.image = [UIImage imageNamed:@"photo_image_placeholder.png"];
            }
            if ([self.photoWebImageManagersForPhotoServerIDs objectForKey:photo.serverID] == nil) {
                NSLog(@"Download image with server id %@ and url %@", photo.serverID, photo.imageURL);
                PhotoWebImageManager * photoWebImageManager = [PhotoWebImageManager photoWebImageManagerForPhotoServerID:photo.serverID withDelegate:self];
                [self.photoWebImageManagersForPhotoServerIDs setObject:photoWebImageManager forKey:photo.serverID];
                [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:photo.imageURL] delegate:photoWebImageManager];
            } else {
                NSLog(@"Already downloading image with server id %@ and url %@", photo.serverID, photo.imageURL);
            }
        }
    }
    
    PFUser * currentUser = [PFUser currentUser];
    [photoView updateLikesCount:photo.likesCount likedPersonally:[photo likeExistsForUserServerID:currentUser.objectId]];
    BOOL deleteAllowed = [self deleteAllowedForCurrentUser:currentUser withPhoto:photo];
    [photoView setActionButtonWithCode:Delete enabled:deleteAllowed visible:deleteAllowed];
    [self updatePhotoViewCaption:photoView withDataFromPhoto:photo oppositeOfFocus:self.focus];
    
}

- (Photo *) photoAtIndex:(int)index {
    Photo * photo = nil;
    if (index >= 0 && index < self.fetchedResultsControllerForCurrentFocus.fetchedObjects.count) {
        photo = [self.fetchedResultsControllerForCurrentFocus objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    return photo;
}

- (void) updatePhotoViewCaption:(PhotoView *)photoView withDataFromPhoto:(Photo *)photo oppositeOfFocus:(PhotosStripFocus)mainViewDataFocus {
    NSString * captionText = nil;
    UIColor * captionColor = nil;
    if (photo != nil) {
        if (mainViewDataFocus == FeelingFocus) {
            captionText = photo.user.name;
            captionColor = [UIColor userColor];
        } else {
            captionText = photo.feeling.word;//.lowercaseString;
            captionColor = [UIColor feelingColor];
        }
    }
    photoView.photoCaptionTextField.text = captionText;
    photoView.photoCaptionTextField.textColor = captionColor;
}

- (int) indexForContentOffsetX:(CGFloat)contentOffsetX {
    int contentOffsetMiddleWithinBounds = (int)MIN(MAX(0, contentOffsetX),
                                                   self.photosScrollView.contentSize.width - 1); // Sort of a view-controller-specific hackish implementation, based on the fact that there is no point in returning an index that will invariably be out of bounds.
    return contentOffsetMiddleWithinBounds / (int)self.photosScrollView.frame.size.width;
}

- (int) indexForScrollViewCenterWithContentOffsetX:(CGFloat)contentOffsetX {
    return [self indexForContentOffsetX:contentOffsetX + floorf(self.photosScrollView.frame.size.width / 2.0)];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.photoViewCenter showActionButtons:NO animated:YES];
    // The following may not be necessary... I think we actually just need to showLikes:NO for self.photoViewCenter. But this probably isn't all that expensive for now.
    for (PhotoView * photoView in self.photoViews) {
        [photoView showLikes:NO animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidScroll");
    self.flagStretchView.pulledOutDistance = MAX(0, -scrollView.contentOffset.x);
    BOOL activationZone = scrollView.isTracking && self.flagStretchView.pulledOutDistance >= self.flagStretchView.activationDistanceEnd;
    [self.flagStretchView setActivated:activationZone animated:YES];
//    if (!self.refreshAllRequested) {
//        self.photosScrollView.contentInset = activationZone ? UIEdgeInsetsMake(0, self.flagStretchView.activationDistanceEnd, 0, 0) : UIEdgeInsetsZero;
//    }
    if (!self.controllerChangingContent) {
        self.photoCenterIndex = [self indexForScrollViewCenterWithContentOffsetX:scrollView.contentOffset.x]; // This will potentially cause view updates to occur, depending on whether photoCenterIndex has changed.
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self.photoViewCenter showLikes:self.photoCenter.likesCount.intValue > 0 animated:YES];
    }
    if (self.flagStretchView.activated && !self.refreshAllInProgress) {
        self.refreshAllRequested = YES;
        self.view.userInteractionEnabled = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.photoViewCenter showLikes:self.photoCenter.likesCount.intValue > 0 animated:YES];
    if (self.refreshAllRequested) {
        self.refreshAllRequested = NO;
        self.view.userInteractionEnabled = YES;
        if (self.focus == FeelingFocus) {
            [self getPhotosFromServerForFeeling:self.feelingFocus];
        } else {
            [self getPhotosFromServerForUser:self.userFocus];
        }
    }
}

- (NSFetchedResultsController *)fetchedResultsControllerForCurrentFocus {
    return [self fetchedResultsControllerForFocus:self.focus];
}

- (NSFetchedResultsController *)fetchedResultsControllerForFocus:(PhotosStripFocus)focus {
    NSFetchedResultsController * fetchedResultsController = nil;
    if (focus == FeelingFocus) {
        fetchedResultsController = self.fetchedResultsControllerFeeling;
    } else if (focus == UserFocus) {
        fetchedResultsController = self.fetchedResultsControllerUser;
    }
    return fetchedResultsController;
}

- (void)performFetchForCurrentFocus {
    if (self.focus != NoFocus) {
        NSError * error;
        if (![self.fetchedResultsControllerForCurrentFocus performFetch:&error]) {
            // Handle the error appropriately...
            NSLog(@"PhotosStripViewController - Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
    }
}

- (NSFetchedResultsController *)fetchedResultsControllerFeeling {
    
    if (_fetchedResultsControllerFeeling != nil) {
        return _fetchedResultsControllerFeeling;
    }
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.coreDataManager.managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"feeling == %@ && hidden == NO", self.feelingFocus];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO]];
    fetchRequest.fetchBatchSize = 10; // Think about this later?
    
    _fetchedResultsControllerFeeling = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreDataManager.managedObjectContext sectionNameKeyPath:nil cacheName:@"FeelingFocus"];
    _fetchedResultsControllerFeeling.delegate = self;
    
    return _fetchedResultsControllerFeeling;
    
}

- (NSFetchedResultsController *)fetchedResultsControllerUser {
    
    if (_fetchedResultsControllerUser != nil) {
        return _fetchedResultsControllerUser;
    }
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.coreDataManager.managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user == %@ && hidden == NO", self.userFocus];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO]];
    fetchRequest.fetchBatchSize = 10; // Think about this later?
    
    _fetchedResultsControllerUser = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreDataManager.managedObjectContext sectionNameKeyPath:nil cacheName:@"UserFocus"];
    _fetchedResultsControllerUser.delegate = self;
    
    return _fetchedResultsControllerUser;
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (controller == self.fetchedResultsControllerForCurrentFocus) {
        NSLog(@"self.fetchedResultsControllerForCurrentFocus willChangeContent");
        self.refreshAllNetChangeBeforePreviousPhotoCenterIndex = 0;
        NSLog(@"self.refreshAllNetChangeBeforePreviousPhotoCenterIndex reset to 0");
        self.controllerChangingContent = YES;
    }
}

//NSFetchedResultsChangeInsert = 1
//NSFetchedResultsChangeDelete = 2
//NSFetchedResultsChangeMove   = 3
//NSFetchedResultsChangeUpdate = 4
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
//    NSLog(@"self.fetchedResultsControllerForCurrentFocus didChangeObject:%@ atIndexPath:%d-%d forChangeType:%d newIndexPath:%d-%d", anObject, indexPath.section, indexPath.row, type, newIndexPath.section, newIndexPath.row);
    if (controller == self.fetchedResultsControllerForCurrentFocus) {
        if (type == NSFetchedResultsChangeDelete && self.focus == UserFocus) {
            Photo * photo = (Photo *)anObject;
            photo.feeling.word = photo.feeling.word;
        }
        if (!self.refreshAllInProgress) {
            if (type == NSFetchedResultsChangeUpdate) {
                int photoViewLowestPhotoIndex  = self.photoCenterIndex - self.photoViewCenterIndex;
                int photoViewHighestPhotoIndex = self.photoCenterIndex + self.photoViewCenterIndex;
                if (indexPath.row >= photoViewLowestPhotoIndex &&
                    indexPath.row <= photoViewHighestPhotoIndex) {
                    NSUInteger photoViewIndex = self.photoViewCenterIndex - (self.photoCenterIndex - indexPath.row);
    //                NSLog(@"Going to update photoView %@ at photoViewIndex=%d withPhotooAtIndex:%d", [self.photoViews objectAtIndex:photoViewIndex], photoViewIndex, indexPath.row);
                    [self updatePhotoView:[self.photoViews objectAtIndex:photoViewIndex] atPhotoViewIndex:photoViewIndex withPhotoAtIndex:indexPath.row];
                    if (!self.photosScrollView.isTracking) {
                        [self.photoViewCenter showLikes:self.photoCenter.likesCount.intValue > 0 animated:YES];
                    }
                }
            } else if (type == NSFetchedResultsChangeDelete) {
                if (indexPath.row == self.photoCenterIndex) {
                    self.view.userInteractionEnabled = NO;
                    
                    if (self.fetchedResultsControllerForCurrentFocus.fetchedObjects.count == 0) {
                        [self viewControllerFinishedWithNoMorePhotos:YES];
                    } else {
                        
                        self.photoCenter.feeling.word = self.photoCenter.feeling.word; // Touch the Feeling object so that the Gallery's fetched results controller is notified of the Photo delete and the potential resulting disappearance of the Feeling (if it was the last visible Photo for the Feeling)
                        
                        [UIScrollView animateWithDuration:0.25 animations:^{ // Note the receiver Class UIScrollView here. New trick I hadn't known before!
                            self.photoViewCenter.alpha = 0.0;
                            if (self.photoCenterIndex < self.fetchedResultsControllerForCurrentFocus.fetchedObjects.count) {
                                self.photoViewRightCenter.frame = self.photoViewCenter.frame;
                                self.photoViewRightmost.frame = CGRectOffset(self.photoViewRightCenter.frame, self.photoViewRightCenter.frame.size.width, 0);                            
                            } else {
                                [self.photosScrollView setContentOffset:CGPointMake(self.photosScrollView.contentSize.width -  2 * self.photosScrollView.frame.size.width, 0)];
                            }
                        } completion:^(BOOL finished) {
                            [self setPhotoCenterIndex:MIN(self.photoCenterIndex, self.fetchedResultsControllerForCurrentFocus.fetchedObjects.count - 1) forcePhotoViewsUpdate:YES];
                            [self.photoViewCenter showActionButtons:NO animated:NO];                
                            self.photoViewCenter.alpha = 1.0;
                            self.photoViewRightCenter.frame = CGRectOffset(self.photoViewCenter.frame, self.photoViewCenter.frame.size.width, 0);
                            self.photoViewRightmost.frame = CGRectOffset(self.photoViewRightCenter.frame, self.photoViewRightCenter.frame.size.width, 0);
                            [self.photoViewCenter showLikes:self.photoCenter.likesCount.intValue > 0 animated:YES];
                            self.view.userInteractionEnabled = YES;
                            self.photosScrollView.contentSize = CGSizeMake(self.fetchedResultsControllerForCurrentFocus.fetchedObjects.count * self.photosScrollView.frame.size.width, self.photosScrollView.frame.size.height);
                        }];
                    }
                }
            }
        } else {
            if (type == NSFetchedResultsChangeInsert && newIndexPath.row <= self.photoCenterIndex) {
                self.refreshAllNetChangeBeforePreviousPhotoCenterIndex++;
                NSLog(@"self.refreshAllNetChangeBeforePreviousPhotoCenterIndex = %d", self.refreshAllNetChangeBeforePreviousPhotoCenterIndex);
            } else if (type == NSFetchedResultsChangeDelete && indexPath.row < self.photoCenterIndex) {
                self.refreshAllNetChangeBeforePreviousPhotoCenterIndex--;
                NSLog(@"self.refreshAllNetChangeBeforePreviousPhotoCenterIndex = %d", self.refreshAllNetChangeBeforePreviousPhotoCenterIndex);
            }
        }
    }
}

//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//    if (controller == self.fetchedResultsControllerForCurrentFocus) {
//        NSLog(@"self.fetchedResultsControllerForCurrentFocus didChangeSection...");
//    }
//}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (controller == self.fetchedResultsControllerForCurrentFocus) {
        NSLog(@"self.fetchedResultsControllerForCurrentFocus didChangeContent");
        if (self.refreshAllInProgress) {
            
            if (self.fetchedResultsControllerForCurrentFocus.fetchedObjects.count == 0) {
                
                [self viewControllerFinishedWithNoMorePhotos:YES];
                
            } else {
                
                Photo * oldPhotoCenter = self.photoCenter;
                BOOL oldPhotoCenterHidden = oldPhotoCenter.hidden.boolValue;
                int oldPhotoCenterIndex = self.photoCenterIndex;
                int newPhotoCenterIndex = oldPhotoCenterIndex;
                
                self.photosScrollView.contentSize = CGSizeMake(self.fetchedResultsControllerForCurrentFocus.fetchedObjects.count * self.photosScrollView.frame.size.width, self.photosScrollView.frame.size.height);
                
                if (oldPhotoCenterHidden) {
                    newPhotoCenterIndex += self.refreshAllNetChangeBeforePreviousPhotoCenterIndex;
                    newPhotoCenterIndex = MIN(MAX(0, newPhotoCenterIndex), (int)(self.photosScrollView.contentSize.width - 1) / self.fetchedResultsControllerForCurrentFocus.fetchedObjects.count);
                } else {
                    newPhotoCenterIndex = [self.fetchedResultsControllerForCurrentFocus indexPathForObject:oldPhotoCenter].row;
                }
                NSLog(@"oldPhotoCenterIndex = %d, newPhotoCenterIndex = %d, self.refreshAllNetChangeBeforePreviousPhotoCenterIndex = %d", oldPhotoCenterIndex, newPhotoCenterIndex, self.refreshAllNetChangeBeforePreviousPhotoCenterIndex);
                
                [self.photosScrollView stopScroll];
                [self setPhotoCenterIndex:newPhotoCenterIndex forcePhotoViewsUpdate:YES];
                [self.photosScrollView setContentOffset:CGPointMake(self.photoCenterIndex * self.photosScrollView.frame.size.width, 0) animated:NO];
                [self.photoViewCenter showLikes:self.photoCenter.likesCount.intValue > 0 animated:NO];
                
            }
            
        }
        self.refreshAllInProgress = NO;
    }
    self.controllerChangingContent = NO;
}

- (void) userCurrent:(PFUser *)userCurrent likedPhotoAttempt:(Photo *)photoLiked {
    if (userCurrent == nil) {
        [self.signInAlertView show];
    } else {
        if (![photoLiked likeExistsForUserServerID:userCurrent.objectId] ||
            unlimited_likes_allowed) {
            [self userCurrent:userCurrent likedPhoto:photoLiked];
        }
    }
}

- (void) userCurrent:(PFUser *)userCurrent likedPhoto:(Photo *)photoLiked {
    NSString * photoCenterServerID = photoLiked.serverID;
    PFObject * photoServer = [PFObject objectWithClassName:@"Photo"];
    photoServer.objectId = photoCenterServerID;
    [photoServer incrementKey:@"likesCount"];
    [photoServer saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error){
        if (succeeded) {
            
            // Local data updates...
            Like * likeObjectLocal = [NSEntityDescription insertNewObjectForEntityForName:@"Like" inManagedObjectContext:self.coreDataManager.managedObjectContext];
            likeObjectLocal.photo = photoLiked;
            likeObjectLocal.user = (User *)[self.coreDataManager getFirstObjectForEntityName:@"User" matchingPredicate:[NSPredicate predicateWithFormat:@"SELF.serverID == %@", userCurrent.objectId] usingSortDescriptors:nil];
            // Local data save...
            [self.coreDataManager saveCoreData];
            
//            // View update // Taken care of now in controller:didChangeObject:...
//            if (photoLiked == self.photoCenter) {
//                [self.photoViewCenter showLikes:YES likesCount:self.photoCenter.likesCount likedPersonally:YES animated:YES];
//            }
            
            // More server calls...
            PFObject * likeObject = [PFObject objectWithClassName:@"Like"];
            [likeObject setObject:userCurrent forKey:@"user"];
            [likeObject setObject:photoServer forKey:@"photo"];
            [likeObject saveInBackground];
            
            // More server calls...
            PFQuery * photoUpdatedQuery = [PFQuery queryWithClassName:@"Photo"];
            [photoUpdatedQuery getObjectInBackgroundWithId:photoCenterServerID block:^(PFObject * object, NSError * error){
                if (!error && object != nil) {
                    [self.coreDataManager addOrUpdatePhotoFromServer:object];
                } else {
                    // Local data updates...
                    photoLiked.likesCount = [NSNumber numberWithInt:photoLiked.likesCount.intValue + 1];
                }
                [self.coreDataManager saveCoreData];
            }];
            
            // Client push notification
            BOOL testingWithOnlyOneDeviceAvailable = NO;
            if (![userCurrent.objectId isEqualToString:photoLiked.user.serverID] ||
                testingWithOnlyOneDeviceAvailable) {
                NSMutableDictionary * pushNotificationData = [NSMutableDictionary dictionary];
                [pushNotificationData setObject:[NSString stringWithFormat:@"%@ liked your %@ photo!", userCurrent.username, photoLiked.feeling.word] forKey:@"alert"];
                //                [pushNotificationData setObject:userCurrent.objectId forKey:PUSH_LIKER_USER_SERVER_ID];
                [pushNotificationData setObject:photoLiked.serverID forKey:PUSH_LIKED_PHOTO_SERVER_ID];
                //                [pushNotificationData setObject:photoLiked.feeling.serverID forKey:PUSH_LIKED_FEELING_SERVER_ID];
                //                [pushNotificationData setObject:photoLiked.user.serverID forKey:PUSH_LIKED_USER_SERVER_ID];
                [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"%@%@", PUSH_USER_CHANNEL_PREFIX, photoLiked.user.serverID] withData:pushNotificationData];
            }
            
        } else {
            [[EmotishAlertViews generalConnectionErrorAlertView] show];
        }
    }];
}

- (void) userCurrent:(PFUser *)userCurrent deletedPhotoAttempt:(Photo *)photoDeleted {
    if ([self deleteAllowedForCurrentUser:userCurrent withPhoto:photoDeleted]) {
        self.photoToDelete = photoDeleted;
        [self.confirmDeleteAlertView show];
    }
}

- (void) userDeletedPhoto:(Photo *)photoDeleted {
    
    photoDeleted.hidden = [NSNumber numberWithBool:YES];
    [self.coreDataManager saveCoreData];
    
    PFObject * photoServer = [PFObject objectWithClassName:@"Photo"];
    photoServer.objectId = photoDeleted.serverID;
    [photoServer setObject:[NSNumber numberWithBool:YES] forKey:@"deleted"];
    [photoServer saveEventually];
    
}

- (void)photoView:(PhotoView *)photoView photoCaptionButtonTouched:(UIButton *)photoCaptionButton {
    if (photoView == self.photoViewCenter) {
        [self photoViewSelected:self.photoViewCenter withPhoto:self.photoCenter];
    }
}

- (void)photoView:(PhotoView *)photoView tapSingleGestureDidBegin:(UITapGestureRecognizer *)gestureRecognizer {
    if (photoView == self.photoViewCenter && !self.photoViewCenter.actionButtonsVisible) {
        self.blockViewControllerFinishing = YES;
    }
}

- (void)photoView:(PhotoView *)photoView tapSingleGestureRecognized:(UITapGestureRecognizer *)gestureRecognizer {
    if (photoView == self.photoViewCenter) {
        if (self.photoViewCenter.actionButtonsVisible) {
            [self.photoViewCenter showActionButtons:NO animated:YES];
        } else {
            [self photoViewSelected:self.photoViewCenter withPhoto:self.photoCenter];
        }
        self.blockViewControllerFinishing = NO;
    }
}

- (void)photoView:(PhotoView *)photoView tapDoubleGestureRecognized:(UITapGestureRecognizer *)gestureRecognizer {
    if (photoView == self.photoViewCenter) {
        [self userCurrent:[PFUser currentUser] likedPhotoAttempt:self.photoCenter];
        self.blockViewControllerFinishing = NO;
    }
}

- (void)photoView:(PhotoView *)photoView tapHoldGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (photoView == self.photoViewCenter) {
        if ([PFUser currentUser] == nil) {
            [self.signInAlertView show];
        } else {
            [self.photoViewCenter showActionButtons:!self.photoViewCenter.actionButtonsVisible animated:YES];
        }
        self.blockViewControllerFinishing = NO;
    }    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.signInAlertView && buttonIndex != alertView.cancelButtonIndex) {
        [self showAccountViewController];
    } else if (alertView == self.confirmDeleteAlertView && buttonIndex == alertView.cancelButtonIndex) {
        [self userDeletedPhoto:self.photoToDelete];
    }
}

- (void)photoView:(PhotoView *)photoView actionButtonTouched:(UIButton *)actionButton withActionButtonCode:(PhotoViewActionButtonCode)actionButtonCode {
    
    // TEMPORARY below
    UIAlertView * tempFeatureInProgressAlertView = [[UIAlertView alloc] initWithTitle:@"In Development..." message:@"We're still working on this feature! Sorry!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    // TEMPORARY above
    
    switch (actionButtonCode) {
        case Twitter:
            // Twitter...
            // ...
            //            break;
        case Facebook:
            // Facebook...
            // ...
            //            break;
        case Email:
            // Email...
            // ...
            //            break;
        case TextMessage:
            // TextMessage...
            [tempFeatureInProgressAlertView show];
            break;
        case Flag:
            // Flag...
            [tempFeatureInProgressAlertView show];
            break;
        case Delete:
            // Delete...
            [self userCurrent:[PFUser currentUser] deletedPhotoAttempt:self.photoCenter];
//            [tempFeatureInProgressAlertView show];
            break;
        case LikePhoto:
            // Like...
            [self userCurrent:[PFUser currentUser] likedPhotoAttempt:self.photoCenter];
            break;
        default:
            break;
    }
    
}

- (void)photoViewSelected:(PhotoView *)photoView withPhoto:(Photo *)photo {
    // There is a weird crash caused by your selecting a photo view and then immediately tapping the header label to return to the gallery. The header label tap is recognized before the photo view selection, yet both try to execute. This is due to the photo view selection coming from a single tap gesture recognizer, which requires (and waits for) a doulbe tap gesture recognizer to fail.
    // For now, I'm going to mask this bug by just checking if the view controller is already in the process of finishing, and if so, ignore the photo view selection. // That didn't work. I've added a delegate callback method to PhotoView that should help take care of the problem.
    if (!self.finishing) {
        
        NSLog(@"photoViewSelected:withPhoto:");
        NSLog(@"self.finishing = %d", self.finishing);
        
        self.view.userInteractionEnabled = NO;
        
        PhotosStripViewController * oppositeFocusStripViewController = [[PhotosStripViewController alloc] initWithNibName:@"PhotosStripViewController" bundle:[NSBundle mainBundle]];
        oppositeFocusStripViewController.delegate = self.delegate;
        oppositeFocusStripViewController.modalTransitionStyle = self.modalTransitionStyle;
        oppositeFocusStripViewController.coreDataManager = self.coreDataManager;
        oppositeFocusStripViewController.fetchedResultsControllerFeelings = self.fetchedResultsControllerFeelings;
        if (self.focus == FeelingFocus) {
            [oppositeFocusStripViewController setFocusToUser:photo.user photo:photo];
        } else {
            [oppositeFocusStripViewController setFocusToFeeling:photo.feeling photo:photo];
        }
        [oppositeFocusStripViewController setShouldAnimateIn:YES fromSource:PhotosStripOpposite withPersistentImage:photoView.photoImageView.image];
        //    oppositeFocusStripViewController.galleryScreenshot = self.galleryScreenshot;
        
        // Animate the transition
        //    CGRect headerFrame = self.headerButton.frame;
        //    CGRect captionFrame = photoView.photoCaptionTextField.frame;
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
            [photoView showActionButtons:NO animated:NO];
            CGFloat headerTextLeftEdgeInView = self.headerButton.frame.origin.x + self.headerButton.contentEdgeInsets.left;
            CGFloat captionTextRightEdgeInView = CGRectGetMaxX([self.view convertRect:photoView.frame fromView:photoView.superview]);
            //        NSLog(@"%f %f", headerTextLeftEdgeInView, captionTextRightEdgeInView);
            self.headerButton.frame = CGRectOffset(self.headerButton.frame, self.headerButton.frame.size.width - headerTextLeftEdgeInView + PSVC_LABELS_ANIMATION_EXTRA_DISTANCE_OFFSCREEN, 0);
            photoView.photoCaptionTextField.frame = CGRectOffset(photoView.photoCaptionTextField.frame, -(captionTextRightEdgeInView + PSVC_LABELS_ANIMATION_EXTRA_DISTANCE_OFFSCREEN), 0);
            for (PhotoView * photoViewToAdjust in self.photoViews) {
                if (photoViewToAdjust != photoView) {
                    photoViewToAdjust.alpha = 0.0;
                }
            }
            self.addPhotoLabel.alpha = 0.0;
            [self.topBar hideButtonInPosition:LeftSpecial animated:NO];
        } completion:^(BOOL finished){
            // Actually request for (instantaneous, imperceptible) the pop & push -ing of view controllers
            [self.delegate photosStripViewController:self requestedReplacementWithPhotosStripViewController:oppositeFocusStripViewController];
        }];
    }
}

- (void)setShouldAnimateIn:(BOOL)shouldAnimateIn fromSource:(PhotosStripAnimationInSource)source withPersistentImage:(UIImage *)image {
    self.shouldAnimateIn = shouldAnimateIn;
    self.animationInSource = source;
    self.animationInPersistentImage = image;
}

- (void)headerButtonTouched:(UIButton *)button {
    NSLog(@"headerButtonTouched");
    [self viewControllerFinishedWithNoMorePhotos:NO];
}

- (void)pinchedToZoomOut:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if (pinchGestureRecognizer.velocity < 0.0) {
        [self viewControllerFinishedWithNoMorePhotos:NO];
    }
}

- (void)viewControllerFinishedWithNoMorePhotos:(BOOL)noMorePhotos {
    
    if (!self.finishing && !self.blockViewControllerFinishing) {
        
        NSLog(@"viewControllerFinishedWithNoMorePhotos:%d", noMorePhotos);
        
        self.finishing = YES;
        [self.photosScrollView stopScroll];
        
////        self.galleryImageView.image = self.galleryScreenshot;
        self.floatingImageView.frame = CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X, PC_PHOTO_CELL_IMAGE_ORIGIN_Y, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH);
        self.floatingImageView.image = self.photoViewCenter.photoImageView.image;
        self.floatingImageView.alpha = 1.0;
        self.photoViewCenter.photoImageView.alpha = 0.0;
        
        [self.delegate photosStripViewControllerFinished:self withNoMorePhotos:noMorePhotos];
        
//        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
////
////            [self.photoViewCenter showActionButtons:NO animated:NO];
////            self.headerButton.alpha = 0.0;
////            self.addPhotoLabel.alpha = 0.0;
////            self.photosScrollView.alpha = 0.0;
//////            self.backgroundView.alpha = 0.0;            
//            self.floatingImageView.frame = CGRectInset(self.floatingImageView.frame, self.floatingImageView.frame.size.width * 0.1, self.floatingImageView.frame.size.height * 0.1);
//            self.floatingImageView.alpha = 0.0;
//////            if (self.focus == UserFocus) {
//////                [self.topBar showButtonType:ProfileButton inPosition:LeftSpecial animated:NO];
//////            }
////            
//        } completion:^(BOOL finished){
////            
//////            [self.delegate photosStripViewControllerFinished:self withNoMorePhotos:noMorePhotos];
////            
//        }];
        
    }
    
}

- (NSString *)photoViewNameForPhotoView:(PhotoView *)photoView {
    NSString * photoViewName = @"photoViewUnknown";
    if (photoView == self.photoViewLeftmost) {
        photoViewName = @"photoViewLeftmost";
    } else if (photoView == self.photoViewLeftCenter) {
        photoViewName = @"photoViewLeftCenter";
    } else if (photoView == self.photoViewCenter) {
        photoViewName = @"photoViewCenter";
    } else if (photoView == self.photoViewRightCenter) {
        photoViewName = @"photoViewRightCenter";
    } else if (photoView == self.photoViewRightmost) {
        photoViewName = @"photoViewRightmost";
    } 
    return photoViewName;
}

- (void)emotishLogoTouched:(UIButton *)button {
    [self viewControllerFinishedWithNoMorePhotos:NO];
}

- (void)swipedVertically:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    
    // Test if current focus is on a Feeling
    if (self.focus == FeelingFocus) {
        
        NSLog(@"Swiped %@", swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp ? @"up" : @"down");
        NSIndexPath * indexPath = [self.fetchedResultsControllerFeelings indexPathForObject:self.feelingFocus];
        int indexAdjustment = swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp ? 1 : -1; // Swiping up means that you are pushing the content of the view up, trying to bring up the content that is "below". That content belongs to the next alphabetical feeling. In contrast, swiping down would bring in the previous alphabetical feeling.
        if (!(indexPath.row + indexAdjustment < 0 || 
              indexPath.row + indexAdjustment >= self.fetchedResultsControllerFeelings.fetchedObjects.count)) {
            Feeling * nextFeeling = [self.fetchedResultsControllerFeelings objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + indexAdjustment inSection:indexPath.section]]; // Keep in mind that the "next" feeling might actually be the "previous" feeling alphabetically - it is "next" in the sense that it is now the "next" Feeling that will be displayed on screen.
            
            PhotosStripViewController * feelingViewController = [[PhotosStripViewController alloc] initWithNibName:@"PhotosStripViewController" bundle:[NSBundle mainBundle]];
            feelingViewController.delegate = self.delegate;
            feelingViewController.modalTransitionStyle = self.modalTransitionStyle;
            feelingViewController.coreDataManager = self.coreDataManager;
            feelingViewController.fetchedResultsControllerFeelings = self.fetchedResultsControllerFeelings;
            [feelingViewController setFocusToFeeling:nextFeeling photo:[nextFeeling.mostRecentPhotos objectAtIndex:0]];
//            feelingViewController.galleryScreenshot = self.galleryScreenshot;
            
//            feelingViewController.galleryImageView.alpha = 0.0;
//            feelingViewController.backgroundView.alpha = 0.0;
            feelingViewController.topBar.alpha = 0.0;
            feelingViewController.bottomBar.alpha = 0.0;
            feelingViewController.addPhotoButton.alpha = 0.0;
            feelingViewController.addPhotoLabel.alpha = 0.0;
            
            [self.view insertSubview:feelingViewController.view belowSubview:self.topBar];
            int direction = swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp ? -1 : 1;
            feelingViewController.view.frame = CGRectMake(0, -direction * self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);// CGRectOffset(self.view.frame, 0, -direction * self.view.frame.size.height);
            NSLog(@"self = %@", NSStringFromCGRect(self.view.frame));
            NSLog(@"feel = %@", NSStringFromCGRect(feelingViewController.view.frame));
            CGFloat originYAdjustment = direction * self.view.frame.size.height;
            NSLog(@"yadj = %f", originYAdjustment);
            
            [UIView animateWithDuration:0.125 animations:^{
                self.addPhotoLabel.alpha = 0.0;
            } completion:^(BOOL finished){
                [UIView animateWithDuration:0.125 animations:^{
                    feelingViewController.addPhotoLabel.alpha = 1.0;
                }];
            }];
            [UIView animateWithDuration:0.25 animations:^{
                self.contentView.frame = CGRectOffset(self.contentView.frame, 0, originYAdjustment);
                feelingViewController.view.frame = CGRectOffset(feelingViewController.view.frame, 0, originYAdjustment);
            } completion:^(BOOL finished){
//                feelingViewController.galleryImageView.alpha = 1.0;
//                feelingViewController.backgroundView.alpha = 1.0;
                feelingViewController.topBar.alpha = 1.0;
                feelingViewController.bottomBar.alpha = 1.0;
                feelingViewController.addPhotoButton.alpha = 1.0;
                feelingViewController.addPhotoLabel.alpha = 1.0;
                [self.delegate photosStripViewController:self requestedReplacementWithPhotosStripViewController:feelingViewController];
            }];
            
        }
        
    }
    
}

- (void)swipedRightOnHeader:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    CGPoint swipeLocationInHeaderButton = [swipeGestureRecognizer locationInView:self.headerButton];
    if (swipeLocationInHeaderButton.x >= self.headerButton.contentEdgeInsets.left && 
        swipeLocationInHeaderButton.x <= [self.headerButton.titleLabel.text sizeWithFont:self.headerButton.titleLabel.font constrainedToSize:CGSizeMake(self.headerButton.frame.size.width - self.headerButton.contentEdgeInsets.left - self.headerButton.contentEdgeInsets.right, self.headerButton.frame.size.height)].width + self.headerButton.contentEdgeInsets.left) {
        if (!self.photosScrollView.isTracking) {
            [self photoViewSelected:self.photoViewCenter withPhoto:self.photoCenter];
        }
    }
}

- (IBAction)addPhotoButtonTouched:(id)sender {
    SubmitPhotoViewController * submitPhotoViewController = [[SubmitPhotoViewController alloc] initWithNibName:@"SubmitPhotoViewController" bundle:[NSBundle mainBundle]];
    if (self.focus == FeelingFocus) {
        submitPhotoViewController.feelingWord = self.feelingFocus.word;
    }
    submitPhotoViewController.shouldPushImagePicker = YES;
    submitPhotoViewController.coreDataManager = self.coreDataManager;
    submitPhotoViewController.delegate = self.delegate;
    [self presentModalViewController:submitPhotoViewController animated:NO];
}

// THIS METHOD IS DUPLICATED IN VARIOUS PLACES
- (void)getPhotosFromServerForFeeling:(Feeling *)feeling {
    self.refreshAllInProgress = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.getPhotosQuery = [PFQuery queryWithClassName:@"Photo"];
    PFObject * feelingServer = [PFObject objectWithClassName:@"Feeling"];
    feelingServer.objectId = feeling.serverID;
    [self.getPhotosQuery whereKey:@"feeling" equalTo:feelingServer];
    //    [self.getPhotosQuery whereKey:@"flagged" notEqualTo:[NSNumber numberWithBool:YES]];
    //    [self.getPhotosQuery whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    self.getPhotosQuery.limit = [NSNumber numberWithInt:100]; // This should be much smaller eventually. But currently this is the only place where we are loading Photos, so, gotta keep it big! Just testing.
    [self.getPhotosQuery orderByDescending:@"createdAt"];
    [self.getPhotosQuery includeKey:@"feeling"];
    [self.getPhotosQuery includeKey:@"user"];
    [self.getPhotosQuery findObjectsInBackgroundWithTarget:self selector:@selector(getPhotosFromServerCallback:error:)];
}

- (void)getPhotosFromServerForUser:(User *)user {
    self.refreshAllInProgress = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.getPhotosQuery = [PFQuery queryWithClassName:@"Photo"];
    PFUser * userServer = [PFUser user];
    userServer.objectId = user.serverID;
    [userServer setObject:user.name forKey:@"username"];
    [self.getPhotosQuery whereKey:@"user" equalTo:userServer];
    //    [self.getPhotosQuery whereKey:@"flagged" notEqualTo:[NSNumber numberWithBool:YES]];
    //    [self.getPhotosQuery whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    self.getPhotosQuery.limit = [NSNumber numberWithInt:100]; // This should be revisited.
    [self.getPhotosQuery orderByDescending:@"createdAt"];
    [self.getPhotosQuery includeKey:@"feeling"];
    [self.getPhotosQuery includeKey:@"user"];
    [self.getPhotosQuery findObjectsInBackgroundWithTarget:self selector:@selector(getPhotosFromServerCallback:error:)];
}

// THIS METHOD IS DUPLICATED IN VARIOUS PLACES
- (void)getPhotosFromServerCallback:(NSArray *)results error:(NSError *)error {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (!error) {
        NSLog(@"Success - %d results", results.count);
        for (PFObject * photoServer in results) {
            PFObject * feelingServer = [photoServer objectForKey:@"feeling"];
            PFObject * userServer = [photoServer objectForKey:@"user"];
            [self.coreDataManager addOrUpdatePhotoFromServer:photoServer feelingFromServer:feelingServer userFromServer:userServer];
        }
        [self.coreDataManager saveCoreData];
    } else {
        NSLog(@"Network Connection Error: %@ %@", error, error.userInfo);
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"There was an error contacting the server. This is not yet being handled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

//- (void)getUpdateFromServerForPhoto:(Photo *)photo {
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    PFQuery * photoUpdateQuery = [PFQuery queryWithClassName:@"Photo"];
//    [self.photoUpdateQueries addObject:photoUpdateQuery];
//    [photoUpdateQuery getObjectInBackgroundWithId:photo.serverID block:^(PFObject *object, NSError * error){
//        if (!error && object != nil) {
//            [self.coreDataManager addOrUpdatePhotoFromServer:object];
//            [self.coreDataManager saveCoreData];
//            [self updateViewsForCurrentFocus]; // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight // Ridiculously heavyweight
//        }
//        [self.photoUpdateQueries removeObject:photoUpdateQuery];
//    }];
//}

- (void)profileButtonTouched:(UIButton *)button {
    NSLog(@"Profile button touched...");
    
    PFUser * currentUser = [PFUser currentUser];
    User * currentUserLocal = currentUser == nil ? nil : (User *)[self.coreDataManager getFirstObjectForEntityName:@"User" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", currentUser.objectId]  usingSortDescriptors:nil];
    if (currentUser == nil) {
        [self showAccountViewController];
    } else {
        
        if (!currentUserLocal.photosVisibleExist.boolValue) {
            [self showSettingsViewControllerForUserLocal:currentUserLocal userServer:currentUser];
        } else {
            
            PhotosStripViewController * feelingViewController = [[PhotosStripViewController alloc] initWithNibName:@"PhotosStripViewController" bundle:[NSBundle mainBundle]];
            feelingViewController.delegate = self.delegate;
            feelingViewController.modalTransitionStyle = self.modalTransitionStyle;
            feelingViewController.coreDataManager = self.coreDataManager;
            feelingViewController.fetchedResultsControllerFeelings = self.fetchedResultsControllerFeelings;
            Photo * firstPhotoForUser = (Photo *)[self.coreDataManager getFirstObjectForEntityName:@"Photo" matchingPredicate:[NSPredicate predicateWithFormat:@"user == %@ && hidden == NO", currentUserLocal] usingSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO]]];
            [feelingViewController setFocusToUser:currentUserLocal photo:firstPhotoForUser];
            [feelingViewController setShouldAnimateIn:YES fromSource:PhotosStripUnrelated withPersistentImage:nil];
//            feelingViewController.galleryScreenshot = self.galleryScreenshot;
            
            [UIView animateWithDuration:0.25 animations:^{
                self.contentView.alpha = 0.0;
                self.addPhotoLabel.alpha = 0.0;
                [self.topBar hideButtonInPosition:LeftSpecial animated:NO];
            } completion:^(BOOL finished){
                [self.delegate photosStripViewController:self requestedReplacementWithPhotosStripViewController:feelingViewController];
            }];
            
        }
        
    }
    
}

- (void) showAccountViewController {
    AccountViewController * accountViewController = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:[NSBundle mainBundle]];
    accountViewController.delegate = self;
    accountViewController.coreDataManager = self.coreDataManager;
    accountViewController.swipeDownToCancelEnabled = YES;
    [self presentModalViewController:accountViewController animated:YES];
}

- (void)accountViewController:(AccountViewController *)accountViewController didFinishWithConnection:(BOOL)finishedWithConnection viaConnectMethod:(AccountConnectMethod)connectMethod {
    [self dismissModalViewControllerAnimated:YES];
    if (finishedWithConnection) {
        UIAlertView * loggedInAlertView = [[UIAlertView alloc] initWithTitle:@"Logged In" message:@"Have fun expressing yourself!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [loggedInAlertView show];
    }
}

- (void)settingsButtonTouched:(UIButton *)button {
    NSLog(@"Settings button touched...");
    PFUser * currentUserServer = [PFUser currentUser];
    User * currentUserLocal = (User *)[self.coreDataManager getFirstObjectForEntityName:@"User" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", currentUserServer.objectId] usingSortDescriptors:nil];
    [self showSettingsViewControllerForUserLocal:currentUserLocal userServer:currentUserServer];
}

- (void)showSettingsViewControllerForUserLocal:(User *)userLocal userServer:(PFUser *)userServer {
    NSLog(@"Settings button touched...");
    SettingsViewController * settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    settingsViewController.delegate = self;
    settingsViewController.coreDataManager = self.coreDataManager;
    UINavigationController * settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsNavController.navigationBarHidden = YES;
    //    settingsNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:settingsNavController animated:YES];
}

- (void) settingsViewControllerFinished:(SettingsViewController *)settingsViewController {
    [self dismissModalViewControllerAnimated:YES];
}

- (UIAlertView *)signInAlertView {
    if (_signInAlertView == nil) {
        _signInAlertView = [[UIAlertView alloc] initWithTitle:@"Sign In" message:@"Sign in to an Emotish account to Like, Share, and Post Photos!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign In", nil];
        _signInAlertView.delegate = self;
    }
    return _signInAlertView;
}

- (UIAlertView *)confirmDeleteAlertView {
    if (_confirmDeleteAlertView == nil) {
        _confirmDeleteAlertView = [[UIAlertView alloc] initWithTitle:@"Delete Photo?" message:@"Are you sure you want to delete your Photo?" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
        _confirmDeleteAlertView.delegate = self;
    }
    return _confirmDeleteAlertView;
}

- (BOOL) deleteAllowedForCurrentUser:(PFUser *)currentUser withPhoto:(Photo *)photo {
    return currentUser != nil && [currentUser.objectId isEqualToString:photo.user.serverID];
}

- (void)photoWebImageManager:(PhotoWebImageManager *)photoWebImangeManager withWebImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    NSLog(@"photoWebImageManager:withWebImageManager:didFinishWithImage:%@forPhotoWithServerID:%@", image, photoWebImangeManager.photoServerID);
    NSUInteger photoViewIndexOfPhotoServerID = [self.photoViewsPhotoServerIDs indexOfObject:photoWebImangeManager.photoServerID];
    if (photoViewIndexOfPhotoServerID != NSNotFound) {
        ((PhotoView *)[self.photoViews objectAtIndex:photoViewIndexOfPhotoServerID]).photoImageView.image = image;
    }
    [self.photoWebImageManagersForPhotoServerIDs removeObjectForKey:photoWebImangeManager.photoServerID];
}

- (void)photoWebImageManager:(PhotoWebImageManager *)photoWebImangeManager withWebImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error {
    NSLog(@"photoWebImageManager:withWebImageManager:didFailWithError:%@forPhotoWithServerID:%@", error, photoWebImangeManager.photoServerID);
    // Not sure what to do really... Hope that a future download will succeed, I suppose?
    [self.photoWebImageManagersForPhotoServerIDs removeObjectForKey:photoWebImangeManager.photoServerID];
}
                 
- (NSUInteger) photoViewCenterIndex {
    return self.photoViews.count / 2;
}

@end
