//
//  CoreDataManager.m
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataManager.h"
#import "NSDateFormatter+EmotishTimeSpans.h"

@interface CoreDataManager ()
- (Photo *) addOrUpdatePhotoFromServer:(PFObject *)photoServer;
- (Feeling *) addOrUpdateFeelingFromServer:(PFObject *)feelingServer;
@end

@implementation CoreDataManager

@synthesize managedObjectContext=_managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    if (self = [self init]) {
        self.managedObjectContext = managedObjectContext;
    }
    return self;
}

- (void) saveCoreData {
    NSLog(@"saveCoreData started");
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
    NSLog(@"saveCoreData finished");
}

- (NSArray *) getAllObjectsForEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
    if (predicate) { [fetchRequest setPredicate:predicate]; }
    if (sortDescriptors) { [fetchRequest setSortDescriptors:sortDescriptors]; }
	NSError * error;
	NSArray * fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

- (NSManagedObject *)getFirstObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors {
    BOOL newObjectMadeIndicator;
    return [self getFirstObjectForEntityName:entityName matchingPredicate:predicate usingSortDescriptors:sortDescriptors shouldMakeObjectIfNoMatch:NO newObjectMadeIndicator:&newObjectMadeIndicator];
}

- (NSManagedObject *)getFirstObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors shouldMakeObjectIfNoMatch:(BOOL)shouldMakeObjectIfNoMatch newObjectMadeIndicator:(BOOL *)newObjectMadeIndicator {
    NSArray * matchingObjects = [self getAllObjectsForEntityName:entityName predicate:predicate sortDescriptors:sortDescriptors];
    NSManagedObject * matchingObject = matchingObjects.count > 0 ? [matchingObjects objectAtIndex:0] : nil;
    if (shouldMakeObjectIfNoMatch && matchingObject == nil) {
        matchingObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
        *newObjectMadeIndicator = YES;
    } else {
        *newObjectMadeIndicator = NO;
    }
    return matchingObject;
}

- (void) updateAllFeelingDatetimes {
    for (Feeling * feeling in [self getAllObjectsForEntityName:@"Feeling" predicate:nil sortDescriptors:nil]) {
        [feeling updateDatetimeMostRecentPhoto];
    }
}

- (Feeling *)addOrUpdateFeelingFromServer:(PFObject *)feelingServer {
    BOOL newObjectMadeIndicator;
    Feeling * feeling = (Feeling *)[self getFirstObjectForEntityName:@"Feeling" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", feelingServer.objectId] usingSortDescriptors:nil shouldMakeObjectIfNoMatch:YES newObjectMadeIndicator:&newObjectMadeIndicator];
    feeling.serverID = feelingServer.objectId;
    feeling.word = [feelingServer objectForKey:@"word"];
    return feeling;
}

- (User *)addOrUpdateUserFromServer:(PFObject *)userServer {
    BOOL newObjectMadeIndicator;
    User * user = (User *)[self getFirstObjectForEntityName:@"User" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", userServer.objectId] usingSortDescriptors:nil shouldMakeObjectIfNoMatch:YES newObjectMadeIndicator:&newObjectMadeIndicator];
    user.serverID = userServer.objectId;
    user.name = [userServer objectForKey:@"username"];
    return user;
}

- (Photo *)addOrUpdatePhotoFromServer:(PFObject *)photoServer {
    BOOL newObjectMadeIndicator;
    Photo * photo = (Photo *)[self getFirstObjectForEntityName:@"Photo" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", photoServer.objectId] usingSortDescriptors:nil shouldMakeObjectIfNoMatch:YES newObjectMadeIndicator:&newObjectMadeIndicator];
    photo.serverID = photoServer.objectId;
    photo.datetime = photoServer.createdAt;
    photo.hiddenServer = [NSNumber numberWithBool:[[photoServer objectForKey:@"deleted"] boolValue] || [[photoServer objectForKey:@"flagged"] boolValue]];
    photo.hidden = [NSNumber numberWithBool:(photo.hiddenServer.boolValue || photo.hiddenLocal.boolValue)];
//    photo.shouldHighlight = [NSNumber numberWithBool:newObjectMadeIndicator]; // This is unnecessary, for now. This value defaults to YES, which is what we want. Otherwise, it is set to NO when an image is viewed.
    return photo;
}

- (Photo *)addOrUpdatePhotoFromServer:(PFObject *)photoServer feelingFromServer:(PFObject *)feelingServer userFromServer:(PFObject *)userServer {
    Feeling * feeling = [self addOrUpdateFeelingFromServer:feelingServer];
    User * user = [self addOrUpdateUserFromServer:userServer];
    Photo * photo = [self addOrUpdatePhotoFromServer:photoServer];
    photo.feeling = feeling;
    photo.user = user;
    photo.hidden = photo.hidden;
    return photo;
}

- (void) debugLogAllFeelingsAlphabetically {
    NSLog(@"Debugging feelings alphabetically");
    for (Feeling * feeling in [self getAllObjectsForEntityName:@"Feeling" predicate:nil sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"word" ascending:YES]]]) {
        NSLog(@"  %@ - (%@) - %@", feeling.word, [NSDateFormatter emotishTimeSpanStringForDatetime:feeling.datetimeMostRecentPhoto countSeconds:YES], feeling.datetimeMostRecentPhoto);
    }
}

- (void) debugLogAllFeelingsChronologicallyDatetimeMostRecentPhoto {
    NSLog(@"Debugging feelings chronologically");
    for (Feeling * feeling in [self getAllObjectsForEntityName:@"Feeling" predicate:nil sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datetimeMostRecentPhoto" ascending:NO]]]) {
        NSLog(@"  %@ - (%@) - %@", feeling.word, [NSDateFormatter emotishTimeSpanStringForDatetime:feeling.datetimeMostRecentPhoto countSeconds:YES], feeling.datetimeMostRecentPhoto);
    }
}

- (void)processPhotosFromServer:(NSArray *)photosFromServer {
    for (PFObject * photoServer in photosFromServer) {
        PFObject * feelingServer = [photoServer objectForKey:@"feeling"];
        PFObject * userServer    = [photoServer objectForKey:@"user"];
        Photo * photoLocal = [self addOrUpdatePhotoFromServer:photoServer feelingFromServer:feelingServer userFromServer:userServer];
        NSLog(@"Added or updated photo %@ (%@ %@)", photoLocal.serverID, photoLocal.user.name, photoLocal.feeling.word);
    }
}

@end
