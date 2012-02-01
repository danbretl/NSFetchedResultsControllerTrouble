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

typedef enum {
    NoFocus = 0,
    FeelingFocus = 1,
    UserFocus = 2,
} PhotosStripFocus;

@protocol PhotosStripViewControllerDelegate;

@interface PhotosStripViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

- (void) setFocusToFeeling:(Feeling *)feeling photo:(Photo *)photo;
- (void) setFocusToUser:(User *)user photo:(Photo *)photo;

@property (strong, nonatomic) CoreDataManager * coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultsControllerFeeling;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultsControllerUser;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *topBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *headerButton;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *photosTableView;
@property (strong, nonatomic) UIImageView * floatingImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *addPhotoLabel;

@property (strong, nonatomic) UIPinchGestureRecognizer * zoomOutGestureRecognizer;

@property (unsafe_unretained, nonatomic) id<PhotosStripViewControllerDelegate> delegate;

@end

@protocol PhotosStripViewControllerDelegate <NSObject>
- (void) photosStripViewControllerFinished:(PhotosStripViewController *)photosStripViewController;
- (void) photosStripViewController:(PhotosStripViewController *)photosStripViewController requestedReplacementWithPhotosStripViewController:(PhotosStripViewController *)replacementPhotosStripViewController;
@end
