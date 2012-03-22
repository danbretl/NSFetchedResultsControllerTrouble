//
//  Photo.h
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feeling, User, Like;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * datetime;
@property (nonatomic, retain) Feeling *feeling;
@property (nonatomic, retain) User * user;
@property (nonatomic, retain) NSString * serverID;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * hidden;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSNumber * hiddenLocal;
@property (nonatomic, retain) NSNumber * hiddenServer;

@end