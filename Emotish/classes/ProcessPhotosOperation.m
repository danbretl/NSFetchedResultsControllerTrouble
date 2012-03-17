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
- (void)finishedWithSuccess:(NSNumber *)success;
@end

@implementation ProcessPhotosOperation

@synthesize coreDataManager=_coreDataManager;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize photos=_photos;
@synthesize delegate=_delegate;

- (void)main {
    
    @try {
    
        if (self.isCancelled) {
            [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES]; return;
        }
        
        EmotishAppDelegate * appDelegate = (EmotishAppDelegate *)[UIApplication sharedApplication].delegate;
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        self.managedObjectContext.undoManager = nil;
        self.managedObjectContext.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
    //    self.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        self.coreDataManager = [[CoreDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];    
            
        if (self.isCancelled) {
            [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES]; return;
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
            [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES]; return;
        } else {
            NSLog(@"about to save background thread core data");
            [self.coreDataManager saveCoreData];
        }
    }

    @catch (NSException * exception) {
        NSLog(@"Caught an exception in ProcessPhotosOperation. Ignoring?");
        // Do not rethrow exception...
        [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
    }
    
}

- (void)mergeChanges:(NSNotification *)notification {
    if (self.isCancelled) {
        [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES]; return;
    }
    @try {
        EmotishAppDelegate * appDelegate = (EmotishAppDelegate *)[UIApplication sharedApplication].delegate;
        // Merge changes into the main context on the main thread
        NSLog(@"about to merge");
        [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
    }
    @catch (NSException * exception) {
        NSLog(@"Caught an exception in ProcessPhotosOperation. Ignoring?");
        // Do not rethrow exception...
        [self performSelectorOnMainThread:@selector(finishedWithSuccess:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
    }
}

- (void)finishedWithSuccess:(NSNumber *)success {
    [self.delegate operationFinishedWithSuccess:success];
}

//- (void)cancel {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

@end
