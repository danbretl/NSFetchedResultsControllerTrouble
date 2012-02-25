//
//  CoreDataManager.m
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager

@synthesize managedObjectContext=_managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    if (self = [self init]) {
        self.managedObjectContext = managedObjectContext;
    }
    return self;
}

- (void) saveCoreData {
    NSError * error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error saving core data: %@", [error localizedDescription]);
    }
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

//- (NSManagedObject *) getOrMakeObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors {
//    NSArray * matchingObjects = [self getAllObjectsForEntityName:entityName predicate:predicate sortDescriptors:sortDescriptors];
//    NSManagedObject * matchingObject = matchingObjects.count > 0 ? [matchingObjects objectAtIndex:0] : nil;
//    if (matchingObject == nil) {
//        matchingObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
//    }
//    return matchingObject;
//}

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
    PFFile * imageFile = [photoServer objectForKey:@"image"];
    photo.imageURL = imageFile.url;
    photo.datetime = photoServer.createdAt;
//    photo.shouldHighlight = [NSNumber numberWithBool:newObjectMadeIndicator]; // This is unnecessary, for now. This value defaults to YES, which is what we want. Otherwise, it is set to NO when an image is viewed.
    return photo;
}

- (Photo *)addOrUpdatePhotoFromServer:(PFObject *)photoServer feelingFromServer:(PFObject *)feelingServer userFromServer:(PFObject *)userServer {
    Photo * photo = [self addOrUpdatePhotoFromServer:photoServer];
    photo.feeling = [self addOrUpdateFeelingFromServer:feelingServer];
    photo.user = [self addOrUpdateUserFromServer:userServer];
    return photo;
}



@end
