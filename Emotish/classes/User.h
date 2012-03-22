//
//  User.h
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Like;//, WebFetch;

@interface User : NSManagedObject
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * serverID;
@property (nonatomic, retain) NSDate * webLoadDate;
@property (nonatomic, retain) NSSet * photos;
@end

@interface User (CoreDataGeneratedAccessors)
- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;
@end

@interface User (Convenience)
@property (nonatomic, strong, readonly) NSSet * photosVisible;
@property (nonatomic, readonly) NSNumber * photosVisibleExist;
@property (nonatomic, strong, readonly) NSArray * mostRecentPhotosVisible;
@property (nonatomic, strong, readonly) Photo * mostRecentPhotoVisible;
@end