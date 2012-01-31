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

@interface CoreDataManager : NSObject

- (id) initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

- (void) saveCoreData;
- (NSArray *) getAllObjectsForEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;
- (NSManagedObject *) getOrMakeObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors;

- (Photo *) addPhotoWithFilename:(NSString *)filename forFeelingWord:(NSString *)feelingWord fromUsername:(NSString *)username; // This method will add a new Photo object to the database. It will connect that Photo to an existing Feeling object in the database for the given feeling word, or else create one. Likewise, it will connect the Photo to an existing User object matching the given username, or else create a new one.

@end
