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
#import "FlagStretchView.h"
#import "CameraOverlayViewHandler.h"
#import "TopBarView.h"

@interface GalleryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIScrollViewDelegate, GalleryFeelingCellDelegate, PhotosStripViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayViewHandlerDelegate> {
    
    BOOL debugging;
    
}

@property (strong, nonatomic) CoreDataManager * coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultsController;

@property (nonatomic) CGPoint feelingsTableViewContentOffsetPreserved;
@property (unsafe_unretained, nonatomic) GalleryFeelingCell * activeFeelingCell;
@property (nonatomic) NSInteger activeFeelingCellIndexRow;
@property (nonatomic) CGPoint activeFeelingCellContentOffsetPreserved;
@property (strong, nonatomic) FlagStretchView *flagStretchView;
@property (strong, nonatomic) UIImageView * floatingImageView;
@property (unsafe_unretained, nonatomic) IBOutlet TopBarView * topBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *bottomBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton * addPhotoButton;

// THE FOLLOWING PROPERTIES ARE DUPLICATED IN GalleryViewController.m AND PhotosStripViewController.m
@property (strong, nonatomic) UIImagePickerController * imagePickerControllerCamera;
@property (strong, nonatomic) UIImagePickerController * imagePickerControllerLibrary;
@property (strong, nonatomic) CameraOverlayViewHandler * cameraOverlayViewHandler;
@property (strong, nonatomic) UIImage * addPhotoImage;
// THE PREVIOUS PROPERTIES ARE DUPLICATED IN GalleryViewController.m AND PhotosStripViewController.m

@end
