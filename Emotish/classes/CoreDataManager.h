//
//  CoreDataManager.h
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"
#import "Feeling.h"
#import "User.h"
#import "Like.h"
#import <Parse/Parse.h>

@interface CoreDataManager : NSObject

- (id) initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

- (void) saveCoreData;
- (NSArray *) getAllObjectsForEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;
//- (NSManagedObject *) getOrMakeObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors;
- (NSManagedObject *) getFirstObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors shouldMakeObjectIfNoMatch:(BOOL)shouldMakeObjectIfNoMatch newObjectMadeIndicator:(BOOL *)newObjectMadeIndicator;
- (NSManagedObject *) getFirstObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors;
- (void) deleteAllLikes;

//- (NSArray *) getFeelings;
//- (Feeling *) getFeelingAlphabeticallyBeforeFeeling:(Feeling *)feeling;
//- (Feeling *) getFeelingAlphabeticallyAfterFeeling:(Feeling *)feeling;

// The following methods will get an existing object that matches the given server object's objectID (serverID, locally speaking), or will create one if it doesn't exist already.
- (Feeling *) addOrUpdateFeelingFromServer:(PFObject *)feelingServer;
- (User *) addOrUpdateUserFromServer:(PFObject *)userServer;
//
- (Photo *) addOrUpdatePhotoFromServer:(PFObject *)photoServer;
- (Photo *) addOrUpdatePhotoFromServer:(PFObject *)photoServer feelingFromServer:(PFObject *)feelingServer userFromServer:(PFObject *)userServer;
//
- (Like *) addOrUpdateLikeFromServer:(PFObject *)likeServer;
- (Like *) addOrUpdateLikeFromServer:(PFObject *)likeServer photoFromServer:(PFObject *)photoServer userFromServer:(PFObject *)userServer;

@end
