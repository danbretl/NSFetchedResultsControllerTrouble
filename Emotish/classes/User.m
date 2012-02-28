//
//  User.m
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "Photo.h"


@implementation User

@dynamic name;
@dynamic photos;
@dynamic serverID;
@dynamic likes;

- (NSArray *)mostRecentPhotos {
    NSArray * sortedPhotos = [self.photos sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO]]];
    return [sortedPhotos subarrayWithRange:NSMakeRange(0, MIN(10, sortedPhotos.count))];
}

@end
