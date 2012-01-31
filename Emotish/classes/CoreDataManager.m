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

- (NSManagedObject *) getOrMakeObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors {
    NSArray * matchingObjects = [self getAllObjectsForEntityName:entityName predicate:predicate sortDescriptors:sortDescriptors];
    NSManagedObject * matchingObject = matchingObjects.count > 0 ? [matchingObjects objectAtIndex:0] : nil;
    if (matchingObject == nil) {
        matchingObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
    }
    return matchingObject;
}

- (Photo *) addPhotoWithFilename:(NSString *)filename forFeelingWord:(NSString *)feelingWord fromUsername:(NSString *)username {
    
    Photo * photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    photo.filename = filename;
    photo.datetime = [NSDate date];
    
    Feeling * feeling = (Feeling *)[self getOrMakeObjectForEntityName:@"Feeling" matchingPredicate:[NSPredicate predicateWithFormat:@"word == %@", feelingWord] usingSortDescriptors:nil];
    feeling.word = feelingWord;
    photo.feeling = feeling;
    
    User * user = (User *)[self getOrMakeObjectForEntityName:@"User" matchingPredicate:[NSPredicate predicateWithFormat:@"name == %@", username] usingSortDescriptors:nil];
    user.name = username;
    photo.user = user;
    
    [self saveCoreData];
    
    return photo;
    
}



@end
