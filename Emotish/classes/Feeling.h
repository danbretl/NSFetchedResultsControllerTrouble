//
//  Feeling.h
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Feeling : NSManagedObject
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSSet * photos;
@property (nonatomic, retain) NSString * serverID;
//@property (nonatomic, retain) NSNumber * photosVisibleExist; // This is SO DUMB
//@property (nonatomic, readonly) NSNumber * foo;
@end

@interface Feeling (CoreDataGeneratedAccessors)
- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;
@end

@interface Feeling (Convenience)
@property (nonatomic, strong, readonly) NSSet * photosVisible;
//@property (nonatomic, readonly) NSNumber * photosVisibleExist;
@property (nonatomic, strong, readonly) NSArray * mostRecentPhotos;
@end
