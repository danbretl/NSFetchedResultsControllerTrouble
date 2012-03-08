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
#import "CameraOverlayView.h"
#import <Parse/Parse.h>

@interface GalleryViewController()
@property (strong, nonatomic) IBOutlet UITableView * feelingsTableView;
- (void) emotishLogoTouched:(UIButton *)button;
- (void) profileButtonTouched:(UIButton *)button;
- (IBAction)addPhotoButtonTouched:(id)sender;
- (void)tableView:(UITableView *)tableView configureCell:(GalleryFeelingCell *)feelingCell atIndexPath:(NSIndexPath *)indexPath;
//@property (strong, nonatomic) UIImage * galleryScreenshot;
//@property (strong, nonatomic, readonly) UIImage * galleryScreenshotCurrent;
- (void) getFeelingsFromServerCallback:(NSArray *)results error:(NSError *)error;
- (void) getPhotosFromServerForFeeling:(Feeling *)feeling;
- (void) getPhotosFromServerForFeelingCallback:(NSArray *)results error:(NSError *)error;
- (void)showSettingsViewControllerForUserLocal:(User *)userLocal userServer:(PFUser *)userServer;
//- (void) updateConfigureVisibleCells;
- (void) showPhotosStripViewControllerFocusedOnUser:(User *)user photo:(Photo *)photo updatePhotoData:(BOOL)updatePhotoData animated:(BOOL)animated; // The parameter updatePhotoData is currently ignored. Need to come up with a better solution later.
- (void) navToRoot;
@end

@implementation GalleryViewController

@synthesize coreDataManager=_coreDataManager;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize feelingsTableView=_feelingsTableView;
@synthesize feelingsTableViewContentOffsetPreserved=_feelingsTableViewContentOffsetPreserved;
@synthesize activeFeelingCell=_activeFeelingCell;
@synthesize activeFeelingCellIndexRow=_activeFeelingCellIndexRow;
@synthesize activeFeelingCellContentOffsetPreserved=_activeFeelingCellContentOffsetPreserved;
@synthesize flagStretchView = _flagStretchView, flagStretchViewTransitions=_flagStretchViewTransitions;
@synthesize floatingImageView=_floatingImageView;
@synthesize topBar=_topBar;
@synthesize bottomBar = _bottomBar;
@synthesize addPhotoButton = _addPhotoButton;
//@synthesize galleryScreenshot=_galleryScreenshot;

//- (void) changeColor:(NSTimer *)timer {
//    if ([self.topBar.backgroundView.backgroundColor isEqual:[UIColor whiteColor]]) {
//        self.topBar.backgroundView.backgroundColor = [UIColor blackColor];
//    } else {
//        self.topBar.backgroundView.backgroundColor = [UIColor whiteColor];
//    }
//}
//
//- (void) animateTopBar {
//    self.topBar.backgroundView.image = nil;
//    NSTimer * timer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(changeColor:) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
////    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionRepeat animations:^{
////        NSLog(@"animateTopBar");
////        self.topBar.backgroundView.backgroundColor = whiteBool ? [UIColor whiteColor] : [UIColor blackColor];
////        whiteBool = !whiteBool;
////        NSLog(@"animateTopBar");
////    } completion:NULL];
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        debugging = NO;
        self.feelingsTableViewContentOffsetPreserved = CGPointMake(0, -VC_TOP_BAR_HEIGHT);
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
//    NSLog(@"%@", NSStringFromCGRect(self.addPhotoButton.frame));
//    self.addPhotoButton.frame = CGRectMake(VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_LEFT_EDGE, self.view.frame.size.height - VC_BOTTOM_BAR_HEIGHT - self.addPhotoButton.frame.size.height - VC_ADD_PHOTO_BUTTON_DISTANCE_FROM_BOTTOM_EDGE, self.addPhotoButton.frame.size.width, self.addPhotoButton.frame.size.height);
    
    [self.topBar.buttonBranding addTarget:self action:@selector(emotishLogoTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar showButtonType:ProfileButton inPosition:LeftSpecial animated:NO];
//    NSLog(@"self.topBar.buttonLeftSpecial = %@", self.topBar.buttonLeftSpecial);
    [self.topBar.buttonLeftSpecial addTarget:self action:@selector(profileButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
    self.feelingsTableView.rowHeight = GC_FEELING_IMAGE_SIDE_LENGTH + 2 * GC_FEELING_IMAGE_MARGIN_VERTICAL;
    self.feelingsTableView.contentInset = UIEdgeInsetsMake(VC_TOP_BAR_HEIGHT, 0, GC_FEELING_IMAGE_MARGIN_VERTICAL + VC_BOTTOM_BAR_HEIGHT, 0);
    self.feelingsTableView.scrollsToTop = YES;

    UIView * tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.feelingsTableView.frame.size.width, GC_TABLE_HEADER_VIEW_FLAG_VISIBLE_HEIGHT + GC_FEELING_IMAGE_MARGIN_VERTICAL)];
    
    self.feelingsTableView.tableHeaderView = tableHeaderView;
    
    self.flagStretchView = [[FlagStretchView alloc] initWithFrame:CGRectMake(0, GC_TABLE_HEADER_VIEW_FLAG_VISIBLE_HEIGHT - [UIScreen mainScreen].bounds.size.height, self.feelingsTableView.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.flagStretchView.icon.opacity = 0.75;
    self.flagStretchView.iconDistanceFromBottom = floorf(self.feelingsTableView.rowHeight / 3.0);
    self.flagStretchView.activationDistanceEnd = 2 * self.flagStretchView.iconDistanceFromBottom + self.flagStretchView.icon.frame.size.height;
    self.flagStretchView.angledShapes = NO;
    self.flagStretchView.activationAffectsIcon = YES;
    self.flagStretchView.activationAffectsAlpha = NO;
    [tableHeaderView addSubview:self.flagStretchView];
    
    self.flagStretchViewTransitions = [[FlagStretchView alloc] initWithFrame:CGRectMake(0, 0, self.feelingsTableView.frame.size.width, VC_TOP_BAR_HEIGHT + GC_TABLE_HEADER_VIEW_FLAG_VISIBLE_HEIGHT)];
    self.flagStretchViewTransitions.userInteractionEnabled = NO;
    self.flagStretchViewTransitions.angledShapes = NO;
    self.flagStretchViewTransitions.alpha = 0.0;
    [self.view insertSubview:self.flagStretchViewTransitions belowSubview:self.topBar];
    
    self.floatingImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.floatingImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.floatingImageView belowSubview:self.topBar];
    self.floatingImageView.alpha = 0.0;
    self.floatingImageView.userInteractionEnabled = NO;
    self.floatingImageView.backgroundColor = [UIColor clearColor];
    self.floatingImageView.clipsToBounds = YES;
    
    if (debugging) {
        self.feelingsTableView.backgroundColor = [UIColor greenColor];
    }
    
    NSError * error;
	if (![self.fetchedResultsController performFetch:&error]) {
		// Handle the error appropriately...
		NSLog(@"GalleryViewController - Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    if ([self tableView:self.feelingsTableView numberOfRowsInSection:0] == 0) {
        [self getFeelingsFromServer]; // This will hopefully asynchronously update the table view... The updates may not look too pretty!
    }
    
//    [self animateTopBar];
    
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

- (void)viewDidAppear:(BOOL)animated {
//    NSLog(@"GalleryViewController viewDidAppear");
    [super viewDidAppear:animated];
    self.view.userInteractionEnabled = YES;
//    self.galleryScreenshot = nil;
    for (GalleryFeelingCell * galleryFeelingCell in self.feelingsTableView.visibleCells) {
        for (GalleryFeelingImageCell * galleryFeelingImageCell in galleryFeelingCell.imagesTableView.visibleCells) {
            [galleryFeelingImageCell setHighlightTabVisible:((Photo *)[galleryFeelingCell.photos objectAtIndex:galleryFeelingImageCell.imageIndex]).shouldHighlight.boolValue animated:YES];
        }
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.floatingImageView.alpha = 0.0;
    self.feelingsTableView.alpha = 1.0;
    self.flagStretchViewTransitions.alpha = 0.0;
    self.floatingImageView.userInteractionEnabled = NO;
    self.feelingsTableView.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
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
        [self tableView:tableView configureCell:cell atIndexPath:indexPath];

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

- (void)tableView:(UITableView *)tableView configureCell:(GalleryFeelingCell *)feelingCell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    Feeling * feeling = [self.fetchedResultsController objectAtIndexPath:indexPath];
    feelingCell.feelingLabel.text = feeling.word;//.lowercaseString;
    feelingCell.feelingIndex = indexPath.row;
    feelingCell.photos = feeling.mostRecentPhotos;
    [feelingCell.imagesTableView reloadData];
    
}

- (void) feelingCellSelected:(GalleryFeelingCell *)feelingCell fromImageCell:(GalleryFeelingImageCell *)imageCell {
    
    if (!(self.activeFeelingCell != nil &&
          self.activeFeelingCell.imagesTableView.isTracking) &&
        feelingCell.photos.count > 0) {
        NSLog(@"Feeling button touched, should push view controller for feeling '%@', focused on %@.", feelingCell.feelingLabel.text, imageCell != nil ? [NSString stringWithFormat:@"the image that was located at index %d)",  imageCell.imageIndex] : @"the first image");
            
        // Old behavior, arguably 'slicker' - if a feeling cell is pulled out (and is thus the active feeling cell), but the user then taps the label or image from a different (not pulled out) feeling cell, while that new tapped feeling cell is being pushed to a view controller etc, the old active cell is deactivated (and starts to scroll towards the origin), and the new tapped cell is offically the new active one.
        GalleryFeelingCell * oldActiveFeelingCell = self.activeFeelingCell;
        GalleryFeelingCell * newActiveFeelingCell = feelingCell;
        if (oldActiveFeelingCell != newActiveFeelingCell) {
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
        
        // New behavior, works with my galleryScreenshot technique - in the situation described above, the new tapped feeling cell does not become the new official active cell. In all other situations, it does. (The problem was that the screenshot would be taken before the potentially old active feeling cell was finished scrolling back to its origin, and thus the transition back to the Gallery, whenever that might happen, would not look right.) // GOING BACK to the old 'slicker' behavior, because we are no longer using the ridiculous Gallery Screenshots.
//        GalleryFeelingCell * oldActiveFeelingCell = self.activeFeelingCell;
//        GalleryFeelingCell * newActiveFeelingCell = feelingCell;
//        if (oldActiveFeelingCell != newActiveFeelingCell) {
//            if (oldActiveFeelingCell.imagesTableView.isDecelerating) {
//                NSLog(@"oldActiveFeelingCell.imagesTableView.isDecelerating");
//                [oldActiveFeelingCell.imagesTableView scrollRectToVisible:CGRectMake(0, oldActiveFeelingCell.imagesTableView.contentOffset.y-1, 1, 1) animated:NO];
//            }
//            if (oldActiveFeelingCell.imagesTableView.contentOffset.y <= 0) {
//                self.activeFeelingCell = nil;
//                [oldActiveFeelingCell highlightLabel:NO];
//                self.activeFeelingCell = newActiveFeelingCell;
//                self.activeFeelingCellIndexRow = newActiveFeelingCell.feelingIndex;
//                [self.activeFeelingCell highlightLabel:YES];
//            }
//        }
    
        if (imageCell == nil) {   
            imageCell = [feelingCell.imagesTableView.visibleCells objectAtIndex:0];
        }
        
        PhotosStripViewController * feelingStripViewController = [[PhotosStripViewController alloc] initWithNibName:@"PhotosStripViewController" bundle:[NSBundle mainBundle]];
        feelingStripViewController.delegate = self;
        feelingStripViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        feelingStripViewController.coreDataManager = self.coreDataManager;
        feelingStripViewController.fetchedResultsControllerFeelings = self.fetchedResultsController;
        Feeling * feeling = [self.fetchedResultsController objectAtIndexPath:[self.feelingsTableView indexPathForCell:feelingCell]];
        [feelingStripViewController setFocusToFeeling:feeling photo:[feelingCell.photos objectAtIndex:(imageCell != nil ? imageCell.imageIndex : 0)]];
        [feelingStripViewController setShouldAnimateIn:YES fromSource:Gallery withPersistentImage:imageCell.button.imageView.image];
        
//        self.galleryScreenshot = self.galleryScreenshotCurrent;
//        feelingStripViewController.galleryScreenshot = self.galleryScreenshot;
                
        self.floatingImageView.frame = [imageCell.button convertRect:imageCell.button.imageView.frame toView:self.floatingImageView.superview];
        self.floatingImageView.image = imageCell.button.imageView.image;
        self.floatingImageView.alpha = 1.0;
        self.floatingImageView.clipsToBounds = YES;
        imageCell.alpha = 0.0;
        
        if (self.feelingsTableView.contentOffset.y == -self.feelingsTableView.contentInset.top) {
            self.flagStretchViewTransitions.alpha = 1.0;
        }
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.flagStretchViewTransitions.alpha = 1.0;
            self.floatingImageView.frame = /*[self.floatingImageView.superview convertRect:*/CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X, PC_PHOTO_CELL_IMAGE_ORIGIN_Y, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH)/* fromView:nil]*/;
//            NSLog(@"self.floatingImageView.frame = %@", NSStringFromCGRect(self.floatingImageView.frame));
//            NSLog(@"galleryViewController.view.frame = %@", NSStringFromCGRect(self.view.frame));
            self.feelingsTableView.alpha = 0.0;
            self.floatingImageView.userInteractionEnabled = YES;
            self.feelingsTableView.userInteractionEnabled = NO;
        } completion:^(BOOL finished){
            [self.navigationController pushViewController:feelingStripViewController animated:NO];
            imageCell.alpha = 1.0;
        }];
    
    }
    
}

//- (void) updateConfigureVisibleCells {
//    NSLog(@"updateConfigureVisibleCells");
//    NSArray * visibleCells = self.feelingsTableView.visibleCells;
//    NSArray * visibleIndexPaths = self.feelingsTableView.indexPathsForVisibleRows;
//    for (int i=0; i<visibleCells.count; i++) {
//        [self tableView:self.feelingsTableView configureCell:[visibleCells objectAtIndex:i] atIndexPath:[visibleIndexPaths objectAtIndex:i]];
//    }
//}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.feelingsTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSLog(@"GalleryViewController controller:didChangeObject:");
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.feelingsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Need to update feelingIndex for visible cells
//            [self updateConfigureVisibleCells];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.feelingsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Need to update feelingIndex for visible cells
//            [self updateConfigureVisibleCells];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self tableView:self.feelingsTableView configureCell:(GalleryFeelingCell *)[self.feelingsTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.feelingsTableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.feelingsTableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.feelingsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.feelingsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.feelingsTableView endUpdates];
}

- (void)photosStripViewControllerFinished:(PhotosStripViewController *)photosStripViewController withNoMorePhotos:(BOOL)noMorePhotos {
    if (noMorePhotos && photosStripViewController.focus == FeelingFocus) {
        photosStripViewController.feelingFocus.word = photosStripViewController.feelingFocus.word; // Touch the Feeling object so that the Gallery's fetched results controller is notified of the Photo delete and the potential resulting disappearance of the Feeling (if it was the last visible Photo for the Feeling)
    }
    
    self.floatingImageView.alpha = 1.0;
    self.floatingImageView.image = photosStripViewController.floatingImageView.image;
    self.floatingImageView.frame = CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X, PC_PHOTO_CELL_IMAGE_ORIGIN_Y, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH);
    
    photosStripViewController.floatingImageView.alpha = 0.0;
    
    CABasicAnimation * floatingSizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    floatingSizeAnimation.duration = 0.25;
    floatingSizeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CGRect oldBounds = self.floatingImageView.layer.bounds;
    CGRect newBounds = CGRectInset(oldBounds, 0.1 * oldBounds.size.width, 0.1 * oldBounds.size.height);
    floatingSizeAnimation.fromValue = [NSValue valueWithCGRect:oldBounds];
    floatingSizeAnimation.toValue = [NSValue valueWithCGRect:newBounds];
    [self.floatingImageView.layer addAnimation:floatingSizeAnimation forKey:@"bounds"];
    self.floatingImageView.layer.bounds = newBounds;
    
    CABasicAnimation * floatingAlphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    floatingAlphaAnimation.duration = 0.25;
    floatingAlphaAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    floatingAlphaAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    floatingAlphaAnimation.toValue = [NSNumber numberWithFloat:0.0];
    [self.floatingImageView.layer addAnimation:floatingAlphaAnimation forKey:@"opacity"];
    self.floatingImageView.layer.opacity = 0.0;
    
    CATransition * viewTransition = [CATransition animation];
    viewTransition.duration = 0.25;
    viewTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    viewTransition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:viewTransition forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
    
//    [self dismissModalViewControllerAnimated:YES];
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
        GalleryFeelingCell * cell = (GalleryFeelingCell *)scrollView.superview.superview; // Totally unsafe, based on insider knowledge that might become untrue at some point.
        if (cell.flagStretchView.activated) {
            [self getPhotosFromServerForFeeling:[self.fetchedResultsController objectAtIndexPath:[self.feelingsTableView indexPathForCell:cell]]];
        }
    } else {
        if (self.flagStretchView.activated) {
            [self getFeelingsFromServer];
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
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY photos.hidden == NO"];
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"foo == YES"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"word" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    fetchRequest.fetchBatchSize = 20;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreDataManager.managedObjectContext sectionNameKeyPath:nil cacheName:@"Gallery"];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)emotishLogoTouched:(UIButton *)button {
    if ([self tableView:self.feelingsTableView numberOfRowsInSection:0] > 0) {
        [self.feelingsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    } else {
        [self.feelingsTableView setContentOffset:CGPointMake(0, -(VC_TOP_BAR_HEIGHT + GC_FEELING_IMAGE_MARGIN_VERTICAL)) animated:YES];
    }
}

- (void)showSettingsViewControllerForUserLocal:(User *)userLocal userServer:(PFUser *)userServer {
    NSLog(@"Settings button touched...");
    SettingsViewController * settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    settingsViewController.delegate = self;
    settingsViewController.coreDataManager = self.coreDataManager;
    UINavigationController * settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsNavController.navigationBarHidden = YES;
    [self presentModalViewController:settingsNavController animated:YES];
}

- (void) settingsViewControllerFinished:(SettingsViewController *)settingsViewController {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)profileButtonTouched:(UIButton *)button {
    NSLog(@"profileButtonTouched");
    PFUser * currentUser = [PFUser currentUser];
    User * currentUserLocal = currentUser == nil ? nil : (User *)[self.coreDataManager getFirstObjectForEntityName:@"User" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", currentUser.objectId]  usingSortDescriptors:nil];
    if (currentUser == nil) {
        AccountViewController * accountViewController = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:[NSBundle mainBundle]];
        accountViewController.delegate = self;
        accountViewController.coreDataManager = self.coreDataManager;
        accountViewController.swipeDownToCancelEnabled = YES;
        [self presentModalViewController:accountViewController animated:YES];
    } else {
        if (!currentUserLocal.photosVisibleExist.boolValue) {
            [self showSettingsViewControllerForUserLocal:currentUserLocal userServer:currentUser];
        } else {
            [self showPhotosStripViewControllerFocusedOnUser:currentUserLocal photo:nil updatePhotoData:NO animated:YES];
        }
    }
}

- (void) showPhotosStripViewControllerFocusedOnUser:(User *)user photo:(Photo *)photo updatePhotoData:(BOOL)updatePhotoData animated:(BOOL)animated {
    PhotosStripViewController * feelingStripViewController = [[PhotosStripViewController alloc] initWithNibName:@"PhotosStripViewController" bundle:[NSBundle mainBundle]];
    feelingStripViewController.delegate = self;
    feelingStripViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    feelingStripViewController.coreDataManager = self.coreDataManager;
    feelingStripViewController.fetchedResultsControllerFeelings = self.fetchedResultsController;
    Photo * photoFocus = photo != nil ? photo : (Photo *)[self.coreDataManager getFirstObjectForEntityName:@"Photo" matchingPredicate:[NSPredicate predicateWithFormat:@"user == %@ && hidden == NO", user] usingSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO]]];
    [feelingStripViewController setFocusToUser:user photo:photoFocus];
    [feelingStripViewController setShouldAnimateIn:animated fromSource:Gallery withPersistentImage:nil];
//    self.galleryScreenshot = self.galleryScreenshotCurrent;
//    feelingStripViewController.galleryScreenshot = self.galleryScreenshot;
    
    self.feelingsTableView.userInteractionEnabled = NO;
    
    if (self.feelingsTableView.contentOffset.y == -self.feelingsTableView.contentInset.top) {
        self.flagStretchViewTransitions.alpha = 1.0;
    }
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.feelingsTableView.alpha = 0.0;
            self.flagStretchViewTransitions.alpha = 1.0;
        } completion:^(BOOL finished){
            [self.navigationController pushViewController:feelingStripViewController animated:NO];
//            if (updatePhotoData) {
//                [feelingStripViewController getUpdateFromServerForPhoto:photoFocus];
//            }
        }];
    } else {
        [self.navigationController pushViewController:feelingStripViewController animated:NO];
//        if (updatePhotoData) {
//            [feelingStripViewController getUpdateFromServerForPhoto:photoFocus];
//        }
    }

}

- (void)accountViewController:(AccountViewController *)accountViewController didFinishWithConnection:(BOOL)finishedWithConnection viaConnectMethod:(AccountConnectMethod)connectMethod {
    [self dismissModalViewControllerAnimated:YES];
    if (finishedWithConnection) {
        UIAlertView * loggedInAlertView = [[UIAlertView alloc] initWithTitle:@"Logged In" message:@"Have fun expressing yourself!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [loggedInAlertView show];
    }
}

- (IBAction)addPhotoButtonTouched:(id)sender {
//    self.galleryScreenshot = self.galleryScreenshotCurrent;
    SubmitPhotoViewController * submitPhotoViewController = [[SubmitPhotoViewController alloc] initWithNibName:@"SubmitPhotoViewController" bundle:[NSBundle mainBundle]];
    submitPhotoViewController.shouldPushImagePicker = YES;
    submitPhotoViewController.delegate = self;
    submitPhotoViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    submitPhotoViewController.coreDataManager = self.coreDataManager;
    [self presentModalViewController:submitPhotoViewController animated:NO];
}

- (void)submitPhotoViewControllerDidCancel:(SubmitPhotoViewController *)submitPhotoViewController {
    NSLog(@"submitPhotoViewControllerDidCancel");
    [self dismissModalViewControllerAnimated:NO];
}

- (void)submitPhotoViewController:(SubmitPhotoViewController *)submitPhotoViewController didSubmitPhoto:(Photo *)photo withImage:(UIImage *)image {
    
    NSLog(@"submitPhotoViewControllerDidSubmitPhoto");

    PhotosStripViewController * feelingStripViewController = [[PhotosStripViewController alloc] initWithNibName:@"PhotosStripViewController" bundle:[NSBundle mainBundle]];
    feelingStripViewController.delegate = self;
    feelingStripViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    feelingStripViewController.coreDataManager = self.coreDataManager;
    feelingStripViewController.fetchedResultsControllerFeelings = self.fetchedResultsController;
    [feelingStripViewController setFocusToFeeling:photo.feeling photo:photo];
    [feelingStripViewController setShouldAnimateIn:YES fromSource:SubmitPhoto withPersistentImage:image];
//    feelingStripViewController.galleryScreenshot = self.galleryScreenshot; // This might not work... It's an old screenshot.
    
    [self navToRoot];
    [self.navigationController pushViewController:feelingStripViewController animated:NO];
//    self.galleryScreenshot = feelingStripViewController.galleryScreenshot;
    
}

//- (UIImage *) galleryScreenshotCurrent {
//    // Render the view layer of this view controller, for fading back to it from other views
//    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
//        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
//    } else {
//        UIGraphicsBeginImageContext(self.view.bounds.size);
//    }
//    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}



- (void)getFeelingsFromServer {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"%@", NSStringFromSelector(_cmd));
    PFQuery * feelingsQuery = [PFQuery queryWithClassName:@"Feeling"];
    feelingsQuery.limit = [NSNumber numberWithInt:500];
    [feelingsQuery findObjectsInBackgroundWithTarget:self selector:@selector(getFeelingsFromServerCallback:error:)];
}

- (void)getFeelingsFromServerCallback:(NSArray *)results error:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (!error) {
        NSLog(@"Success - %d results", results.count);
        for (PFObject * feelingServer in results) {
            Feeling * feeling = [self.coreDataManager addOrUpdateFeelingFromServer:feelingServer];
            [self getPhotosFromServerForFeeling:feeling];
        }
        [self.coreDataManager saveCoreData];
    } else {
        NSLog(@"Network Connection Error: %@ %@", error, error.userInfo);
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"There was an error contacting the server. This is not yet being handled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
}

// THIS METHOD IS DUPLICATED IN VARIOUS PLACES
- (void)getPhotosFromServerForFeeling:(Feeling *)feeling {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"%@", NSStringFromSelector(_cmd));
    PFQuery * photosQuery = [PFQuery queryWithClassName:@"Photo"];
    PFObject * feelingServer = [PFObject objectWithClassName:@"Feeling"];
    feelingServer.objectId = feeling.serverID;
    [photosQuery whereKey:@"feeling" equalTo:feelingServer];
//    [photosQuery whereKey:@"flagged" notEqualTo:[NSNumber numberWithBool:YES]];
//    [photosQuery whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    photosQuery.limit = [NSNumber numberWithInt:100]; // This should be much smaller eventually. But currently this is the only place where we are loading Photos, so, gotta keep it big! Just testing.
    [photosQuery orderByDescending:@"createdAt"];
    [photosQuery includeKey:@"feeling"];
    [photosQuery includeKey:@"user"];
    [photosQuery findObjectsInBackgroundWithTarget:self selector:@selector(getPhotosFromServerForFeelingCallback:error:)];
}

// THIS METHOD IS DUPLICATED IN VARIOUS PLACES
- (void)getPhotosFromServerForFeelingCallback:(NSArray *)results error:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (!error) {
        NSLog(@"getPhotosFromServerForFeelingCallback - Success - %d results", results.count);
        for (PFObject * photoServer in results) {
            PFObject * feelingServer = [photoServer objectForKey:@"feeling"];
            PFObject * userServer = [photoServer objectForKey:@"user"];
            [self.coreDataManager addOrUpdatePhotoFromServer:photoServer feelingFromServer:feelingServer userFromServer:userServer];
        }
        [self.coreDataManager saveCoreData];
    } else {
        NSLog(@"getPhotosFromServerForFeelingCallback - Network Connection Error: %@ %@", error, error.userInfo);
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"There was an error contacting the server. This is not yet being handled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
}

- (void) navToRootAndShowUserStripViewControllerForPhotoWithServerID:(NSString *)photoServerID {
    
    self.navigationController.visibleViewController.view.userInteractionEnabled = NO;
    
    Photo * photoLocal = (Photo *)[self.coreDataManager getFirstObjectForEntityName:@"Photo" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", photoServerID] usingSortDescriptors:nil];
    if (photoLocal != nil &&
        photoLocal.user != nil &&
        photoLocal.feeling != nil) {
        [self navToRoot];
        [self showPhotosStripViewControllerFocusedOnUser:photoLocal.user photo:photoLocal updatePhotoData:YES animated:NO];
        self.navigationController.visibleViewController.view.userInteractionEnabled = YES;
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        PFQuery * photoQuery = [PFQuery queryWithClassName:@"Photo"];
        [photoQuery includeKey:@"user"];
        [photoQuery includeKey:@"feeling"];
        [photoQuery getObjectInBackgroundWithId:photoServerID block:^(PFObject * object, NSError * error){
            if (!error && object != nil) {
                PFObject * userServer = [object objectForKey:@"user"];
                PFObject * feelingServer = [object objectForKey:@"feeling"];
                Photo * photoLocalFromRetrieved = (Photo *)[self.coreDataManager addOrUpdatePhotoFromServer:object feelingFromServer:feelingServer userFromServer:userServer];
                [self.coreDataManager saveCoreData];
                [self navToRoot];
                [self showPhotosStripViewControllerFocusedOnUser:photoLocalFromRetrieved.user photo:photoLocalFromRetrieved updatePhotoData:YES animated:NO];
            } else {
                UIAlertView * photoTroubleAlertView = [[UIAlertView alloc] initWithTitle:@"Hmmm..." message:@"Something went wrong, and we can't seem to find that particular Photo right now. Sorry! We'll work on this." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [photoTroubleAlertView show];
            }
            self.navigationController.visibleViewController.view.userInteractionEnabled = YES;
        }];
    }
        
}

- (void) navToRoot {
    
    self.floatingImageView.alpha = 0.0;
    self.feelingsTableView.alpha = 1.0;
    self.floatingImageView.userInteractionEnabled = NO;
    self.feelingsTableView.userInteractionEnabled = YES;
    
    if (self.modalViewController != nil) {
        [self.modalViewController.navigationController popToRootViewControllerAnimated:NO];
        [self dismissModalViewControllerAnimated:NO];
    }
    if (self.navigationController.visibleViewController != self) {
        if (self.navigationController.visibleViewController.modalViewController != nil) {
            [self.navigationController.visibleViewController.modalViewController.navigationController popToRootViewControllerAnimated:NO]; // THIS IS RIDICULOUS...
            [self.navigationController.visibleViewController dismissModalViewControllerAnimated:NO];
        }
    }

    [self.navigationController popToRootViewControllerAnimated:NO];
    self.view.userInteractionEnabled = YES;
    
}

@end
