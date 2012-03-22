//
//  GalleryViewController.h
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataManager.h"
#import "WebGetPhotos.h"

typedef enum {
    GalleryAlphabetical = 1,
    GalleryRecent = 2,
} GalleryMode;

@interface GalleryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, WebGetPhotosDelegate>

@property (strong, nonatomic) IBOutlet UITableView * feelingsTableView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton * addPhotoButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton * pullPhotosButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *toggleModesButton;
- (IBAction) buttonTouched:(UIButton *)button;
@property (strong, nonatomic) CoreDataManager * coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultsController;

- (void)tableView:(UITableView *)tableView configureCell:(UITableViewCell *)feelingCell atIndexPath:(NSIndexPath *)indexPath;

- (void) getPhotosFromServer;
- (void) getPhotosFromServerWithLimit:(NSNumber *)limit;
- (void) getPhotosFromServerForFeeling:(Feeling *)feeling;
@property (nonatomic, strong) NSMutableSet * getPhotosRequests;
- (void) cancelAllWebGetPhotos;
- (BOOL) getPhotosRequestIsExecutingForFeelingServerID:(NSString *)feelingServerID;
- (void) addPhoto;
@property (nonatomic, strong, readonly) NSArray * addPhotoFeelingWords;
@property (nonatomic, readonly) int addPhotoFeelingWordsNextIndex;
@property (nonatomic, readonly) int peekAtNextAddPhotoFeelingWordsIndex;

@property (nonatomic) GalleryMode galleryMode;
@property (nonatomic, strong, readonly) NSSortDescriptor * sortDescriptorAlphabetical;
@property (nonatomic, strong, readonly) NSSortDescriptor * sortDescriptorRecent;
- (NSSortDescriptor *) sortDescriptorForGalleryMode:(GalleryMode)galleryMode;

@end
