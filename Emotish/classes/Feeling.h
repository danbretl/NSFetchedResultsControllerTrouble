//
//  Feeling.h
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;//, WebFetch;

@interface Feeling : NSManagedObject
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSSet * photos;
@property (nonatomic, retain) NSString * serverID;
@property (nonatomic, retain) NSDate * datetimeMostRecentPhoto;
//@property (nonatomic, retain) NSSet *webFetches;
@property (nonatomic, retain) NSDate * webLoadDate;
@end

@interface Feeling (CoreDataGeneratedAccessors)
- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;
//- (void)addWebFetchesObject:(WebFetch *)value;
//- (void)removeWebFetchesObject:(WebFetch *)value;
//- (void)addWebFetches:(NSSet *)values;
//- (void)removeWebFetches:(NSSet *)values;
@end

@interface Feeling (Convenience)
@property (nonatomic, strong, readonly) NSSet * photosVisible;
@property (nonatomic, readonly) NSNumber * photosVisibleExist;
@property (nonatomic, strong, readonly) NSArray * mostRecentPhotosVisible;
@property (nonatomic, strong, readonly) Photo * mostRecentPhotoVisible;
- (void) updateDatetimeMostRecentPhoto;
@end
