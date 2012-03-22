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

@dynamic datetime;
@dynamic feeling;
@dynamic user;
@dynamic serverID;
@dynamic hidden;
@dynamic hiddenLocal;
@dynamic hiddenServer;

- (void)setHidden:(NSNumber *)hidden {
    [self willChangeValueForKey:@"hidden"];
    [self setPrimitiveValue:hidden forKey:@"hidden"];
    [self didChangeValueForKey:@"hidden"];
    [self.feeling updateDatetimeMostRecentPhoto];
}

@end
