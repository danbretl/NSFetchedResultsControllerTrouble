//
//  ProcessPhotosOperation.m
//  Emotish
//
//  Created by Dan Bretl on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProcessPhotosOperation.h"
#import "EmotishAppDelegate.h"

@interface ProcessPhotosOperation ()
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) CoreDataManager * coreDataManager;
- (void)mergeChanges:(NSNotification *)notification;
@end

@implementation ProcessPhotosOperation

@synthesize coreDataManager=_coreDataManager;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize photos=_photos;

- (id) initWithPhotos:(NSArray *)photos {
    self = [super init];
    if (self) {
        self.photos = photos;
    }
    return self;
}

- (void)main {
    
    EmotishAppDelegate * appDelegate = (EmotishAppDelegate *)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.undoManager = nil;
    self.managedObjectContext.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
//    self.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;

    self.coreDataManager = [[CoreDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
            
    for (PFObject * photoServer in self.photos) {
            
        PFObject * feelingServer = [photoServer objectForKey:@"feeling"];
        PFObject * userServer    = [photoServer objectForKey:@"user"];
        
//        Photo * photoLocal = (Photo *)[self.coreDataManager getFirstObjectForEntityName:@"Photo" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", photoServer.objectId] usingSortDescriptors:nil];
//        NSLog(@"      Local Photo %@", photoLocal == nil ? @"does not exist" : @"exists");
        
//        Feeling * feelingLocal = (Feeling *)[self.coreDataManager getFirstObjectForEntityName:@"Feeling" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", feelingServer.objectId] usingSortDescriptors:nil];
//        NSLog(@"      Local Feeling %@", feelingLocal == nil ? @"does not exist" : @"exists");
//        if (feelingLocal) {
//            NSLog(@"        datetimeMostRecentPhoto = %@", feelingLocal.datetimeMostRecentPhoto);
//            NSLog(@"        photosVisible.count = %d", feelingLocal.photosVisible.count);
//        }
//        User * userLocal = (User *)[self.coreDataManager getFirstObjectForEntityName:@"User" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", userServer.objectId] usingSortDescriptors:nil];
//        NSLog(@"      Local User %@", userLocal == nil ? @"does not exist" : @"exists");
        
        Photo * photo = [self.coreDataManager addOrUpdatePhotoFromServer:photoServer feelingFromServer:feelingServer userFromServer:userServer];
        NSLog(@"Added or updated photo %@", photo);
//        NSString * photoAddedUpdatedString = photoLocal == nil ? @"added" : @"updated";
//        NSString * feelingAddedUpdatedString = feelingLocal == nil ? @"added" : @"updated";
//        NSString * userAddedUpdatedString = userLocal == nil ? @"added" : @"updated";
//        NSLog(@"      Photo %@", photoAddedUpdatedString);
//        NSLog(@"        Feeling %@ %@", photo.feeling.word, feelingAddedUpdatedString);
//        NSLog(@"          datetimeMostRecentPhoto = %@", photo.feeling.datetimeMostRecentPhoto);
//        NSLog(@"          photosVisible.count = %d", photo.feeling.photosVisible.count);
//        NSLog(@"        User %@ %@", photo.user.name, userAddedUpdatedString);
            
    }

//    NSLog(@"  About to save ProcessPhotosOperation's managedObjectContext");
    [self.coreDataManager saveCoreData];
    
}

- (void)mergeChanges:(NSNotification *)notification {
    EmotishAppDelegate * appDelegate = (EmotishAppDelegate *)[UIApplication sharedApplication].delegate;
    // Merge changes into the main context on the main thread
    NSLog(@"  About to merge NSManagedObjectContexts");
    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
}

+ (void)processPhotos:(NSArray *)photos withCoreDataManager:(CoreDataManager *)coreDataManager {
    
    for (PFObject * photoServer in photos) {
        
        PFObject * feelingServer = [photoServer objectForKey:@"feeling"];
        PFObject * userServer    = [photoServer objectForKey:@"user"];
        Photo * photoLocal = [coreDataManager addOrUpdatePhotoFromServer:photoServer feelingFromServer:feelingServer userFromServer:userServer];
        NSLog(@"Added or updated photo %@ (%@ %@)", photoLocal.serverID, photoLocal.user.name, photoLocal.feeling.word);
    }

//    [coreDataManager saveCoreData];
    
}

//+ (void) updateFeelingsChronologicalSortWithCoreDataManager:(CoreDataManager *)coreDataManager {
////    NSArray * feelings = [coreDataManager getAllObjectsForEntityName:@"Feeling" predicate:[NSPredicate predicateWithFormat:@"ANY photos.hidden == NO"] sortDescriptors:nil];
//    [coreDataManager updateAllFeelingDatetimes];
//}

@end
