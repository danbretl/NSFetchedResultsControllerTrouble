//
//  GalleryViewController.h
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryFeelingCell.h"
#import "GalleryFeelingImageCell.h"
#import "CoreDataManager.h"
#import "PhotosStripViewController.h"

@interface GalleryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIScrollViewDelegate, GalleryFeelingCellDelegate, PhotosStripViewControllerDelegate> {
    
    BOOL debugging;
    
}

@property (strong, nonatomic) CoreDataManager * coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultsController;

@property (nonatomic) CGPoint feelingsTableViewContentOffsetPreserved;
@property (unsafe_unretained, nonatomic) GalleryFeelingCell * activeFeelingCell;
@property (nonatomic) NSInteger activeFeelingCellIndexRow;
@property (nonatomic) CGPoint activeFeelingCellContentOffsetPreserved;
//@property (strong, nonatomic, readonly) NSArray * tempFeelingStrings;
@property (strong, nonatomic) UIImageView * floatingImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView * topBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *addPhotoButton;

@end
