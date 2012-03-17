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
@synthesize photos=_photos;//, dateRangeOld=_dateRangeOld, dateRangeRecent=_dateRangeRecent, groupLocalClassName=_groupLocalClassName, groupLocalServerID=_groupLocalServerID;
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
    
//    NSMutableDictionary * feelingsOldest = [NSMutableDictionary dictionary];
//    NSMutableDictionary * feelingsNewest = [NSMutableDictionary dictionary];
//    NSMutableDictionary * usersOldest = [NSMutableDictionary dictionary];
//    NSMutableDictionary * usersNewest = [NSMutableDictionary dictionary];
    
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
//            if (self.groupLocalClassName == nil || 
//                [self.groupLocalClassName isEqualToString:@"Feeling"]) {
//                if ([feelingsOldest objectForKey:feelingServer.objectId] == nil ||
//                    ([photo.datetime compare:[feelingsOldest objectForKey:feelingServer.objectId]] == NSOrderedAscending)) {
//                    NSDate * dateUpdate = photo.datetime;
//                    if (self.dateRangeOld != nil && [self.dateRangeOld compare:dateUpdate] == NSOrderedAscending) {
//                        dateUpdate = self.dateRangeOld;
//                    }
//                    [feelingsOldest setObject:dateUpdate forKey:feelingServer.objectId];
//                }
//                if ([feelingsNewest objectForKey:feelingServer.objectId] == nil ||
//                    ([photo.datetime compare:[feelingsNewest objectForKey:feelingServer.objectId]] == NSOrderedDescending)) {
//                    NSDate * dateUpdate = photo.datetime;
//                    if (self.dateRangeRecent != nil && [self.dateRangeRecent compare:dateUpdate] == NSOrderedDescending) {
//                        dateUpdate = self.dateRangeRecent;
//                    }
//                    [feelingsNewest setObject:dateUpdate forKey:feelingServer.objectId];                
//                }
//            }
//            if (self.groupLocalClassName == nil ||
//                [self.groupLocalClassName isEqualToString:@"User"]) {
//                if ([usersOldest objectForKey:userServer.objectId] == nil ||
//                    ([photo.datetime compare:[usersOldest objectForKey:userServer.objectId]] == NSOrderedAscending)) {
//                    NSDate * dateUpdate = photo.datetime;
//                    if (self.dateRangeOld != nil && [self.dateRangeOld compare:dateUpdate] == NSOrderedAscending) {
//                        dateUpdate = self.dateRangeOld;
//                    }
//                    [usersOldest setObject:dateUpdate forKey:userServer.objectId];
//                }
//                if ([usersNewest objectForKey:userServer.objectId] == nil ||
//                    ([photo.datetime compare:[usersNewest objectForKey:userServer.objectId]] == NSOrderedDescending)) {
//                    NSDate * dateUpdate = photo.datetime;
//                    if (self.dateRangeRecent != nil && [self.dateRangeRecent compare:dateUpdate] == NSOrderedDescending) {
//                        dateUpdate = self.dateRangeRecent;
//                    }
//                    [usersNewest setObject:dateUpdate forKey:userServer.objectId];                
//                }
//            }
        }
    }
//    if (!self.isCancelled) {
//        if (self.groupLocalClassName == nil || 
//            [self.groupLocalClassName isEqualToString:@"Feeling"]) {
//            NSArray * feelings = [self.coreDataManager getAllObjectsForEntityName:@"Feeling" predicate:nil sortDescriptors:nil];
//            for (Feeling * feeling in feelings) {
//                if (self.isCancelled) {
//                    break;
//                } else {
//                    WebFetch * webFetch = [NSEntityDescription insertNewObjectForEntityForName:@"WebFetch" inManagedObjectContext:self.managedObjectContext];
//                    webFetch.feeling = feeling;
//                    webFetch.startDatetime = [feelingsOldest objectForKey:feeling.serverID];
//                    webFetch.endDatetime = [feelingsNewest objectForKey:feeling.serverID];
//                    NSLog(@"made web fetch block for %@ with startDatetime=%@ endDatetime=%@", feeling.word, webFetch.startDatetime, webFetch.endDatetime);
//                }
//            }
//        }
//        if (self.groupLocalClassName == nil || 
//            [self.groupLocalClassName isEqualToString:@"User"]) {
//            NSArray * users = [self.coreDataManager getAllObjectsForEntityName:@"User" predicate:nil sortDescriptors:nil];
//            for (User * user in users) {
//                if (self.isCancelled) {
//                    break;
//                } else {
//                    WebFetch * webFetch = [NSEntityDescription insertNewObjectForEntityForName:@"WebFetch" inManagedObjectContext:self.managedObjectContext];
//                    webFetch.user = user;
//                    webFetch.startDatetime = [usersOldest objectForKey:user.serverID];
//                    webFetch.endDatetime = [usersNewest objectForKey:user.serverID];
//                    NSLog(@"made web fetch block for %@ with startDatetime=%@ endDatetime=%@", user.name, webFetch.startDatetime, webFetch.endDatetime);
//                }
//            }
//        }
//    }
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
