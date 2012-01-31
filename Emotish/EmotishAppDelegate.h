//
//  EmotishAppDelegate.h
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryViewController.h"
#import "CoreDataManager.h"

@interface EmotishAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) GalleryViewController * galleryViewController;

@property (strong, nonatomic) UIWindow * window;

@property (strong, nonatomic) CoreDataManager * coreDataManager;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic, readonly) NSArray * tempSeedFeelings;
@property (strong, nonatomic, readonly) NSArray * tempSeedUsernames;
@property (strong, nonatomic, readonly) NSSet * tempSeedImageFilenames;
- (NSSet *) tempSeedImageFilenamesForFeelingWord:(NSString *)feelingWord;

@end
