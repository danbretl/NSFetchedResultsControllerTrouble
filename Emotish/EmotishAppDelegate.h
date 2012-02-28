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

@interface EmotishAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UINavigationController * rootNavController;
@property (strong, nonatomic) GalleryViewController * galleryViewController;

@property (strong, nonatomic) UIWindow * window;

@property (strong, nonatomic) CoreDataManager * coreDataManager;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIAlertView * notificationAlertView;
@property (strong, nonatomic) NSString * notificationPhotoServerID;
- (void) attemptNavigateToPhotoWithServerID:(NSString *)photoServerID;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
