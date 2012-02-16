//
//  Photo.h
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feeling, User;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSDate * datetime;
@property (nonatomic, retain) Feeling *feeling;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSString * serverID;
@property (nonatomic, retain) NSString * imageURL;

@end
