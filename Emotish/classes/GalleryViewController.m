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
- (NSString *)imageNameForFeelingIndex:(NSInteger)feelingIndex imageIndex:(NSInteger)imageIndex;
- (void) feelingLabelButtonTouched:(UIButton *)feelingLabelButton;
- (void) feelingImageButtonTouched:(UIButton *)imageButton;
- (void) feelingButtonTouchedWithFeelingIndex:(NSInteger)feelingIndex imageIndex:(NSInteger)imageIndex imageButtonImageViewFrame:(CGRect)imageButtonImageViewFrame;
- (void) floatingImageViewTouched:(UITapGestureRecognizer *)tapGestureRecognizer;
@end

@implementation GalleryViewController

@synthesize feelingsTableView=_feelingsTableView;
@synthesize feelingsTableViewContentOffsetPreserved=_feelingsTableViewContentOffsetPreserved;
@synthesize activeFeelingCell=_activeFeelingCell;
@synthesize activeFeelingCellIndexRow=_activeFeelingCellIndexRow;
@synthesize activeFeelingCellContentOffsetPreserved=_activeFeelingCellContentOffsetPreserved;
@synthesize tempFeelingStrings=_tempFeelingStrings;
@synthesize floatingImageView=_floatingImageView;

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
    NSLog(@"GalleryViewController self.view.frame = %@", NSStringFromCGRect(self.view.frame));
    
    self.feelingsTableView.rowHeight = GC_FEELING_IMAGE_SIDE_LENGTH + 2 * GC_FEELING_IMAGE_MARGIN_VERTICAL;
    self.feelingsTableView.contentInset = UIEdgeInsetsMake(VC_TOP_BAR_HEIGHT + GC_FEELING_IMAGE_MARGIN_VERTICAL, 0, GC_FEELING_IMAGE_MARGIN_VERTICAL, 0);
    self.feelingsTableView.scrollIndicatorInsets = UIEdgeInsetsMake(VC_TOP_BAR_HEIGHT + GC_FEELING_IMAGE_MARGIN_VERTICAL * 2, 0, GC_FEELING_IMAGE_MARGIN_VERTICAL * 2, 0);
    
    self.floatingImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.floatingImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.floatingImageView];
    self.floatingImageView.alpha = 0.0;
    self.floatingImageView.userInteractionEnabled = NO;
    self.floatingImageView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer * floatingImageViewTempTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(floatingImageViewTouched:)];
    [self.floatingImageView addGestureRecognizer:floatingImageViewTempTapGestureRecognizer];
    
    if (debugging) {
        self.feelingsTableView.backgroundColor = [UIColor greenColor];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.feelingsTableView = nil;
    self.activeFeelingCell = nil; // Not retained, but should nil this pointer.
    self.floatingImageView = nil;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView == self.feelingsTableView ? self.tempFeelingStrings.count : 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.feelingsTableView) {
        
        NSLog(@"feelingCell forIndexPath.row:%d", indexPath.row);
        
        // Get / Create the cell
        static NSString * FeelingCellID = @"FeelingCellID";
        GalleryFeelingCell * cell = (GalleryFeelingCell *)[tableView dequeueReusableCellWithIdentifier:FeelingCellID];
        if (cell == nil) {
            NSLog(@"Brand new cell");
            cell = [[GalleryFeelingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeelingCellID];
            cell.imagesTableView.delegate = self;
            cell.imagesTableView.dataSource = self;
            [cell.feelingLabelButton addTarget:self action:@selector(feelingLabelButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            NSLog(@"Dequeued cell with old imagesTableView.tag=%d (%@, %@)", cell.imagesTableView.tag, cell.feelingLabel.text, NSStringFromCGPoint(cell.imagesTableView.contentOffset));
            if (cell.feelingIndex == self.activeFeelingCellIndexRow) {
                NSLog(@"Dequeued cell was the activeFeelingCell, preserving its content offset, and setting the activeFeelingCell object to nil.");
                self.activeFeelingCellContentOffsetPreserved = cell.imagesTableView.contentOffset;
                self.activeFeelingCell = nil;
            }
        }
        
        // Configure the cell
        cell.feelingLabel.text = [[self.tempFeelingStrings objectAtIndex:indexPath.row] lowercaseString];
        cell.feelingIndex = indexPath.row;
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
        
    } else {
        
        // Get / Create the cell
        static NSString * FeelingImageCellID = @"FeelingImageCellID";
        GalleryFeelingImageCell * cell = (GalleryFeelingImageCell *)[tableView dequeueReusableCellWithIdentifier:FeelingImageCellID];
        if (cell == nil) {
            cell = [[GalleryFeelingImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeelingImageCellID];
            [cell.button addTarget:self action:@selector(feelingImageButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        // Configure the cell
        [cell.button setImage:[UIImage imageNamed:[self imageNameForFeelingIndex:tableView.tag imageIndex:indexPath.row]] forState:UIControlStateNormal];
        cell.feelingIndex = tableView.tag;
        cell.imageIndex = indexPath.row;
        
        // Return the cell
        return cell;
        
    }
    
}

- (void) feelingButtonTouchedWithFeelingIndex:(NSInteger)feelingIndex imageIndex:(NSInteger)imageIndex imageButtonImageViewFrame:(CGRect)imageButtonImageViewFrame {
    NSLog(@"Feeling button touched, should push view controller for feeling '%@', focused on %@.", [self.tempFeelingStrings objectAtIndex:feelingIndex], imageIndex >= 0 ? [NSString stringWithFormat:@"image with filename '%@' (that was located at index %d)", [self imageNameForFeelingIndex:feelingIndex imageIndex:imageIndex], imageIndex] : @"the first image");
    if (imageIndex >= 0) {
        self.floatingImageView.frame = imageButtonImageViewFrame;
        self.floatingImageView.image = [UIImage imageNamed:[self imageNameForFeelingIndex:feelingIndex imageIndex:imageIndex]];
        self.floatingImageView.alpha = 1.0;
        [UIView animateWithDuration:0.25 animations:^{
            self.floatingImageView.frame = CGRectMake(50, 120, 220, 220);
            self.feelingsTableView.alpha = 0.0;
            self.floatingImageView.userInteractionEnabled = YES;
            self.feelingsTableView.userInteractionEnabled = NO;
        }];
    }
}

- (void)floatingImageViewTouched:(UITapGestureRecognizer *)tapGestureRecognizer {
    [UIView animateWithDuration:0.25 animations:^{
        self.floatingImageView.alpha = 0.0;
        self.feelingsTableView.alpha = 1.0;
        self.floatingImageView.userInteractionEnabled = NO;
        self.feelingsTableView.userInteractionEnabled = YES;
    }];
}

- (void) feelingLabelButtonTouched:(UIButton *)feelingButton {
    [self feelingButtonTouchedWithFeelingIndex:feelingButton.tag imageIndex:-1 imageButtonImageViewFrame:CGRectZero];
}

- (void) feelingImageButtonTouched:(UIButton *)imageButton {
    GalleryFeelingImageCell * cell = (GalleryFeelingImageCell *)imageButton.superview; // HARD CODED! Totally unsafe assumption! Be careful!
    [self feelingButtonTouchedWithFeelingIndex:cell.feelingIndex imageIndex:cell.imageIndex imageButtonImageViewFrame:[imageButton convertRect:imageButton.imageView.frame toView:self.floatingImageView.superview]];
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
                    self.activeFeelingCellIndexRow = newActiveFeelingCell.imagesTableView.tag;
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
        NSLog(@"scrollViewDidEndScrollingAnimation(%d)(%d)", scrollView.tag, self.activeFeelingCell == scrollView.superview.superview);
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

- (NSArray *)tempFeelingStrings {
    if (_tempFeelingStrings == nil) {
        _tempFeelingStrings = [[NSArray arrayWithObjects:@"Content", @"Distracted", @"Lucky", @"Satisfied", @"Aggressive", @"Frustrated", @"Silly", @"Sleepy", @"Excited", @"Too Cool", @"Utter Despair", @"Clever", @"Confused", @"Frantic", @"So Intense", @"Sneaky", @"Vindictive", @"Euphoric", @"Unicorn", @"Unlucky", @"Mellow", @"Desperate", @"Pouting", @"Happy", @"Intrigued", @"Mischievous", @"Mystified", @"Confident", @"Hopeful", @"Pissed Off", @"Disappointed", @"Flabbergasted", @"Meeple", @"On Edge", @"Robotic", @"Thoughtful", @"Bangladesh", @"Hopeless", @"Quixotic", @"Wary", @"Anguish", @"Calm", @"Indifferent", @"Stupid", @"Surprised", @"Tired", @"Astonished", @"Bemused", @"Bored", @"Chaos", @"Delighted", @"Depressed", @"Determined", @"Flummoxed", @"Full", @"Interested", @"Quirky", @"Stressed", @"Triumphant", @"Zen", @"Angry", @"Anxious", nil] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return _tempFeelingStrings;
}

- (NSString *)imageNameForFeelingIndex:(NSInteger)feelingIndex imageIndex:(NSInteger)imageIndex {
    return [NSString stringWithFormat:@"protoImage%d.jpg", ((imageIndex + feelingIndex) % 4) + 1];
}

@end
