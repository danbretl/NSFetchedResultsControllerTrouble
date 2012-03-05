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

- (void)deleteAllLikes {
    NSLog(@"Deleting all likes");
    NSArray * allLikes = [self getAllObjectsForEntityName:@"Like" predicate:nil sortDescriptors:nil];
    for (Like * like in allLikes) {
        [self.managedObjectContext deleteObject:like];
    }
}

- (void) deleteAllLikesNotAssociatedWithUserLocal:(User *)user {
    NSArray * allOtherLikes = [self getAllObjectsForEntityName:@"Like" predicate:[NSPredicate predicateWithFormat:@"user != %@", user] sortDescriptors:nil];
    for (Like * like in allOtherLikes) {
        [self.managedObjectContext deleteObject:like];
    }
}

- (void) deleteAllLikesNotAssociatedWithUserServer:(PFUser *)userServer {
    User * userLocal = (User *)[self getFirstObjectForEntityName:@"User" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", userServer.objectId] usingSortDescriptors:nil];
    [self deleteAllLikesNotAssociatedWithUserLocal:userLocal];
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
    photo.likesCount = [photoServer objectForKey:@"likesCount"];
    photo.hidden = [NSNumber numberWithBool:[[photoServer objectForKey:@"deleted"] boolValue] || [[photoServer objectForKey:@"flagged"] boolValue]];
//    photo.shouldHighlight = [NSNumber numberWithBool:newObjectMadeIndicator]; // This is unnecessary, for now. This value defaults to YES, which is what we want. Otherwise, it is set to NO when an image is viewed.
    return photo;
}

- (Photo *)addOrUpdatePhotoFromServer:(PFObject *)photoServer feelingFromServer:(PFObject *)feelingServer userFromServer:(PFObject *)userServer {
    Photo * photo = [self addOrUpdatePhotoFromServer:photoServer];
    photo.feeling = [self addOrUpdateFeelingFromServer:feelingServer];
    photo.user = [self addOrUpdateUserFromServer:userServer];
    return photo;
}

- (Like *)addOrUpdateLikeFromServer:(PFObject *)likeServer {
    BOOL newObjectMadeIndicator;
    Like * like = (Like *)[self getFirstObjectForEntityName:@"Like" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@", likeServer.objectId] usingSortDescriptors:nil shouldMakeObjectIfNoMatch:YES newObjectMadeIndicator:&newObjectMadeIndicator];
    like.serverID = likeServer.objectId;
    return like;
}

- (Like *)addOrUpdateLikeFromServer:(PFObject *)likeServer photoFromServer:(PFObject *)photoServer userFromServer:(PFObject *)userServer {
    NSLog(@"Add or update like from server, photo.serverID=%@, user.serverID=%@", photoServer.objectId, userServer.objectId);
    Photo * photoLocal = [self addOrUpdatePhotoFromServer:photoServer];
    User * userLocal = [self addOrUpdateUserFromServer:userServer];
    Like * likeLocal = (Like *)[self getFirstObjectForEntityName:@"Like" matchingPredicate:[NSPredicate predicateWithFormat:@"serverID == %@ || (photo.serverID == %@ && user.serverID == %@) || (photoServerID == %@ && userServerID == %@)", likeServer.objectId, photoServer.objectId, userServer.objectId, photoServer.objectId, userServer.objectId] usingSortDescriptors:nil];
    if (likeLocal == nil) {
        NSLog(@"Like did not exist. Creating.");
        likeLocal = [self addOrUpdateLikeFromServer:likeServer];
    } else {
        NSLog(@"Like already existed. Updating.");
        likeLocal.serverID = likeServer.objectId;
    }
    likeLocal.userServerID = userServer.objectId;
    likeLocal.photoServerID = photoServer.objectId;
    likeLocal.photo = photoLocal;
    likeLocal.user = userLocal;
    return likeLocal;
}

@end
