//
//  GetAndProcessPhotosOperation.m
//  Emotish
//
//  Created by Dan Bretl on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GetAndProcessPhotosOperation.h"
#import "WebUtil.h"
#import "CoreDataManager.h"
#import "EmotishAppDelegate.h"

const BOOL GAP_WEB_GET_PHOTOS_CHRONOLOGICAL_SORT_IS_ASCENDING_DEFAULT = NO;
const BOOL GAP_WEB_GET_PHOTOS_VISIBLE_ONLY_DEFAULT = YES;
const int GAP_WEB_GET_PHOTOS_LIMIT_DEFAULT = 10;
static NSString * GAP_WEB_GET_PHOTOS_DATE_KEY_DEFAULT = @"createdAt"; // (or @"updatedAt")

@interface GetAndProcessPhotosOperation()
- (void) finishedWithSuccess:(BOOL)success;
@property (strong, nonatomic) NSString * groupClassName;
@property (strong, nonatomic) NSString * groupServerID;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
- (void)mergeChanges:(NSNotification *)notification;
@property (strong, nonatomic) CoreDataManager * coreDataManager;
@end

@implementation GetAndProcessPhotosOperation
@synthesize photosQuery=_photosQuery;
@synthesize groupClassName=_groupClassName, groupServerID=_groupServerID;
@synthesize coreDataManager=_coreDataManager, managedObjectContext=_managedObjectContext;

- (id)initWithGroupClassName:(NSString *)groupClassName matchingGroupServerID:(NSString *)groupServerID visibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey chronologicalSortIsAscending:(NSNumber *)ascending limit:(NSNumber *)limit {
    
    self = [super init];
    if (self) {
        
        NSLog(@"Setting up photosQuery");
        
        self.groupClassName = groupClassName;
        self.groupServerID = groupServerID;
        self.photosQuery = [PFQuery queryWithClassName:@"Photo"];
        
        if (groupClassName != nil && groupServerID != nil) {
            [self.photosQuery whereKey:groupClassName.lowercaseString equalTo:[PFPointer pointerWithClassName:groupClassName objectId:groupServerID]];
            NSLog(@"  whereKey:%@ equalTo:%@", groupClassName.lowercaseString, groupServerID);
        }
        
        if (visibleOnly != nil && visibleOnly.boolValue) {
            [self.photosQuery whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
            [self.photosQuery whereKey:@"flagged" notEqualTo:[NSNumber numberWithBool:YES]];
            NSLog(@"  whereKey:deleted notEqualTo:YES");
            NSLog(@"  whereKey:flagged notEqualTo:YES");
        }
        
        if (dateKey == nil) {
            dateKey = GAP_WEB_GET_PHOTOS_DATE_KEY_DEFAULT;
        }
        
        if (endDate != nil) {
            [self.photosQuery whereKey:dateKey lessThanOrEqualTo:endDate];
            NSLog(@"  whereKey:%@ lessThanOrEqualTo:%@", dateKey, endDate);
        }
        if (startDate != nil) {
            [self.photosQuery whereKey:dateKey greaterThanOrEqualTo:startDate];
            NSLog(@"  whereKey:%@ greaterThanOrEqualTo:%@", dateKey, startDate);
        }
        
        BOOL ascendingValue = GAP_WEB_GET_PHOTOS_CHRONOLOGICAL_SORT_IS_ASCENDING_DEFAULT;
        if (ascending != nil) {
            ascendingValue = ascending.boolValue;
        }
        if (ascendingValue) {
            [self.photosQuery orderByAscending:dateKey];
            NSLog(@"  orderByAscending:%@", dateKey);
        } else {
            [self.photosQuery orderByDescending:dateKey];
            NSLog(@"  orderByDescending:%@", dateKey);
        }
        
        int limitValue = GAP_WEB_GET_PHOTOS_LIMIT_DEFAULT;
        if (limit != nil) {
            limitValue = limit.intValue;
        }
        [self.photosQuery setLimit:[NSNumber numberWithInt:limitValue]];
        NSLog(@"  setLimit:%d", limitValue);
        
        [self.photosQuery includeKey:@"feeling"];
        NSLog(@"  includeKey:feeling");
        [self.photosQuery includeKey:@"user"];
        NSLog(@"  includeKey:user");
        
    }
    return self;
        
}

- (void)finishedWithSuccess:(BOOL)success {
    [[NSNotificationCenter defaultCenter] postNotificationName:WEB_GET_PHOTOS_FINISHED_NOTIFICATION object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:success], WEB_GET_PHOTOS_FINISHED_NOTIFICATION_SUCCESS_KEY, [WebUtil getPhotosRequestIdentifierForGroupClassName:self.groupClassName groupServerID:self.groupServerID], WEB_GET_PHOTOS_FINISHED_NOTIFICATION_GROUP_IDENTIFIER_KEY, nil]];
}

- (void)main {
    
    if ([self isCancelled]) {
        NSLog(@"Cancelled before it even began");
//        [self finishedWithSuccess:NO];
        return;
    }
    
    NSLog(@"Executing photosQuery in background");
//    NSError * error;
//    NSArray * objects = [self.photosQuery findObjects:&error];
    [self.photosQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"  Found objects");
        NSLog(@"    Error: %@ %@ %@", error, error.description, error.userInfo);
        NSLog(@"    Objects: (%d)", objects.count);
        for (PFObject * object in objects) {
            NSLog(@"      %@ %@ %@", object.objectId, [[object objectForKey:@"feeling"] objectForKey:@"word"], [[object objectForKey:@"user"] objectForKey:@"username"]);
        }
        if (!error) {
            if (objects && objects.count > 0) {
                
                // Process photos here...
                
                // Set up managedObjectContext & coreDataManager
                NSLog(@"  Creating NSManagedObjectContext from appDelegate's persistentStoreCoordinator");
                EmotishAppDelegate * appDelegate = (EmotishAppDelegate *)[UIApplication sharedApplication].delegate;
                self.managedObjectContext = [[NSManagedObjectContext alloc] init];
                self.managedObjectContext.undoManager = nil;
                self.managedObjectContext.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
                //    self.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
                NSLog(@"  Creating coreDataManager with managedObjectContext");
                self.coreDataManager = [[CoreDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
                NSLog(@"  Registering for NSManagedObjectContextDidSaveNotification");
                // Registering for didSave notification
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
                
                NSLog(@"  Processing Photos");
                for (PFObject * photoServer in objects) {
                    NSLog(@"    Processing Photo %@", photoServer.objectId);
                    if ([self isCancelled]) {
                        NSLog(@"    Cancelled while processing photo %@. Breaking loop.", photoServer.objectId);
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
                
                if ([self isCancelled]) {
                    NSLog(@"  Cancelled just before saving core data");
//                    [self finishedWithSuccess:NO];
                } else {
                    NSLog(@"  About to save GetAndProcessPhotosOperation's managedObjectContext");
                    [self.coreDataManager saveCoreData];
                }
                
            } else {
                [self finishedWithSuccess:YES];
            }
        } else {
            [self finishedWithSuccess:NO];
        }
    }];

}

- (void)mergeChanges:(NSNotification *)notification {
    EmotishAppDelegate * appDelegate = (EmotishAppDelegate *)[UIApplication sharedApplication].delegate;
    // Merge changes into the main context on the main thread
    NSLog(@"  About to merge NSManagedObjectContexts");
    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
    [self finishedWithSuccess:YES];
}

@end
