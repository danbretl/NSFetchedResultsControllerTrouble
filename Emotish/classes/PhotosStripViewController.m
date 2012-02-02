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

const CGFloat PSVC_LABELS_ANIMATION_EXTRA_DISTANCE_OFFSCREEN = 10.0;
const int PSVC_PHOTO_VIEWS_COUNT = 5;

@interface PhotosStripViewController()
@property (nonatomic) PhotosStripFocus focus;
@property (strong, nonatomic) Feeling * feelingFocus;
@property (strong, nonatomic) User * userFocus;
@property (strong, nonatomic) Photo * photoInView;
@property (strong, nonatomic, readonly) NSFetchedResultsController * fetchedResultsControllerForCurrentFocus;
- (NSFetchedResultsController *)fetchedResultsControllerForFocus:(PhotosStripFocus)focus;
- (void) performFetchForCurrentFocus;
- (void) updateViewsForCurrentFocus;
- (void) reloadPhotoViewsFocusedOnPhoto:(Photo *)photo;
- (void) reloadPhotoView:(PhotoView *)photoView givenFocusOnIndexPath:(NSIndexPath *)centerIndexPath;
- (void) updatePhotoViewCaption:(PhotoView *)photoView withDataFromPhoto:(Photo *)photo oppositeOfFocus:(PhotosStripFocus)mainViewDataFocus;
- (void) pinchedToZoomOut:(UIPinchGestureRecognizer *)pinchGestureRecognizer;
- (void) tappedToSelectPhotoView:(UITapGestureRecognizer *)tapGestureRecognizer;
- (void)photoInView:(Photo *)photo selectedFromPhotoView:(PhotoView *)photoView;
- (IBAction)headerButtonTouched:(UIButton *)button;
@property (nonatomic) BOOL shouldAnimateIn;
@property (nonatomic) PhotosStripAnimationInSource animationInSource;
@property (strong, nonatomic) UIImage * animationInPersistentImage;
@end

@implementation PhotosStripViewController
@synthesize focus=_focus;
@synthesize feelingFocus=_feelingFocus, userFocus=_userFocus, photoInView=_photoInView;
@synthesize shouldAnimateIn=_shouldAnimateIn, animationInSource=_animationInSource, animationInPersistentImage=_animationInPersistentImage;
@synthesize coreDataManager=_coreDataManager;
@synthesize fetchedResultsControllerFeeling=_fetchedResultsControllerFeeling;
@synthesize fetchedResultsControllerUser=_fetchedResultsControllerUser;
@synthesize fetchedResultsControllerForCurrentFocus=_fetchedResultsControllerForCurrentFocus;
@synthesize topBar=_topBar;
@synthesize headerButton=_headerButton;
@synthesize photosClipView = _photosClipView;
@synthesize photosScrollView=_photosScrollView;
@synthesize photosContainer = _photosContainer;
@synthesize photoViewLeftmost = _photoViewLeftmost;
@synthesize photoViewLeftCenter = _photoViewLeftCenter;
@synthesize photoViewCenter = _photoViewCenter;
@synthesize photoViewRightCenter = _photoViewRightCenter;
@synthesize photoViewRightmost = _photoViewRightmost;
@synthesize floatingImageView=_floatingImageView;
@synthesize addPhotoLabel = _addPhotoLabel;
@synthesize zoomOutGestureRecognizer=_zoomOutGestureRecognizer;
@synthesize delegate=_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.focus = NoFocus;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headerButton.titleLabel.adjustsFontSizeToFitWidth = YES;

    self.photosClipView.scrollView = self.photosScrollView;
    self.photosClipView.frame = CGRectMake(0, PC_PHOTO_CELL_IMAGE_ORIGIN_Y, 320, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM + PC_PHOTO_CELL_LABEL_HEIGHT);
    CGFloat photoViewWidth = PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL * 2;
    self.photosScrollView.frame = CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, 0, photoViewWidth, self.photosClipView.frame.size.height);
    self.photosScrollView.scrollsToTop = NO;
    [self.photosScrollView addSubview:self.photosContainer];
    self.photosContainer.frame = CGRectMake(0, 0, PSVC_PHOTO_VIEWS_COUNT * photoViewWidth, self.photosContainer.frame.size.height);
    self.photosScrollView.contentSize = self.photosContainer.frame.size;
    UITapGestureRecognizer * tapToSelectPhotoViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToSelectPhotoView:)];
    [self.photosScrollView addGestureRecognizer:tapToSelectPhotoViewGestureRecognizer];
    self.photosClipView.backgroundColor = [UIColor whiteColor];
    
    self.headerButton.frame = CGRectMake(0, 0, 320, CGRectGetMinY(self.photosClipView.frame));
    self.headerButton.contentEdgeInsets = UIEdgeInsetsMake(0, self.photosScrollView.frame.origin.x + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, self.headerButton.contentEdgeInsets.bottom, 320 - (CGRectGetMaxX(self.photosScrollView.frame) - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL));
    
    self.floatingImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.floatingImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.floatingImageView belowSubview:self.topBar];
    self.floatingImageView.alpha = 0.0;
    self.floatingImageView.userInteractionEnabled = NO;
    self.floatingImageView.backgroundColor = [UIColor clearColor];
//    UITapGestureRecognizer * floatingImageViewTempTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(floatingImageViewTouched:)];
//    [self.floatingImageView addGestureRecognizer:floatingImageViewTempTapGestureRecognizer];
    
    [self updateViewsForCurrentFocus];
    
    self.zoomOutGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchedToZoomOut:)];
    [self.view addGestureRecognizer:self.zoomOutGestureRecognizer];
    
    BOOL debugging = NO;
    if (debugging) {
        self.photosScrollView.backgroundColor = [UIColor redColor];
    }

}

- (void)viewDidUnload
{
    [self setHeaderButton:nil];
    [self setPhotosScrollView:nil];
    self.floatingImageView = nil;
    self.fetchedResultsControllerFeeling = nil;
    self.fetchedResultsControllerUser = nil;
    [self setTopBar:nil];
    [self setAddPhotoLabel:nil];
    [self setPhotosContainer:nil];
    [self setPhotoViewLeftmost:nil];
    [self setPhotoViewLeftCenter:nil];
    [self setPhotoViewCenter:nil];
    [self setPhotoViewRightCenter:nil];
    [self setPhotoViewRightmost:nil];
    [self setPhotosClipView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.shouldAnimateIn) {
        
        self.floatingImageView.frame = CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X, PC_PHOTO_CELL_IMAGE_ORIGIN_Y, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH);
        self.floatingImageView.image = self.animationInPersistentImage;
        self.floatingImageView.alpha = 1.0;
        self.addPhotoLabel.alpha = 0.0;
        self.view.userInteractionEnabled = NO;
        self.photoViewLeftCenter.alpha = 0.0;
        self.photoViewRightCenter.alpha = 0.0;
        
        if (self.animationInSource == Gallery) {
            
            self.headerButton.alpha = 0.0;
            self.photoViewCenter.alpha = 0.0;
            
        } else if (self.animationInSource == PhotosStripOpposite) {
            
            CGRect headerFrame = self.headerButton.frame;
            CGRect captionFrame = self.photoViewCenter.photoCaptionLabel.frame;
            CGFloat headerTextWidth = MIN([self.headerButton.titleLabel.text sizeWithFont:self.headerButton.titleLabel.font].width, self.headerButton.frame.size.width - (self.headerButton.contentEdgeInsets.left + self.headerButton.contentEdgeInsets.right));
            CGFloat captionTextWidth = MIN([self.photoViewCenter.photoCaptionLabel.text sizeWithFont:self.photoViewCenter.photoCaptionLabel.font].width, self.photoViewCenter.photoCaptionLabel.frame.size.width);
            CGRect headerOffscreenFrame = CGRectMake(-(self.headerButton.contentEdgeInsets.left + headerTextWidth + PSVC_LABELS_ANIMATION_EXTRA_DISTANCE_OFFSCREEN), headerFrame.origin.y, headerFrame.size.width, headerFrame.size.height);
            CGPoint offscreenPointToCaptionLabel = [self.photoViewCenter.photoCaptionLabel.superview convertPoint:CGPointMake(self.view.frame.size.width, 0) fromView:self.view];
            CGRect captionOffscreenFrame = CGRectMake(offscreenPointToCaptionLabel.x + PSVC_LABELS_ANIMATION_EXTRA_DISTANCE_OFFSCREEN - (captionFrame.size.width - captionTextWidth), captionFrame.origin.y, captionFrame.size.width, captionFrame.size.height);
            self.headerButton.frame = headerOffscreenFrame;
            self.photoViewCenter.photoCaptionLabel.frame = captionOffscreenFrame;
            
        }
        
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.shouldAnimateIn) {
        
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.addPhotoLabel.alpha = 1.0;
            self.photoViewLeftCenter.alpha = 1.0;
            self.photoViewRightCenter.alpha = 1.0;
            
            if (self.animationInSource == Gallery) {
                self.headerButton.alpha = 1.0;
                self.photoViewCenter.alpha = 1.0;
            } else if (self.animationInSource == PhotosStripOpposite) {
                CGRect headerFrame = self.headerButton.frame;
                headerFrame.origin.x = 0;
                self.headerButton.frame = headerFrame;
                CGRect captionFrame = self.photoViewCenter.photoCaptionLabel.frame;
                captionFrame.origin.x = self.photoViewCenter.photoImageView.frame.origin.x;
                self.photoViewCenter.photoCaptionLabel.frame = captionFrame;
            }
            
        } completion:^(BOOL finished){
            self.floatingImageView.alpha = 0.0;
            self.view.userInteractionEnabled = YES;
        }];
        
        self.shouldAnimateIn = NO;
        self.animationInSource = NoSource;
        self.animationInPersistentImage = nil;
        
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setFocusToFeeling:(Feeling *)feeling photo:(Photo *)photo {
    self.focus = FeelingFocus;
    self.feelingFocus = feeling;
    self.photoInView = photo;
    if (self.view.window) {
        [self updateViewsForCurrentFocus];
    }
//    NSLog(@"Should scroll to photo %@", photo);
}

- (void)setFocusToUser:(User *)user photo:(Photo *)photo {
    self.focus = UserFocus;
    self.userFocus = user;
    self.photoInView = photo;
    if (self.view.window) {
        [self updateViewsForCurrentFocus];
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
        headerString = self.feelingFocus.word.lowercaseString;
        headerColor = [UIColor feelingColor];
        addPhotoString = [NSString stringWithFormat:@"Do you feel %@?", self.feelingFocus.word.lowercaseString];
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
    photoView.photoImageView.image = photo == nil ? nil : [UIImage imageNamed:photo.filename];
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
            captionText = photo.feeling.word.lowercaseString;
            captionColor = [UIColor feelingColor];
        }
    }
    photoView.photoCaptionLabel.text = captionText;
    photoView.photoCaptionLabel.textColor = captionColor;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat contentOffsetToMiddleX = scrollView.contentOffset.x + (scrollView.frame.size.width / 2.0);
    contentOffsetToMiddleX = MAX(contentOffsetToMiddleX, 0);
    contentOffsetToMiddleX = MIN(contentOffsetToMiddleX, self.photosScrollView.contentSize.width - self.photosScrollView.frame.size.width);
    NSUInteger indexOfPhotoInView = (int)contentOffsetToMiddleX / (int)self.photosScrollView.frame.size.width;
    Photo * photoInView = [self.fetchedResultsControllerForCurrentFocus objectAtIndexPath:[NSIndexPath indexPathForRow:indexOfPhotoInView inSection:0]];
    if (!decelerate) {
        self.photoInView = photoInView;
    }
    [self reloadPhotoViewsFocusedOnPhoto:photoInView];
//    self.photoInView = [self.fetchedResultsControllerForCurrentFocus objectAtIndexPath:[NSIndexPath indexPathForRow:indexOfPhotoInView inSection:0]];
//    [self reloadPhotoViewsFocusedOnPhoto:self.photoInView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger indexOfPhotoInView = (int)scrollView.contentOffset.x / (int)self.photosScrollView.frame.size.width;
    self.photoInView = [self.fetchedResultsControllerForCurrentFocus objectAtIndexPath:[NSIndexPath indexPathForRow:indexOfPhotoInView inSection:0]];
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

- (void)pinchedToZoomOut:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    NSLog(@"pinchedToZoomOut");
    [self.delegate photosStripViewControllerFinished:self];
}

- (void)tappedToSelectPhotoView:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint locationInScrollView = [tapGestureRecognizer locationInView:self.photosScrollView];
    if (CGRectContainsPoint(CGRectInset(self.photosScrollView.bounds, PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, 0), locationInScrollView)) {
        PhotoView * photoViewTapped = self.photoViewCenter;
        CGPoint locationInPhotosContainer = [tapGestureRecognizer locationInView:self.photosContainer];
        if (CGRectContainsPoint(self.photoViewLeftCenter.frame, locationInPhotosContainer)) {
            photoViewTapped = self.photoViewLeftCenter;
            NSLog(@"self.photoViewLeftCenter");
        } else if (CGRectContainsPoint(self.photoViewRightCenter.frame, locationInPhotosContainer)) {
            photoViewTapped = self.photoViewRightCenter;
            NSLog(@"self.photoViewRightCenter");
        } else {
            NSLog(@"self.photoViewCenter");
        }
        [self photoInView:self.photoInView selectedFromPhotoView:photoViewTapped];
    }
}

- (void)photoInView:(Photo *)photo selectedFromPhotoView:(PhotoView *)photoView {
        
    PhotosStripViewController * oppositeFocusStripViewController = [[PhotosStripViewController alloc] initWithNibName:@"PhotosStripViewController" bundle:[NSBundle mainBundle]];
    oppositeFocusStripViewController.delegate = self.delegate;
    oppositeFocusStripViewController.coreDataManager = self.coreDataManager;
    if (self.focus == FeelingFocus) {
        [oppositeFocusStripViewController setFocusToUser:photo.user photo:photo];
    } else {
        [oppositeFocusStripViewController setFocusToFeeling:photo.feeling photo:photo];
    }
    [oppositeFocusStripViewController setShouldAnimateIn:YES fromSource:PhotosStripOpposite withPersistentImage:photoView.photoImageView.image];

    // Animate the transition
//    CGRect headerFrame = self.headerButton.frame;
//    CGRect captionFrame = photoView.photoCaptionLabel.frame;
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
        CGFloat headerTextLeftEdgeInView = self.headerButton.frame.origin.x + self.headerButton.contentEdgeInsets.left;
        CGFloat captionTextRightEdgeInView = CGRectGetMaxX([self.view convertRect:photoView.frame fromView:photoView.superview]);
        NSLog(@"%f %f", headerTextLeftEdgeInView, captionTextRightEdgeInView);
        self.headerButton.frame = CGRectOffset(self.headerButton.frame, self.headerButton.frame.size.width - headerTextLeftEdgeInView + PSVC_LABELS_ANIMATION_EXTRA_DISTANCE_OFFSCREEN, 0);
        photoView.photoCaptionLabel.frame = CGRectOffset(photoView.photoCaptionLabel.frame, -(captionTextRightEdgeInView + PSVC_LABELS_ANIMATION_EXTRA_DISTANCE_OFFSCREEN), 0);
        void(^photoViewAlpha)(PhotoView *)=^(PhotoView * photoViewInQuestion){
            photoViewInQuestion.alpha = photoView == photoViewInQuestion ? 1.0 : 0.0;
        };
        photoViewAlpha(self.photoViewCenter);
        photoViewAlpha(self.photoViewLeftCenter);
        photoViewAlpha(self.photoViewRightCenter);
        photoViewAlpha(self.photoViewLeftmost);
        photoViewAlpha(self.photoViewRightmost);
        self.addPhotoLabel.alpha = 0.0;
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
    [self.delegate photosStripViewControllerFinished:self];
}

@end
