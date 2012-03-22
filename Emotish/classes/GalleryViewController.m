//
//  GalleryViewController.m
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "NSDateFormatter+EmotishTimeSpans.h"

static NSString * GALLERY_MODE_KEY = @"GALLERY_MODE_KEY";

@implementation GalleryViewController

@synthesize addPhotoButton = _addPhotoButton;
@synthesize pullPhotosButton = _pullPhotosButton;
@synthesize feelingsTableView=_feelingsTableView;
@synthesize toggleModesButton = _toggleModesButton;
@synthesize coreDataManager=_coreDataManager;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize sortDescriptorAlphabetical=_sortDescriptorAlphabetical, sortDescriptorRecent=_sortDescriptorRecent;
@synthesize galleryMode=_galleryMode;
@synthesize getPhotosRequests=_getPhotosRequests;
@synthesize addPhotoFeelingWords=_addPhotoFeelingWords, addPhotoFeelingWordsNextIndex=_addPhotoFeelingWordsNextIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSNumber * galleryModeLast = [[NSUserDefaults standardUserDefaults] objectForKey:GALLERY_MODE_KEY];
        if (galleryModeLast != nil) {
            self.galleryMode = galleryModeLast.intValue;
        } else {
            self.galleryMode = GalleryAlphabetical;
        }
        [[NSUserDefaults standardUserDefaults] setInteger:self.galleryMode forKey:GALLERY_MODE_KEY];
        self.getPhotosRequests = [NSMutableSet set];
        _addPhotoFeelingWordsNextIndex = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.addPhotoButton setTitle:[NSString stringWithFormat:@"Add %@ Photo to Server", [self.addPhotoFeelingWords objectAtIndex:self.peekAtNextAddPhotoFeelingWordsIndex]] forState:UIControlStateNormal];
    [self.toggleModesButton setTitle:(self.galleryMode == GalleryAlphabetical) ? @"Toggle Gallery Mode to Recent" : @"Toggle Gallery Mode to Alphabetical" forState:UIControlStateNormal];
    
    NSError * error;
	if (![self.fetchedResultsController performFetch:&error]) {
		// Handle the error appropriately...
		NSLog(@"GalleryViewController - Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
}

- (void)viewDidUnload {
    [self setAddPhotoButton:nil];
    [self setPullPhotosButton:nil];
    [self setToggleModesButton:nil];
    [self setFeelingsTableView:nil];
    [self setFetchedResultsController:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cancelAllWebGetPhotos];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    int photosCount = [self tableView:self.feelingsTableView numberOfRowsInSection:0];
    if (photosCount == 0) {
        [self getPhotosFromServerWithLimit:[NSNumber numberWithInt:100]];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    NSLog(@"PRINTOUT OF DATA ACCORDING TO FETCHED RESULTS CONTROLLER");
    for (int i=0; i<[[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]; i++) {
        Feeling * feeling = (Feeling *)[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSLog(@"  %@ (%@) %@", feeling.word, [NSDateFormatter emotishTimeSpanStringForDatetime:feeling.datetimeMostRecentPhoto countSeconds:YES], feeling.datetimeMostRecentPhoto);
    }
    
    NSLog(@"RESULTS FROM SEPARATE FETCH ON MAIN MOC");
    if (self.galleryMode == GalleryAlphabetical) {
        [self.coreDataManager debugLogAllFeelingsAlphabetically];
    } else {
        [self.coreDataManager debugLogAllFeelingsChronologicallyDatetimeMostRecentPhoto];
    }
    
    NSLog(@"RESULTS FROM SEPARATE FETCH ON NEW MOC BASED ON PERSISTENT STORE COORDINATOR");
    NSManagedObjectContext * moc = [[NSManagedObjectContext alloc] init];
    moc.undoManager = nil;
    moc.persistentStoreCoordinator = self.coreDataManager.managedObjectContext.persistentStoreCoordinator;
    CoreDataManager * cdm = [[CoreDataManager alloc] initWithManagedObjectContext:moc];
    if (self.galleryMode == GalleryAlphabetical) {
        [cdm debugLogAllFeelingsAlphabetically];
    } else {
        [cdm debugLogAllFeelingsChronologicallyDatetimeMostRecentPhoto];
    }
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * FeelingCellID = @"FeelingCellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:FeelingCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:FeelingCellID];
    }
    
    [self tableView:tableView configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView configureCell:(UITableViewCell *)feelingCell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    Feeling * feeling = [self.fetchedResultsController objectAtIndexPath:indexPath];
    feelingCell.textLabel.text = feeling.word;
    feelingCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ --- %@", [NSDateFormatter emotishTimeSpanStringForDatetime:feeling.datetimeMostRecentPhoto countSeconds:YES], feeling.datetimeMostRecentPhoto];
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"GalleryViewController.fetchedResultsController controllerWillChangeContent");
    
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    NSLog(@"PRINTOUT OF DATA ACCORDING TO FETCHED RESULTS CONTROLLER");
    for (int i=0; i<[[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]; i++) {
        Feeling * feeling = (Feeling *)[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSLog(@"  %@ (%@) %@", feeling.word, [NSDateFormatter emotishTimeSpanStringForDatetime:feeling.datetimeMostRecentPhoto countSeconds:YES], feeling.datetimeMostRecentPhoto);
    }
    
    NSLog(@"RESULTS FROM SEPARATE FETCH ON MAIN MOC");
    if (self.galleryMode == GalleryAlphabetical) {
        [self.coreDataManager debugLogAllFeelingsAlphabetically];
    } else {
        [self.coreDataManager debugLogAllFeelingsChronologicallyDatetimeMostRecentPhoto];
    }
    
    NSLog(@"RESULTS FROM SEPARATE FETCH ON NEW MOC BASED ON PERSISTENT STORE COORDINATOR");
    NSManagedObjectContext * moc = [[NSManagedObjectContext alloc] init];
    moc.undoManager = nil;
    moc.persistentStoreCoordinator = self.coreDataManager.managedObjectContext.persistentStoreCoordinator;
    CoreDataManager * cdm = [[CoreDataManager alloc] initWithManagedObjectContext:moc];
    if (self.galleryMode == GalleryAlphabetical) {
        [cdm debugLogAllFeelingsAlphabetically];
    } else {
        [cdm debugLogAllFeelingsChronologicallyDatetimeMostRecentPhoto];
    }
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    
    [self.feelingsTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSLog(@"GalleryViewController.fetchedResultsController didChangeObject:%@ atIndexPath:%d-%d newIndexPath:%d-%d", anObject, indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            NSLog(@"NSFetchedResultsChangeInsert");
            [self.feelingsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"NSFetchedResultsChangeDelete");
            [self.feelingsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"NSFetchedResultsChangeUpdate");
            [self.feelingsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [self tableView:self.feelingsTableView configureCell:[self.feelingsTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"NSFetchedResultsChangeMove %d to %d", indexPath.row, newIndexPath.row);
            [self.feelingsTableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.feelingsTableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"GalleryViewController.fetchedResultsController controllerDidChangeContent");

    [self.feelingsTableView endUpdates];
    
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    NSLog(@"PRINTOUT OF DATA ACCORDING TO FETCHED RESULTS CONTROLLER");
    for (int i=0; i<[[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]; i++) {
        Feeling * feeling = (Feeling *)[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSLog(@"  %@ (%@) %@", feeling.word, [NSDateFormatter emotishTimeSpanStringForDatetime:feeling.datetimeMostRecentPhoto countSeconds:YES], feeling.datetimeMostRecentPhoto);
    }

    NSLog(@"RESULTS FROM SEPARATE FETCH ON MAIN MOC");
    if (self.galleryMode == GalleryAlphabetical) {
        [self.coreDataManager debugLogAllFeelingsAlphabetically];
    } else {
        [self.coreDataManager debugLogAllFeelingsChronologicallyDatetimeMostRecentPhoto];
    }
    
    NSLog(@"RESULTS FROM SEPARATE FETCH ON NEW MOC BASED ON PERSISTENT STORE COORDINATOR");
    NSManagedObjectContext * moc = [[NSManagedObjectContext alloc] init];
    moc.undoManager = nil;
    moc.persistentStoreCoordinator = self.coreDataManager.managedObjectContext.persistentStoreCoordinator;
    CoreDataManager * cdm = [[CoreDataManager alloc] initWithManagedObjectContext:moc];
    if (self.galleryMode == GalleryAlphabetical) {
        [cdm debugLogAllFeelingsAlphabetically];
    } else {
        [cdm debugLogAllFeelingsChronologicallyDatetimeMostRecentPhoto];
    }
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING
    // DEBUGGING DEBUGGING DEBUGGING DEBUGGING DEBUGGING

}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Feeling" inManagedObjectContext:self.coreDataManager.managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY photos.hidden == NO"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[self sortDescriptorForGalleryMode:self.galleryMode]];
    fetchRequest.fetchBatchSize = 20;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreDataManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (NSSortDescriptor *)sortDescriptorForGalleryMode:(GalleryMode)galleryMode {
    return galleryMode == GalleryAlphabetical ? self.sortDescriptorAlphabetical : self.sortDescriptorRecent;
}

- (NSSortDescriptor *)sortDescriptorAlphabetical {
    if (_sortDescriptorAlphabetical == nil) {
        _sortDescriptorAlphabetical = [NSSortDescriptor sortDescriptorWithKey:@"word" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return _sortDescriptorAlphabetical;
}

- (NSSortDescriptor *)sortDescriptorRecent {
    if (_sortDescriptorRecent == nil) {
        _sortDescriptorRecent = [NSSortDescriptor sortDescriptorWithKey:@"datetimeMostRecentPhoto" ascending:NO];
    }
    return _sortDescriptorRecent;
}

- (void) adjustFetchRequestForGalleryMode:(GalleryMode)galleryMode {
    [UIView animateWithDuration:0.25 animations:^{
        self.feelingsTableView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.fetchedResultsController.fetchRequest.sortDescriptors = [NSArray arrayWithObject:[self sortDescriptorForGalleryMode:galleryMode]];
        NSError * error;
        if (![self.fetchedResultsController performFetch:&error]) {
            // Handle the error appropriately...
            NSLog(@"GalleryViewController - Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        [self.feelingsTableView reloadData];
        [self.feelingsTableView setContentOffset:CGPointZero animated:NO];
        [self.toggleModesButton setTitle:(self.galleryMode == GalleryAlphabetical) ? @"Toggle Gallery Mode to Recent" : @"Toggle Gallery Mode to Alphabetical" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.25 animations:^{
            self.feelingsTableView.alpha = 1.0;
        }];
    }];

}

- (void) cancelAllWebGetPhotos {
    for (WebGetPhotos * request in self.getPhotosRequests) {
        [request cancelWebGetPhotos];
        request.delegate = nil;
    }
    [self.getPhotosRequests removeAllObjects];
}

- (void) getPhotosFromServer {
    
    [self getPhotosFromServerWithLimit:[NSNumber numberWithInt:1000]];
    
}

- (void) getPhotosFromServerWithLimit:(NSNumber *)limit {
    
    BOOL ignore = NO;
    for (WebGetPhotos * request in self.getPhotosRequests) {
        ignore = request.isGeneral;
        if (ignore) { break; }
    }
    
    if (!ignore) {
        
        NSDate * lastReloadDate = [[NSUserDefaults standardUserDefaults] objectForKey: WEB_RELOAD_ALL_DATE_KEY];
        
        WebGetPhotos * request = [[WebGetPhotos alloc] initForPhotosAllWithOptionsVisibleOnly:[NSNumber numberWithBool:YES] beforeEndDate:nil afterStartDate:lastReloadDate dateKey:@"createdAt" limit:limit delegate:self];
        [self.getPhotosRequests addObject:request];
        [request startWebGetPhotos];
        
    }
    
}

- (void)getPhotosFromServerForFeeling:(Feeling *)feeling {
    
    if (![self getPhotosRequestIsExecutingForFeelingServerID:feeling.serverID]) {
    
        WebGetPhotos * request = [[WebGetPhotos alloc] initForPhotosWithFeelingServerID:feeling.serverID visibleOnly:[NSNumber numberWithBool:YES] beforeEndDate:nil afterStartDate:feeling.webLoadDate dateKey:@"createdAt" limit:[NSNumber numberWithInt:10] delegate:self];
        [self.getPhotosRequests addObject:request];
        [request startWebGetPhotos];
        
    }
    
}

- (void)webGetPhotos:(WebGetPhotos *)webGetPhotos succeededWithPhotos:(NSArray *)photosFromWeb {
    [self.getPhotosRequests removeObject:webGetPhotos];
    NSLog(@"GalleryViewController got %d photos", photosFromWeb.count);
    if (webGetPhotos.isGeneral && 
        webGetPhotos.limit.intValue == 1000 && 
        photosFromWeb.count > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:webGetPhotos.datetimeExecuted forKey:WEB_RELOAD_ALL_DATE_KEY];
    }
    if (photosFromWeb && photosFromWeb.count > 0) {
        [self.coreDataManager processPhotosFromServer:photosFromWeb];
        [self.coreDataManager updateAllFeelingDatetimes];
        [self.coreDataManager saveCoreData];
    }
}

- (void)webGetPhotos:(WebGetPhotos *)webGetPhotos failedWithError:(NSError *)error {
    [self.getPhotosRequests removeObject:webGetPhotos];
    NSLog(@"Error when trying to get photos. Should report error?");
}

- (BOOL) getPhotosRequestIsExecutingForFeelingServerID:(NSString *)feelingServerID {
    NSSet * filteredSet = [self.getPhotosRequests filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.groupServerID == %@", feelingServerID]];
    return filteredSet.count > 0;
}

- (void)buttonTouched:(UIButton *)button {
    if (button == self.addPhotoButton) {
        [self addPhoto];
    } else if (button == self.pullPhotosButton) {
        [self getPhotosFromServer];
    } else if (button == self.toggleModesButton) {
        self.galleryMode = (self.galleryMode == GalleryAlphabetical) ? GalleryRecent : GalleryAlphabetical;
        [[NSUserDefaults standardUserDefaults] setInteger:self.galleryMode forKey:GALLERY_MODE_KEY];
        [self adjustFetchRequestForGalleryMode:self.galleryMode];
    }
}

- (void) addPhoto {

    self.view.userInteractionEnabled = NO;
    
    NSString * feelingWord = [self.addPhotoFeelingWords objectAtIndex:self.addPhotoFeelingWordsNextIndex];
    
    NSLog(@"setting up feeling");
    Feeling * feelingLocal = (Feeling *)[self.coreDataManager getFirstObjectForEntityName:@"Feeling" matchingPredicate:[NSPredicate predicateWithFormat:@"word == %@", feelingWord] usingSortDescriptors:nil];
    PFObject * feelingServer = nil;
    if (feelingLocal != nil) {
        feelingServer = [PFObject objectWithClassName:@"Feeling"];
        feelingServer.objectId = feelingLocal.serverID;
        [feelingServer setObject:feelingLocal.word forKey:@"word"];
    } else {
        PFQuery * feelingQuery = [PFQuery queryWithClassName:@"Feeling"];
        [feelingQuery whereKey:@"word" equalTo:feelingWord];
        feelingServer = [feelingQuery getFirstObject];
        if (feelingServer == nil) {
            feelingServer = [PFObject objectWithClassName:@"Feeling"];
            [feelingServer setObject:feelingWord forKey:@"word"];
        }
    }
    NSLog(@"  feelingServer = %@", feelingServer);
    
    NSLog(@"saving feelingServer");
    BOOL savingSuccess = [feelingServer save];
    NSLog(@"  saving feelingServer success? %d", savingSuccess);
    
    NSLog(@"setting up photo");
    PFObject * photoServer = [PFObject objectWithClassName:@"Photo"];
    [photoServer setObject:feelingServer forKey:@"feeling"];
    [photoServer setObject:[PFUser currentUser] forKey:@"user"];
    NSLog(@"  photoServer = %@", photoServer);
    
    NSLog(@"saving photoServer");
    savingSuccess = [photoServer save];
    NSLog(@"  saving photoServer success? %d", savingSuccess);
    
    NSLog(@"getting full saved photo");
    photoServer = [PFQuery getObjectOfClass:@"Photo" objectId:photoServer.objectId];
    NSLog(@"  photo retrieved = %@", photoServer);
    
//    Photo * submittedPhoto = [self.coreDataManager addOrUpdatePhotoFromServer:photoServer feelingFromServer:feelingServer userFromServer:[PFUser currentUser]];
//    NSLog(@"submittedPhotoLocal = %@", submittedPhoto);
    
//    [self.coreDataManager saveCoreData];
    
    self.view.userInteractionEnabled = YES;
    
    [self.addPhotoButton setTitle:[NSString stringWithFormat:@"Add %@ Photo to Server", [self.addPhotoFeelingWords objectAtIndex:self.peekAtNextAddPhotoFeelingWordsIndex]] forState:UIControlStateNormal];
    
}

- (NSArray *)addPhotoFeelingWords {
    if (_addPhotoFeelingWords == nil) {
        _addPhotoFeelingWords = [NSArray arrayWithObjects:@"a-word", @"b-word", @"c-word", @"d-word", @"e-word", nil];
    }
    return _addPhotoFeelingWords;
}

- (int)addPhotoFeelingWordsNextIndex {
    _addPhotoFeelingWordsNextIndex++;
    if (_addPhotoFeelingWordsNextIndex >= self.addPhotoFeelingWords.count) {
        _addPhotoFeelingWordsNextIndex = 0;
    }
    return _addPhotoFeelingWordsNextIndex;
}

- (int)peekAtNextAddPhotoFeelingWordsIndex {
    int peek = _addPhotoFeelingWordsNextIndex + 1;
    if (peek >= self.addPhotoFeelingWords.count) {
        peek = 0;
    }
    return peek;
}

@end
