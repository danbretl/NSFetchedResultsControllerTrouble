//
//  Photo.m
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"
#import "Feeling.h"
#import "User.h"


@implementation Photo

@dynamic filename;
@dynamic datetime;
@dynamic feeling;
@dynamic user;
@dynamic serverID;
@dynamic imageURL;
@dynamic shouldHighlight;
@dynamic likesCount;
@dynamic likes;
@dynamic hidden;
@dynamic thumbURL;

- (BOOL)likeExistsForUserServerID:(NSString *)userServerID {
    BOOL likeExists = NO;
    if (userServerID != nil) {
        NSSet * likesMatchingUser = [self.likes filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"user.serverID == %@", userServerID]];
        likeExists = likesMatchingUser != nil && likesMatchingUser.count > 0;
    }
    return likeExists;
}

- (NSString *)smallestImageAvailableURL {
    return self.thumbURL != nil ? self.thumbURL : self.imageURL;
}

@end
