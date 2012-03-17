//
//  WebFetch.h
//  
//
//  Created by Dan Bretl on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feeling, Photo, User;

@interface WebFetch : NSManagedObject

@property (nonatomic, retain) NSDate * endDatetime;
@property (nonatomic, retain) NSDate * startDatetime;
@property (nonatomic, retain) Feeling * feeling;
@property (nonatomic, retain) User * user;
@end
