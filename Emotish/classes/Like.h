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

@end
