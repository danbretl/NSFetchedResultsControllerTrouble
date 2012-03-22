//
//  CoreDataManager.h
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Photo.h"
#import "Feeling.h"
#import "User.h"

@interface CoreDataManager : NSObject

- (id) initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

- (void) saveCoreData;
- (NSArray *) getAllObjectsForEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;
- (NSManagedObject *) getFirstObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors shouldMakeObjectIfNoMatch:(BOOL)shouldMakeObjectIfNoMatch newObjectMadeIndicator:(BOOL *)newObjectMadeIndicator;
- (NSManagedObject *) getFirstObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors;
- (void) updateAllFeelingDatetimes;

- (void) processPhotosFromServer:(NSArray *)photosFromServer;

// The following methods will get an existing object that matches the given server object's objectID (serverID, locally speaking), or will create one if it doesn't exist already.
- (User *) addOrUpdateUserFromServer:(PFObject *)userServer;
- (Photo *) addOrUpdatePhotoFromServer:(PFObject *)photoServer feelingFromServer:(PFObject *)feelingServer userFromServer:(PFObject *)userServer;

@end

@interface CoreDataManager (Debugging)
- (void) debugLogAllFeelingsAlphabetically;
- (void) debugLogAllFeelingsChronologicallyDatetimeMostRecentPhoto;
@end
