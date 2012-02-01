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

@interface GalleryViewController()
@property (strong, nonatomic) IBOutlet UITableView * feelingsTableView;
//- (NSString *)imageNameForFeelingIndex:(NSInteger)feelingIndex imageIndex:(NSInteger)imageIndex;
- (void) floatingImageViewTouched:(UITapGestureRecognizer *)tapGestureRecognizer;
@end

@implementation GalleryViewController

@synthesize coreDataManager=_coreDataManager;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize feelingsTableView=_feelingsTableView;
@synthesize feelingsTableViewContentOffsetPreserved=_feelingsTableViewContentOffsetPreserved;
@synthesize activeFeelingCell=_activeFeelingCell;
@synthesize activeFeelingCellIndexRow=_activeFeelingCellIndexRow;
@synthesize activeFeelingCellContentOffsetPreserved=_activeFeelingCellContentOffsetPreserved;
//@synthesize tempFeelingStrings=_tempFeelingStrings;
@synthesize floatingImageView=_floatingImageView;
@synthesize topBar=_topBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        debugging = NO;
        self.feelingsTableViewContentOffsetPreserved = CGPointMake(0, -(VC_TOP_BAR_HEIGHT + GC_FEELING_IMAGE_MARGIN_VERTICAL));
        self.activeFeelingCellIndexRow = -1;
        self.activeFeelingCellContentOffsetPreserved = CGPointZero;
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
//    NSLog(@"GalleryViewController self.view.frame = %@", NSStringFromCGRect(self.view.frame));
    
    self.feelingsTableView.rowHeight = GC_FEELING_IMAGE_SIDE_LENGTH + 2 * GC_FEELING_IMAGE_MARGIN_VERTICAL;
    self.feelingsTableView.contentInset = UIEdgeInsetsMake(VC_TOP_BAR_HEIGHT + GC_FEELING_IMAGE_MARGIN_VERTICAL, 0, GC_FEELING_IMAGE_MARGIN_VERTICAL, 0);
    self.feelingsTableView.scrollIndicatorInsets = UIEdgeInsetsMake(VC_TOP_BAR_HEIGHT + GC_FEELING_IMAGE_MARGIN_VERTICAL * 2, 0, GC_FEELING_IMAGE_MARGIN_VERTICAL * 2, 0);
    self.feelingsTableView.scrollsToTop = YES;
    
    self.floatingImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.floatingImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.floatingImageView belowSubview:self.topBar];
    self.floatingImageView.alpha = 0.0;
    self.floatingImageView.userInteractionEnabled = NO;
    self.floatingImageView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer * floatingImageViewTempTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(floatingImageViewTouched:)];
    [self.floatingImageView addGestureRecognizer:floatingImageViewTempTapGestureRecognizer];
    
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.feelingsTableView.contentOffset = self.feelingsTableViewContentOffsetPreserved;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
        
    }/* else {
        
        // Get / Create the cell
        static NSString * FeelingImageCellID = @"FeelingImageCellID";
        GalleryFeelingImageCell * cell = (GalleryFeelingImageCell *)[tableView dequeueReusableCellWithIdentifier:FeelingImageCellID];
        if (cell == nil) {
            cell = [[GalleryFeelingImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeelingImageCellID];
            cell.delegate = self;
        }
        
        // Configure the cell
        
        // Configure the cell
        Feeling * feeling = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.feelingLabel.text = feeling.word.lowercaseString;
        cell.feelingIndex = indexPath.row;
        [cell.imagesTableView reloadData];
        
        Photo * photo = [
        [cell.button setImage:[UIImage imageNamed:[self imageNameForFeelingIndex:tableView.tag imageIndex:indexPath.row]] forState:UIControlStateNormal];
        cell.feelingIndex = tableView.tag;
        cell.imageIndex = indexPath.row;
        cell.feelingCell = (GalleryFeelingCell *)tableView.superview.superview; // HARD CODED, dangerous.
        
        // Return the cell
        return cell;
        
    }*/
    
    return nil;
    
}

- (void)floatingImageViewTouched:(UITapGestureRecognizer *)tapGestureRecognizer {
    [UIView animateWithDuration:0.25 animations:^{
        self.floatingImageView.alpha = 0.0;
        self.feelingsTableView.alpha = 1.0;
        self.floatingImageView.userInteractionEnabled = NO;
        self.feelingsTableView.userInteractionEnabled = YES;
    }];
}

- (void) feelingCellSelected:(GalleryFeelingCell *)feelingCell fromImageCell:(GalleryFeelingImageCell *)imageCell {
    
    if (!(self.activeFeelingCell != nil &&
          self.activeFeelingCell.imagesTableView.isTracking)) {
        NSLog(@"Feeling button touched, should push view controller for feeling '%@', focused on %@.", feelingCell.feelingLabel.text, imageCell != nil ? [NSString stringWithFormat:@"the image that was located at index %d)",  imageCell.imageIndex] : @"the first image");
        if (imageCell != nil) {
            
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
            
            PhotosStripViewController * feelingStripViewController = [[PhotosStripViewController alloc] initWithNibName:@"PhotosStripViewController" bundle:[NSBundle mainBundle]];
            feelingStripViewController.delegate = self;
            feelingStripViewController.coreDataManager = self.coreDataManager;
            Feeling * feeling = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:feelingCell.feelingIndex inSection:0]];
            [feelingStripViewController setFocusToFeeling:feeling photo:[feelingCell.photos objectAtIndex:(imageCell != nil ? imageCell.imageIndex : 0)]];
            
            self.floatingImageView.frame = [imageCell.button convertRect:imageCell.button.imageView.frame toView:self.floatingImageView.superview];
            self.floatingImageView.image = imageCell.button.imageView.image;
            self.floatingImageView.alpha = 1.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                self.floatingImageView.frame = /*[self.floatingImageView.superview convertRect:*/CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X, PC_PHOTO_CELL_IMAGE_ORIGIN_Y, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH)/* fromView:nil]*/;
                NSLog(@"self.floatingImageView.frame = %@", NSStringFromCGRect(self.floatingImageView.frame));
                NSLog(@"galleryViewController.view.frame = %@", NSStringFromCGRect(self.view.frame));
                self.feelingsTableView.alpha = 0.0;
                self.floatingImageView.userInteractionEnabled = YES;
                self.feelingsTableView.userInteractionEnabled = NO;
            } completion:^(BOOL finished){
                [self.navigationController pushViewController:feelingStripViewController animated:NO];
            }];
            
        }
    }
    
}

- (void)photosStripViewControllerFinished:(PhotosStripViewController *)photosStripViewController {
//    [UIView animateWithDuration:0.25 animations:^{
        self.floatingImageView.alpha = 0.0;
        self.feelingsTableView.alpha = 1.0;
        self.floatingImageView.userInteractionEnabled = NO;
        self.feelingsTableView.userInteractionEnabled = YES;
//    }];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)photosStripViewController:(PhotosStripViewController *)photosStripViewController requestedReplacementWithPhotosStripViewController:(PhotosStripViewController *)replacementPhotosStripViewController {
    NSLog(@"photosStripViewController:requestedReplacementWithPhotosStripViewController:");
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController pushViewController:replacementPhotosStripViewController animated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.feelingsTableView) {
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
    }
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

//- (NSArray *)tempFeelingStrings {
//    if (_tempFeelingStrings == nil) {
//        _tempFeelingStrings = [[NSArray arrayWithObjects:@"Content", @"Distracted", @"Lucky", @"Satisfied", @"Aggressive", @"Frustrated", @"Silly", @"Sleepy", @"Excited", @"Too Cool", @"Utter Despair", @"Clever", @"Confused", @"Frantic", @"So Intense", @"Sneaky", @"Vindictive", @"Euphoric", @"Unicorn", @"Unlucky", @"Mellow", @"Desperate", @"Pouting", @"Happy", @"Intrigued", @"Mischievous", @"Mystified", @"Confident", @"Hopeful", @"Pissed Off", @"Disappointed", @"Flabbergasted", @"Meeple", @"On Edge", @"Robotic", @"Thoughtful", @"Bangladesh", @"Hopeless", @"Quixotic", @"Wary", @"Anguish", @"Calm", @"Indifferent", @"Stupid", @"Surprised", @"Tired", @"Astonished", @"Bemused", @"Bored", @"Chaos", @"Delighted", @"Depressed", @"Determined", @"Flummoxed", @"Full", @"Interested", @"Quirky", @"Stressed", @"Triumphant", @"Zen", @"Angry", @"Anxious", nil] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//    }
//    return _tempFeelingStrings;
//}
//
//- (NSString *)imageNameForFeelingIndex:(NSInteger)feelingIndex imageIndex:(NSInteger)imageIndex {
//    return [NSString stringWithFormat:@"protoImage%d.jpg", ((imageIndex + feelingIndex) % 4) + 1];
//}

@end
