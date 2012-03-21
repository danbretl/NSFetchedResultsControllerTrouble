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
@dynamic hiddenLocal;
@dynamic hiddenServer;
@dynamic showInPhotosStrip;
@dynamic userForMainPhoto;

- (void)setHidden:(NSNumber *)hidden {
//    NSLog(@"setHidden");
    [self willChangeValueForKey:@"hidden"];
    [self setPrimitiveValue:hidden forKey:@"hidden"];
    [self didChangeValueForKey:@"hidden"];
//    NSLog(@"  self.feeling = %@", self.feeling);
//    NSLog(@"  self.feeling.datetimeMostRecentPhoto = %@", self.feeling.datetimeMostRecentPhoto);
    [self.feeling updateDatetimeMostRecentPhoto];
//    NSLog(@"  self.feeling = %@", self.feeling);
//    NSLog(@"  self.feeling.datetimeMostRecentPhoto = %@", self.feeling.datetimeMostRecentPhoto);
}

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
