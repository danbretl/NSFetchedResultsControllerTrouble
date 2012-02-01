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

@interface PhotosStripViewController()
@property (nonatomic) PhotosStripFocus focus;
@property (strong, nonatomic) Feeling * feelingFocus;
@property (strong, nonatomic) User * userFocus;
@property (strong, nonatomic) Photo * photoInView;
@property (strong, nonatomic, readonly) NSFetchedResultsController * fetchedResultsControllerForCurrentFocus;
- (NSFetchedResultsController *)fetchedResultsControllerForFocus:(PhotosStripFocus)focus;
- (void) performFetchForCurrentFocus;
- (void) updateViewsForCurrentFocus;
- (void) pinchedToZoomOut:(UIPinchGestureRecognizer *)pinchGestureRecognizer;
@end

@implementation PhotosStripViewController
@synthesize focus=_focus;
@synthesize feelingFocus=_feelingFocus, userFocus=_userFocus, photoInView=_photoInView;
@synthesize coreDataManager=_coreDataManager;
@synthesize fetchedResultsControllerFeeling=_fetchedResultsControllerFeeling;
@synthesize fetchedResultsControllerUser=_fetchedResultsControllerUser;
@synthesize fetchedResultsControllerForCurrentFocus=_fetchedResultsControllerForCurrentFocus;
@synthesize topBar=_topBar;
@synthesize headerButton=_headerButton;
@synthesize photosTableView=_photosTableView;
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

    self.photosTableView.frame = CGRectMake( PC_PHOTO_CELL_IMAGE_ORIGIN_Y, PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM + PC_PHOTO_CELL_LABEL_HEIGHT, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL * 2); // I don't know why this line is necessary, but apparently it is.
    self.photosTableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
    CGRect photosTableViewFrameInWindow = CGRectMake(PC_PHOTO_CELL_IMAGE_WINDOW_ORIGIN_X - PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, PC_PHOTO_CELL_IMAGE_ORIGIN_Y, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL * 2, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM + PC_PHOTO_CELL_LABEL_HEIGHT);
    self.photosTableView.frame = /*[self.view convertRect:*/photosTableViewFrameInWindow/* fromView:nil]*/;
//    self.photosTableView.frame = CGRectOffset(photosTableViewFrameInWindow, 0, -(self.view.frame.origin.y + [UIApplication sharedApplication].statusBarFrame.size.height)); // I have no idea why this hack is necessary. I think it has something to do with the fact that this view controller is shown modally currently... Will probably have to revisit this and clean it up.
    NSLog(@"self.photosTableView.frame = %@", NSStringFromCGRect(self.photosTableView.frame));
    NSLog(@"photosStripViewController.view.frame = %@", NSStringFromCGRect(self.view.frame));
    self.photosTableView.rowHeight = PC_PHOTO_CELL_IMAGE_SIDE_LENGTH + PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL * 2;
    self.photosTableView.scrollsToTop = NO;
    
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
        self.photosTableView.backgroundColor = [UIColor redColor];
    }

}

- (void)viewDidUnload
{
    [self setHeaderButton:nil];
    [self setPhotosTableView:nil];
    self.floatingImageView = nil;
    self.fetchedResultsControllerFeeling = nil;
    self.fetchedResultsControllerUser = nil;
    [self setTopBar:nil];
    [self setAddPhotoLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    [self.headerButton setTitle:headerString forState:UIControlStateNormal];
    [self.headerButton setTitle:headerString forState:UIControlStateHighlighted];
    [self.headerButton setTitleColor:headerColor forState:UIControlStateNormal];
    [self.headerButton setTitleColor:headerColor forState:UIControlStateHighlighted];
    self.addPhotoLabel.text = addPhotoString;
    
    [NSFetchedResultsController deleteCacheWithName:self.fetchedResultsControllerForCurrentFocus.cacheName];
    NSPredicate * fetchPredicate = self.focus == FeelingFocus ? [NSPredicate predicateWithFormat:@"feeling == %@", self.feelingFocus] : [NSPredicate predicateWithFormat:@"user == %@", self.userFocus];
    self.fetchedResultsControllerForCurrentFocus.fetchRequest.predicate = fetchPredicate;
    [self performFetchForCurrentFocus];
    [self.photosTableView reloadData];
    [self.photosTableView scrollToRowAtIndexPath:[self.fetchedResultsControllerForCurrentFocus indexPathForObject:self.photoInView] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)setFocusToFeeling:(Feeling *)feeling photo:(Photo *)photo {
    self.focus = FeelingFocus;
    self.feelingFocus = feeling;
    self.photoInView = photo;
    if (self.view.window) {
        [self updateViewsForCurrentFocus];
    }
    NSLog(@"Should scroll to photo %@", photo);
}

- (void)setFocusToUser:(User *)user photo:(Photo *)photo {
    self.focus = UserFocus;
    self.userFocus = user;
    self.photoInView = photo;
    if (self.view.window) {
        [self updateViewsForCurrentFocus];
    }
    NSLog(@"Should scroll to photo %@", photo);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    if (self.focus != NoFocus) {
        rowCount = [[self.fetchedResultsControllerForCurrentFocus.sections objectAtIndex:section] numberOfObjects];
    }
    NSLog(@"photosTableView numberOfRows=%d", rowCount);
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Get / Create the cell
    static NSString * PhotoCellID = @"PhotoCellID";
    PhotoCell * cell = (PhotoCell *)[tableView dequeueReusableCellWithIdentifier:PhotoCellID];
    if (cell == nil) {
        cell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PhotoCellID];
    }

    // Configure the cell
    Photo * photo = [self.fetchedResultsControllerForCurrentFocus objectAtIndexPath:indexPath];
    cell.photoImageView.image = [UIImage imageNamed:photo.filename];
    NSString * captionText = nil;
    UIColor * captionColor = nil;
    if (self.focus == FeelingFocus) {
        captionText = photo.user.name;
        captionColor = [UIColor userColor];
    } else {
        captionText = photo.feeling.word.lowercaseString;
        captionColor = [UIColor feelingColor];
    }
    cell.photoCaptionLabel.text = captionText;
    cell.photoCaptionLabel.textColor = captionColor;
//    [cell.photoCaptionLabel sizeToFit];
//    NSLog(@"%@", NSStringFromCGRect(cell.photoCaptionLabel.frame));

    // Return the cell
    return cell;
    
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

@end
