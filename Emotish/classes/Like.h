//
//  Like.h
//  
//
//  Created by Dan Bretl on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, User;

@interface Like : NSManagedObject

@property (nonatomic, retain) Photo * photo;
@property (nonatomic, retain) User * user;
@property (nonatomic, retain) NSString * serverID;
@property (nonatomic, retain) NSString * photoServerID; // This was kind of stupid... Trying to deal with a scenario where we flush photos and feelings, but the user is logged in (so 'Like' objects remain, but lose their connections). Really, we should just stop flushing photos and feelings. Working on getting rid of that need.
@property (nonatomic, retain) NSString * userServerID; // This was kind of stupid... Trying to deal with a scenario where we flush photos and feelings, but the user is logged in(so 'Like' objects remain, but lose their connections). Really, we should just stop flushing photos and feelings. Working on getting rid of that need.

@end
