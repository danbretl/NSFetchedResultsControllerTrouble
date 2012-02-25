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
@property (strong, nonatomic) Photo * photoInView;
//@property (unsafe_unretained, nonatomic) PhotoView * photoViewInView;
@property (strong, nonatomic, readonly) PhotoView * photoViewInView;
@property (strong, nonatomic, readonly) NSFetchedResultsController * fetchedResultsControllerForCurrentFocus;
- (NSFetchedResultsController *)fetchedResultsControllerForFocus:(PhotosStripFocus)focus;
- (void) performFetchForCurrentFocus;
- (void) updateViewsForCurrentFocus;
- (void) reloadPhotoViewsFocusedOnPhoto:(Photo *)photo;
- (void) reloadPhotoView:(PhotoView *)photoView givenFocusOnIndexPath:(NSIndexPath *)centerIndexPath;
- (void) updatePhotoViewCaption:(PhotoView *)photoView withDataFromPhoto:(Photo *)photo oppositeOfFocus:(PhotosStripFocus)mainViewDataFocus;
- (void) pinchedToZoomOut:(UIPinchGestureRecognizer *)pinchGestureRecognizer;
- (void) swipedVertically:(UISwipeGestureRecognizer *)swipeGestureRecognizer;
- (void) tappedToSelectPhotoView:(UITapGestureRecognizer *)tapGestureRecognizer;
- (void) swipedRightOnHeader:(UISwipeGestureRecognizer *)swipeGestureRecognizer;
- (void) photoInView:(Photo *)photo selectedFromPhotoView:(PhotoView *)photoView;
- (void) viewControllerFinished;
- (IBAction)headerButtonTouched:(UIButton *)button;
@property (nonatomic) BOOL shouldAnimateIn;
@property (nonatomic) PhotosStripAnimationInSource animationInSource;
@property (strong, nonatomic) UIImage * animationInPersistentImage;
@property (nonatomic) BOOL finishing;
- (NSString *)photoViewNameForPhotoView:(PhotoView *)photoView;
- (void)emotishLogoTouched:(UIButton *)button;
- (IBAction)addPhotoButtonTouched:(id)sender;
- (void)getPhotosFromServerForFeeling:(Feeling *)feeling;
- (void)getPhotosFromServerForUser:(User *)user;
- (void)getPhotosFromServerCallback:(NSArray *)results error:(NSError *)error;
@property (strong, nonatomic) PFQuery * getPhotosQuery;
- (void) profileButtonTouched:(UIButton *)button;
- (void) settingsButtonTouched:(UIButton *)button;
@end

@implementation PhotosStripViewController
@synthesize focus=_focus;
@synthesize feelingFocus=_feelingFocus, userFocus=_userFocus, photoInView=_photoInView;
@synthesize shouldAnimateIn=_shouldAnimateIn, animationInSource=_animationInSource, animationInPersistentImage=_animationInPersistentImage;
@synthesize galleryScreenshot=_galleryScreenshot;
@synthesize galleryImageView = _galleryImageView;
@synthesize backgroundView = _backgroundView;
@synthesize coreDataManager=_coreDataManager;
@synthesize fetchedResultsControllerFeeling=_fetchedResultsControllerFeeling;
@synthesize fetchedResultsControllerUser=_fetchedResultsControllerUser;
@synthesize fetchedResultsControllerFeelings=_fetchedResultsControllerFeelings;
@synthesize bottomBar = _bottomBar;
@synthesize fetchedResultsControllerForCurrentFocus=_fetchedResultsControllerForCurrentFocus;
@synthesize topBar=_topBar;
@synthesize contentView = _contentView;
@synthesize headerButton=_headerButton;
@synthesize photosClipView = _photosClipView;
@synthesize photosScrollView=_photosScrollView;
@synthesize flagStretchView=_flagStretchView;
@synthesize photosContainer = _photosContainer;
@synthesize photoViewLeftmost = _photoViewLeftmost;
@synthesize photoViewLeftCenter = _photoViewLeftCenter;
@synthesize photoViewCenter = _photoViewCenter;
@synthesize photoViewRightCenter = _photoViewRightCenter;
@synthesize photoViewRightmost = _photoViewRightmost;
@synthesize photoViewInView = _photoViewInView;
@synthesize floatingImageView=_floatingImageView;
@synthesize addPhotoButton = _addPhotoButton;
@synthesize addPhotoLabel = _addPhotoLabel;
@synthesize zoomOutGestureRecognizer=_zoomOutGestureRecognizer, swipeUpGestureRecognizer=_swipeUpGestureRecognizer, swipeDownGestureRecognizer=_swipeDownGestureRecognizer, swipeRightHeaderGestureRecognizer=_swipeRightHeaderGestureRecognizer;
@synthesize finishing=_finishing;
@synthesize getPhotosQuery=_getPhotosQuery;
@synthesize delegate=_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.focus = NoFocus;
//        self.photoViewInView = nil;
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
    UITapGestureRecognizer * tapToSelectPhotoViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToSelectPhotoView:)];
    [self.photosScrollView addGestureRecognizer:tapToSelectPhotoViewGestureRecognizer];
    self.photosClipView.backgroundColor = [UIColor clearColor];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//    CGFloat flagStretchViewHeight = floorf(self.photoViewCenter.photoImageView.bounds.size.height / 2.0);
    CGFloat flagStretchViewHeight = floorf(self.photoViewCenter.photoImageView.bounds.size.height * PSVC_FLAG_STRETCH_VIEW_HEIGHT_PERCENTAGE_OF_PHOTO_VIEW_IMAGE_HEIGHT);
    CGRect photoViewRectInScrollView = [self.photosScrollView convertRect:self.photoViewCenter.photoImageView.frame fromView:self.photoViewCenter.superview];
    NSLog(@"photoViewRectInScrollView = %@", NSStringFromCGRect(photoViewRectInScrollView));
    self.flagStretchView = [[FlagStretchView alloc] initWithFrame:CGRectMake((photoViewRectInScrollView.size.height - flagStretchViewHeight) / 2.0, -screenWidth - self.photosScrollView.frame.origin.x, flagStretchViewHeight, screenWidth)];
    self.flagStretchView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
    self.flagStretchView.frame = CGRectMake(-screenWidth - self.photosScrollView.frame.origin.x, (photoViewRectInScrollView.size.height - flagStretchViewHeight) / 2.0, screenWidth, flagStretchViewHeight);
    NSLog(@"flagStretchView.frame = %@", NSStringFromCGRect(self.flagStretchView.frame));
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
//    UITapGestureRecognizer * floatingImageViewTempTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(floatingImageViewTouched:)];
//    [self.floatingImageView addGestureRecognizer:floatingImageViewTempTapGestureRecognizer];
    
    [self updateViewsForCurrentFocus];
//    self.photoViewInView = self.photoViewCenter;
    
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
    
    BOOL debugging = NO;
    if (debugging) {
        self.photosScrollView.backgroundColor = [UIColor redColor];
    }

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
    [self setGalleryImageView:nil];
    [self setBackgroundView:nil];
    [self setZoomOutGestureRecognizer:nil];
    [self setSwipeUpGestureRecognizer:nil];
    [self setSwipeDownGestureRecognizer:nil];
    [self setSwipeRightHeaderGestureRecognizer:nil];
    [self setContentView:nil];
    [self setAddPhotoButton:nil];
    [self setBottomBar:nil];
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
    }
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
    [self.getPhotosQuery cancel];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setFocusToFeeling:(Feeling *)feeling photo:(Photo *)photo {
    self.focus = FeelingFocus;
    self.feelingFocus = feeling;
    self.photoInView = photo;
    self.photoInView.shouldHighlight = [NSNumber numberWithBool:NO];
    if (self.view.window) {
        [self updateViewsForCurrentFocus];
//        self.photoViewInView = self.photoViewCenter;
    }
//    NSLog(@"Should scroll to photo %@", photo);
}

- (void)setFocusToUser:(User *)user photo:(Photo *)photo {
    self.focus = UserFocus;
    self.userFocus = user;
    self.photoInView = photo;
    self.photoInView.shouldHighlight = [NSNumber numberWithBool:NO];
    if (self.view.window) {
        [self updateViewsForCurrentFocus];
//        self.photoViewInView = self.photoViewCenter;
    }
//    NSLog(@"Should scroll to photo %@", photo);
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
    NSPredicate * fetchPredicate = self.focus == FeelingFocus ? [NSPredicate predicateWithFormat:@"feeling == %@", self.feelingFocus] : [NSPredicate predicateWithFormat:@"user == %@", self.userFocus];
    self.fetchedResultsControllerForCurrentFocus.fetchRequest.predicate = fetchPredicate;
    [self performFetchForCurrentFocus];
    self.photosScrollView.contentSize = CGSizeMake(self.fetchedResultsControllerForCurrentFocus.fetchedObjects.count * self.photosScrollView.frame.size.width, self.photosScrollView.frame.size.height);
    
    [self reloadPhotoViewsFocusedOnPhoto:self.photoInView];
    self.photosScrollView.contentOffset = CGPointMake(self.photosScrollView.frame.size.width * [self.fetchedResultsControllerForCurrentFocus indexPathForObject:self.photoInView].row, 0);
//    [self.photosTableView reloadData];
//    [self.photosTableView scrollToRowAtIndexPath:[self.fetchedResultsControllerForCurrentFocus indexPathForObject:self.photoInView] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void) reloadPhotoViewsFocusedOnPhoto:(Photo *)photo {
    
    NSIndexPath * photoCenterIndexPath = [self.fetchedResultsControllerForCurrentFocus indexPathForObject:photo];
    
    [self reloadPhotoView:self.photoViewCenter givenFocusOnIndexPath:photoCenterIndexPath];
    [self reloadPhotoView:self.photoViewLeftCenter givenFocusOnIndexPath:photoCenterIndexPath];
    [self reloadPhotoView:self.photoViewLeftmost givenFocusOnIndexPath:photoCenterIndexPath];
    [self reloadPhotoView:self.photoViewRightCenter givenFocusOnIndexPath:photoCenterIndexPath];
    [self reloadPhotoView:self.photoViewRightmost givenFocusOnIndexPath:photoCenterIndexPath];
    
    CGFloat contentOffsetX = self.photosScrollView.frame.size.width * photoCenterIndexPath.row;
    CGRect photosContainerFrame = self.photosContainer.frame;
    photosContainerFrame.origin.x = contentOffsetX - self.photoViewCenter.frame.origin.x;
    self.photosContainer.frame = photosContainerFrame;
//    self.photosScrollView.contentOffset = CGPointMake(contentOffsetX, 0);
    
}

- (void) reloadPhotoView:(PhotoView *)photoView givenFocusOnIndexPath:(NSIndexPath *)centerIndexPath {
    
    NSUInteger fetchedPhotosCount = self.fetchedResultsControllerForCurrentFocus.fetchedObjects.count;
    
    NSIndexPath * validIndexPathForPhotoView = nil;
    if (photoView == self.photoViewCenter) {
        validIndexPathForPhotoView = centerIndexPath;
    } else {
        int rowBump = 0;
        if (photoView == self.photoViewLeftCenter ||
            photoView == self.photoViewLeftmost) {
            rowBump = -1;
            if (photoView == self.photoViewLeftmost) { rowBump *= 2; }
        } else {
            rowBump = 1;
            if (photoView == self.photoViewRightmost) { rowBump *= 2; }
        }
        if (!(centerIndexPath.row + rowBump < 0 || 
              centerIndexPath.row + rowBump >= fetchedPhotosCount)) {
            validIndexPathForPhotoView = [NSIndexPath indexPathForRow:centerIndexPath.row + rowBump inSection:0];
        }
    }
    
    Photo * photo = validIndexPathForPhotoView == nil ? nil : [self.fetchedResultsControllerForCurrentFocus objectAtIndexPath:validIndexPathForPhotoView];
    if (photo == nil) {
        photoView.photoImageView.image = nil;
    } else {
        [photoView.photoImageView setImageWithURL:[NSURL URLWithString:photo.imageURL] placeholderImage:[UIImage imageNamed:@"photo_image_placeholder.png"]];
    }
    [self updatePhotoViewCaption:photoView withDataFromPhoto:photo oppositeOfFocus:self.focus];
    
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat pulledOutDistance = MAX(0, -scrollView.contentOffset.x);
//    NSLog(@"pulledOutDistance = %f", MAX(0, -scrollView.contentOffset.x));
    self.flagStretchView.pulledOutDistance = MAX(0, -scrollView.contentOffset.x);//pulledOutDistance;
    [self.flagStretchView setActivated:scrollView.isTracking && self.flagStretchView.pulledOutDistance >= self.flagStretchView.activationDistanceEnd animated:YES];
//    [self.flagStretchView setActivated:scrollView.isTracking && -scrollView.contentOffset.x >= self.flagStretchView.activationDistanceEnd animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat contentOffsetToMiddleX = scrollView.contentOffset.x + (scrollView.frame.size.width / 2.0);
    contentOffsetToMiddleX = MAX(contentOffsetToMiddleX, 0);
    contentOffsetToMiddleX = MIN(contentOffsetToMiddleX, self.photosScrollView.contentSize.width - self.photosScrollView.frame.size.width);
    NSUInteger indexOfPhotoInView = (int)contentOffsetToMiddleX / (int)self.photosScrollView.frame.size.width;
    Photo * photoInView = [self.fetchedResultsControllerForCurrentFocus objectAtIndexPath:[NSIndexPath indexPathForRow:indexOfPhotoInView inSection:0]];
    if (!decelerate) {
        self.photoInView = photoInView;
        self.photoInView.shouldHighlight = [NSNumber numberWithBool:NO];
//        NSLog(@"Photo view in view : %@", [self photoViewNameForPhotoView:self.photoViewInView]);
//        NSLog(@"Photo in view : %@-%@", self.photoInView.feeling.word, self.photoInView.user.name);
    }
    [self reloadPhotoViewsFocusedOnPhoto:photoInView];
//    self.photoInView = [self.fetchedResultsControllerForCurrentFocus objectAtIndexPath:[NSIndexPath indexPathForRow:indexOfPhotoInView inSection:0]];
//    [self reloadPhotoViewsFocusedOnPhoto:self.photoInView];
    if (self.flagStretchView.activated) {
        if (self.focus == FeelingFocus) {
            [self getPhotosFromServerForFeeling:self.feelingFocus];
        } else {
            [self getPhotosFromServerForUser:self.userFocus];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger indexOfPhotoInView = (int)scrollView.contentOffset.x / (int)self.photosScrollView.frame.size.width;
    self.photoInView = [self.fetchedResultsControllerForCurrentFocus objectAtIndexPath:[NSIndexPath indexPathForRow:indexOfPhotoInView inSection:0]];
    self.photoInView.shouldHighlight = [NSNumber numberWithBool:NO];
//    NSLog(@"Photo view in view : %@", [self photoViewNameForPhotoView:self.photoViewInView]);
//    NSLog(@"Photo in view : %@-%@", self.photoInView.feeling.word, self.photoInView.user.name);
//    [self reloadPhotoViewsFocusedOnPhoto:self.photoInView];
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
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"feeling == %@", self.feelingFocus];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO]];
    fetchRequest.fetchBatchSize = 10;
    
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
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user == %@", self.userFocus];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO]];
    fetchRequest.fetchBatchSize = 10;
    
    _fetchedResultsControllerUser = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreDataManager.managedObjectContext sectionNameKeyPath:nil cacheName:@"UserFocus"];
    _fetchedResultsControllerUser.delegate = self;
    
    return _fetchedResultsControllerUser;
    
}

- (void)tappedToSelectPhotoView:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint locationInScrollView = [tapGestureRecognizer locationInView:self.photosScrollView];
    if (CGRectContainsPoint(CGRectInset(self.photosScrollView.bounds, PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, 0), locationInScrollView)) {
//        PhotoView * photoViewTapped = self.photoViewCenter;
//        CGPoint locationInPhotosContainer = [tapGestureRecognizer locationInView:self.photosContainer];
//        if (CGRectContainsPoint(self.photoViewLeftCenter.frame, locationInPhotosContainer)) {
//            photoViewTapped = self.photoViewLeftCenter;
////            NSLog(@"self.photoViewLeftCenter");
//        } else if (CGRectContainsPoint(self.photoViewRightCenter.frame, locationInPhotosContainer)) {
//            photoViewTapped = self.photoViewRightCenter;
////            NSLog(@"self.photoViewRightCenter");
//        } else {
////            NSLog(@"self.photoViewCenter");
//        }
        [self photoInView:self.photoInView selectedFromPhotoView:self.photoViewInView];
//        [self photoInView:self.photoInView selectedFromPhotoView:photoViewTapped];
    }
}

- (void)photoInView:(Photo *)photo selectedFromPhotoView:(PhotoView *)photoView {
    
//    NSLog(@"Selected photo view in view : %@", [self photoViewNameForPhotoView:self.photoViewInView]);
//    NSLog(@"Selected photo in view : %@-%@", self.photoInView.feeling.word, self.photoInView.user.name);
        
    PhotosStripViewController * oppositeFocusStripViewController = [[PhotosStripViewController alloc] initWithNibName:@"PhotosStripViewController" bundle:[NSBundle mainBundle]];
    oppositeFocusStripViewController.delegate = self.delegate;
    oppositeFocusStripViewController.coreDataManager = self.coreDataManager;
    oppositeFocusStripViewController.fetchedResultsControllerFeelings = self.fetchedResultsControllerFeelings;
    if (self.focus == FeelingFocus) {
        [oppositeFocusStripViewController setFocusToUser:photo.user photo:photo];
    } else {
        [oppositeFocusStripViewController setFocusToFeeling:photo.feeling photo:photo];
    }
    [oppositeFocusStripViewController setShouldAnimateIn:YES fromSource:PhotosStripOpposite withPersistentImage:photoView.photoImageView.image];
    oppositeFocusStripViewController.galleryScreenshot = self.galleryScreenshot;
    
    self.view.userInteractionEnabled = NO;

    // Animate the transition
//    CGRect headerFrame = self.headerButton.frame;
//    CGRect captionFrame = photoView.photoCaptionTextField.frame;
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
        CGFloat headerTextLeftEdgeInView = self.headerButton.frame.origin.x + self.headerButton.contentEdgeInsets.left;
        CGFloat captionTextRightEdgeInView = CGRectGetMaxX([self.view convertRect:photoView.frame fromView:photoView.superview]);
//        NSLog(@"%f %f", headerTextLeftEdgeInView, captionTextRightEdgeInView);
        self.headerButton.frame = CGRectOffset(self.headerButton.frame, self.headerButton.frame.size.width - headerTextLeftEdgeInView + PSVC_LABELS_ANIMATION_EXTRA_DISTANCE_OFFSCREEN, 0);
        photoView.photoCaptionTextField.frame = CGRectOffset(photoView.photoCaptionTextField.frame, -(captionTextRightEdgeInView + PSVC_LABELS_ANIMATION_EXTRA_DISTANCE_OFFSCREEN), 0);
        void(^photoViewAlpha)(PhotoView *)=^(PhotoView * photoViewInQuestion){
            photoViewInQuestion.alpha = photoView == photoViewInQuestion ? 1.0 : 0.0;
        };
        photoViewAlpha(self.photoViewCenter);
        photoViewAlpha(self.photoViewLeftCenter);
        photoViewAlpha(self.photoViewRightCenter);
        photoViewAlpha(self.photoViewLeftmost);
        photoViewAlpha(self.photoViewRightmost);
        self.addPhotoLabel.alpha = 0.0;
        [self.topBar hideButtonInPosition:LeftSpecial animated:NO];
    } completion:^(BOOL finished){
        // Actually request for (instantaneous, imperceptible) the pop & push -ing of view controllers
        [self.delegate photosStripViewController:self requestedReplacementWithPhotosStripViewController:oppositeFocusStripViewController];
    }];
    
}

- (void)setShouldAnimateIn:(BOOL)shouldAnimateIn fromSource:(PhotosStripAnimationInSource)source withPersistentImage:(UIImage *)image {
    self.shouldAnimateIn = shouldAnimateIn;
    self.animationInSource = source;
    self.animationInPersistentImage = image;
}

- (void)headerButtonTouched:(UIButton *)button {
    [self viewControllerFinished];
}

- (void)pinchedToZoomOut:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if (pinchGestureRecognizer.velocity < 0.0) {
        [self viewControllerFinished];
        self.finishing = YES;
    }
}

- (void)viewControllerFinished {
//    NSLog(@"viewControllerFinished");
    
    if (!self.finishing) {
    
        self.galleryImageView.image = self.galleryScreenshot;
        self.floatingImageView.frame = CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X, PC_PHOTO_CELL_IMAGE_ORIGIN_Y, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH);
        self.floatingImageView.image = self.photoViewInView.photoImageView.image;
        self.floatingImageView.alpha = 1.0;
    //    [UIView animateWithDuration:0.5 animations:^{
    //        self.floatingImageView.frame = CGRectInset(self.floatingImageView.frame, self.floatingImageView.frame.size.width * 0.1, self.floatingImageView.frame.size.height * 0.1);
    //        self.floatingImageView.alpha = 0.0;
    //    }];
        self.photoViewInView.photoImageView.alpha = 0.0;
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.headerButton.alpha = 0.0;
            self.addPhotoLabel.alpha = 0.0;
            self.photosScrollView.alpha = 0.0;
            self.backgroundView.alpha = 0.0;            
            self.floatingImageView.frame = CGRectInset(self.floatingImageView.frame, self.floatingImageView.frame.size.width * 0.1, self.floatingImageView.frame.size.height * 0.1);
            self.floatingImageView.alpha = 0.0;
            if (self.focus == UserFocus) {
                [self.topBar showButtonType:ProfileButton inPosition:LeftSpecial animated:NO];
            }
            
        } completion:^(BOOL finished){
            
            [self.delegate photosStripViewControllerFinished:self];
            
    //        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    //            self.backgroundView.alpha = 0.0;            
    ////            self.floatingImageView.frame = CGRectInset(self.floatingImageView.frame, self.floatingImageView.frame.size.width * 0.1, self.floatingImageView.frame.size.height * 0.1);
    ////            self.floatingImageView.alpha = 0.0;
    //        } completion:^(BOOL finished){
    //            [self.delegate photosStripViewControllerFinished:self];
    //        }];
            
        }];
        
    }
    
}

- (PhotoView *)photoViewInView {
    int indexOfPhotoView = (int)(self.photosScrollView.contentOffset.x - self.photosContainer.frame.origin.x) / self.photosScrollView.frame.size.width;
    PhotoView * photoView = nil;
    switch (indexOfPhotoView) {
        case 2: photoView = self.photoViewCenter; break;
        case 1: photoView = self.photoViewLeftCenter; break;
        case 3: photoView = self.photoViewRightCenter; break;
        case 0: photoView = self.photoViewLeftmost; break;
        case 4: photoView = self.photoViewRightmost; break;
        default: break;
    }
    return photoView;
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
    [self viewControllerFinished];
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
            feelingViewController.coreDataManager = self.coreDataManager;
            feelingViewController.fetchedResultsControllerFeelings = self.fetchedResultsControllerFeelings;
            [feelingViewController setFocusToFeeling:nextFeeling photo:[nextFeeling.mostRecentPhotos objectAtIndex:0]];
            feelingViewController.galleryScreenshot = self.galleryScreenshot;
            
            feelingViewController.galleryImageView.alpha = 0.0;
            feelingViewController.backgroundView.alpha = 0.0;
            feelingViewController.topBar.alpha = 0.0;
            feelingViewController.bottomBar.alpha = 0.0;
            feelingViewController.addPhotoButton.alpha = 0.0;
            feelingViewController.addPhotoLabel.alpha = 0.0;
                        
            [self.view insertSubview:feelingViewController.view belowSubview:self.topBar];
            int direction = swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp ? -1 : 1;
            feelingViewController.view.frame = CGRectOffset(self.view.frame, 0, -direction * self.view.frame.size.height);
            CGFloat originYAdjustment = direction * self.view.frame.size.height;
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
                feelingViewController.galleryImageView.alpha = 1.0;
                feelingViewController.backgroundView.alpha = 1.0;
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
            NSLog(@"Swipe right");
            [self photoInView:self.photoInView selectedFromPhotoView:self.photoViewInView];
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.getPhotosQuery = [PFQuery queryWithClassName:@"Photo"];
    PFObject * feelingServer = [PFObject objectWithClassName:@"Feeling"];
    feelingServer.objectId = feeling.serverID;
    [self.getPhotosQuery whereKey:@"feeling" equalTo:feelingServer];
    self.getPhotosQuery.limit = [NSNumber numberWithInt:100]; // This should be much smaller eventually. But currently this is the only place where we are loading Photos, so, gotta keep it big! Just testing.
    [self.getPhotosQuery orderByDescending:@"createdAt"];
    [self.getPhotosQuery includeKey:@"feeling"];
    [self.getPhotosQuery includeKey:@"user"];
    [self.getPhotosQuery findObjectsInBackgroundWithTarget:self selector:@selector(getPhotosFromServerCallback:error:)];
}

- (void)getPhotosFromServerForUser:(User *)user {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.getPhotosQuery = [PFQuery queryWithClassName:@"Photo"];
    PFUser * userServer = [PFUser user];
    userServer.objectId = user.serverID;
    [userServer setObject:user.name forKey:@"username"];
    [self.getPhotosQuery whereKey:@"user" equalTo:userServer];
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
    [self updateViewsForCurrentFocus]; // This has issues with contentOffset
}

- (void)profileButtonTouched:(UIButton *)button {
    NSLog(@"Profile button touched...");
    
    PFUser * currentUser = [PFUser currentUser];
    if (currentUser == nil) {
        AccountViewController * accountViewController = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:[NSBundle mainBundle]];
        accountViewController.delegate = self;
        accountViewController.coreDataManager = self.coreDataManager;
        [self presentModalViewController:accountViewController animated:YES];
    } else {
        
        User * currentUserLocal = (User *)[self.coreDataManager getFirstObjectForEntityName:@"User" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", currentUser.objectId] usingSortDescriptors:nil];
        
        PhotosStripViewController * feelingViewController = [[PhotosStripViewController alloc] initWithNibName:@"PhotosStripViewController" bundle:[NSBundle mainBundle]];
        feelingViewController.delegate = self.delegate;
        feelingViewController.coreDataManager = self.coreDataManager;
        feelingViewController.fetchedResultsControllerFeelings = self.fetchedResultsControllerFeelings;
        Photo * firstPhotoForUser = (Photo *)[self.coreDataManager getFirstObjectForEntityName:@"Photo" matchingPredicate:[NSPredicate predicateWithFormat:@"user == %@", currentUserLocal] usingSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO]]];
        [feelingViewController setFocusToUser:currentUserLocal photo:firstPhotoForUser];
        [feelingViewController setShouldAnimateIn:YES fromSource:PhotosStripUnrelated withPersistentImage:nil];
        feelingViewController.galleryScreenshot = self.galleryScreenshot;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.contentView.alpha = 0.0;
            self.addPhotoLabel.alpha = 0.0;
            [self.topBar hideButtonInPosition:LeftSpecial animated:NO];
        } completion:^(BOOL finished){
            [self.delegate photosStripViewController:self requestedReplacementWithPhotosStripViewController:feelingViewController];
        }];
        
    }
        
}

- (void)accountViewController:(AccountViewController *)accountViewController didFinishWithConnection:(BOOL)finishedWithConnection {
    [self dismissModalViewControllerAnimated:YES];
    if (finishedWithConnection) {
        UIAlertView * loggedInAlertView = [[UIAlertView alloc] initWithTitle:@"Logged In" message:@"Have fun expressing yourself!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [loggedInAlertView show];
    }
}

- (void)settingsButtonTouched:(UIButton *)button {
    NSLog(@"Settings button touched...");
    SettingsViewController * settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    settingsViewController.delegate = self;
    settingsViewController.coreDataManager = self.coreDataManager;
    settingsViewController.userServer = [PFUser currentUser];
    User * currentUserLocal = (User *)[self.coreDataManager getFirstObjectForEntityName:@"User" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", settingsViewController.userServer.objectId] usingSortDescriptors:nil];
    settingsViewController.userLocal = currentUserLocal;
    UINavigationController * settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsNavController.navigationBarHidden = YES;
    [self presentModalViewController:settingsNavController animated:YES];
}

- (void) settingsViewControllerFinished:(SettingsViewController *)settingsViewController {
    [self dismissModalViewControllerAnimated:YES];
}

@end
