//
//  User.h
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Like;

@interface User : NSManagedObject
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet * photos;
@property (nonatomic, retain) NSString * serverID;
@property (nonatomic, retain) NSSet * likes;
@end

@interface User (CoreDataGeneratedAccessors)
- (void)addLikesObject:(Like *)value;
- (void)removeLikesObject:(Like *)value;
- (void)addLikes:(NSSet *)values;
- (void)removeLikes:(NSSet *)values;
- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;
@end

@interface User (Convenience)
@property (nonatomic, strong, readonly) NSArray * mostRecentPhotos;
@end