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
@property (nonatomic, retain) NSSet *photos;
@end

@interface Feeling (CoreDataGeneratedAccessors)
- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;
@end

@interface Feeling (Convenience)
@property (nonatomic, strong, readonly) NSArray * mostRecentPhotos;
@end