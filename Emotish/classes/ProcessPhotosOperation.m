//
//  ProcessPhotosOperation.m
//  Emotish
//
//  Created by Dan Bretl on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProcessPhotosOperation.h"
#import "EmotishAppDelegate.h"
#import "CoreDataManager.h"

@interface ProcessPhotosOperation ()
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
- (void)mergeChanges:(NSNotification *)notification;
@property (strong, nonatomic) CoreDataManager * coreDataManager;
//- (void)finishedWithSuccess:(NSNumber *)success;
- (void) finishedWithSuccess:(BOOL)success;
@end

@implementation ProcessPhotosOperation

@synthesize coreDataManager=_coreDataManager;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize photos=_photos;
//@synthesize delegate=_delegate;

- (void)main {
    
    NSLog(@"ProcessPhotosOperation main starting");
    
//    @try {
    
        if (self.isCancelled) {
            NSLog(@"  Cancelled");
            [self finishedWithSuccess:NO];
            return;
//            [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES]; return;
        }
        
        NSLog(@"  Creating NSManagedObjectContext from appDelegate's persistentStoreCoordinator");
        EmotishAppDelegate * appDelegate = (EmotishAppDelegate *)[UIApplication sharedApplication].delegate;
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        self.managedObjectContext.undoManager = nil;
        self.managedObjectContext.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
    //    self.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        NSLog(@"  Creating coreDataManager with managedObjectContext");
        self.coreDataManager = [[CoreDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
        NSLog(@"  Registering for NSManagedObjectContextDidSaveNotification");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];    
            
//        if (self.isCancelled) {
//            NSLog(@"  Cancelled");
//            [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES]; return;
//        }
        
        NSLog(@"  Processing Photos");
        for (PFObject * photoServer in self.photos) {
            NSLog(@"    Processing Photo %@", photoServer.objectId);
            if (self.isCancelled) {
                NSLog(@"    Cancelled. Breaking loop.");
                break;
            } else {
                
                PFObject * feelingServer = [photoServer objectForKey:@"feeling"];
                PFObject * userServer = [photoServer objectForKey:@"user"];
                
                Photo * photoLocal = (Photo *)[self.coreDataManager getFirstObjectForEntityName:@"Photo" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", photoServer.objectId] usingSortDescriptors:nil];
                NSLog(@"      Local Photo %@", photoLocal == nil ? @"does not exist" : @"exists");
                
                Feeling * feelingLocal = (Feeling *)[self.coreDataManager getFirstObjectForEntityName:@"Feeling" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", feelingServer.objectId] usingSortDescriptors:nil];
                NSLog(@"      Local Feeling %@", feelingLocal == nil ? @"does not exist" : @"exists");
                if (feelingLocal) {
                    NSLog(@"        datetimeMostRecentPhoto = %@", feelingLocal.datetimeMostRecentPhoto);
                    NSLog(@"        photosVisible.count = %d", feelingLocal.photosVisible.count);
                }
                User * userLocal = (User *)[self.coreDataManager getFirstObjectForEntityName:@"User" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", userServer.objectId] usingSortDescriptors:nil];
                NSLog(@"      Local User %@", userLocal == nil ? @"does not exist" : @"exists");
                
                Photo * photo = [self.coreDataManager addOrUpdatePhotoFromServer:photoServer feelingFromServer:feelingServer userFromServer:userServer];
                NSString * photoAddedUpdatedString = photoLocal == nil ? @"added" : @"updated";
                NSString * feelingAddedUpdatedString = feelingLocal == nil ? @"added" : @"updated";
                NSString * userAddedUpdatedString = userLocal == nil ? @"added" : @"updated";
                NSLog(@"      Photo %@", photoAddedUpdatedString);
                NSLog(@"        Feeling %@ %@", photo.feeling.word, feelingAddedUpdatedString);
                NSLog(@"          datetimeMostRecentPhoto = %@", photo.feeling.datetimeMostRecentPhoto);
                NSLog(@"          photosVisible.count = %d", photo.feeling.photosVisible.count);
                NSLog(@"        User %@ %@", photo.user.name, userAddedUpdatedString);
                
            }
        }
        if (self.isCancelled) {
            NSLog(@"  Cancelled");
            [self finishedWithSuccess:NO];
//            [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES]; return;
        } else {
            NSLog(@"  About to save ProcessPhotosOperation's managedObjectContext");
            [self.coreDataManager saveCoreData];
        }
//    }

//    @catch (NSException * exception) {
//        NSLog(@"  Caught an exception. Ignoring?");
//        // Do not rethrow exception...
//        NSLog(@"  Cancelled");
//        [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
//    }
    
}

- (void)mergeChanges:(NSNotification *)notification {
//    if (self.isCancelled || ![notification isKindOfClass:[NSNotification class]]) { // Something weird happens sometimes where notification is some other Class of object... I should really be figuring out why that happens at all, but instead, I'm just trying to catch the weirdness and abort.
//        NSLog(@"  Cancelled");
//        [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES]; return;
//    }
//    @try {
        EmotishAppDelegate * appDelegate = (EmotishAppDelegate *)[UIApplication sharedApplication].delegate;
        // Merge changes into the main context on the main thread
        NSLog(@"  About to merge NSManagedObjectContexts");
        [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
        [self finishedWithSuccess:YES];
//        [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
//    }
//    @catch (NSException * exception) {
//        NSLog(@"  Caught an exception. Ignoring?");
//        NSLog(@"  Cancelled");
//        // Do not rethrow exception...
//        [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
//    }
}

//- (void)finishedWithSuccess:(NSNumber *)success {
//    [self.delegate operationFinishedWithSuccess:success];
//}

- (void)finishedWithSuccess:(BOOL)success {
//    [[NSNotificationCenter defaultCenter] postNotificationName:WEB_GET_PHOTOS_FINISHED_NOTIFICATION object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:success] forKey:WEB_GET_PHOTOS_FINISHED_NOTIFICATION_SUCCESS_KEY]];
}

//- (void)cancel {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

@end
