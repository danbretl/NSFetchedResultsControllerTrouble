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
@end

@implementation ProcessPhotosOperation

@synthesize coreDataManager=_coreDataManager;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize photos=_photos;
@synthesize delegate=_delegate;

- (void)main {
    
    if (self.isCancelled) {
        [self.delegate operationFinishedWithSuccess:NO]; return;
    }
    
    EmotishAppDelegate * appDelegate = (EmotishAppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.undoManager = nil;
    self.managedObjectContext.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
//    self.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    
    if (self.isCancelled) {
        [self.delegate operationFinishedWithSuccess:NO]; return;
    }
    
    self.coreDataManager = [[CoreDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
    
    if (self.isCancelled) {
        [self.delegate operationFinishedWithSuccess:NO]; return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
        
    if (self.isCancelled) {
        [self.delegate operationFinishedWithSuccess:NO]; return;
    }
    
    for (PFObject * photoServer in self.photos) {
        if (self.isCancelled) {
            break;
        } else {
            PFObject * feelingServer = [photoServer objectForKey:@"feeling"];
            PFObject * userServer = [photoServer objectForKey:@"user"];
            Photo * photo = [self.coreDataManager addOrUpdatePhotoFromServer:photoServer feelingFromServer:feelingServer userFromServer:userServer];
            NSLog(@"photo added or updated with feeling %@ & user %@", photo.feeling.word, photo.user.name);
        }
    }
    if (self.isCancelled) {
        [self.delegate operationFinishedWithSuccess:NO]; return;
    } else {
        NSLog(@"about to save background thread core data");
        [self.coreDataManager saveCoreData];
    }
    
}

- (void)mergeChanges:(NSNotification *)notification {
    if (self.isCancelled) {
        [self.delegate operationFinishedWithSuccess:NO]; return;
    }
	EmotishAppDelegate * appDelegate = (EmotishAppDelegate *)[UIApplication sharedApplication].delegate;
	// Merge changes into the main context on the main thread
    NSLog(@"about to merge");
	[appDelegate.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
    [self.delegate operationFinishedWithSuccess:YES];
}

//- (void)cancel {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

@end
