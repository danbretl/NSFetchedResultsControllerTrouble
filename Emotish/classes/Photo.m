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
@dynamic imageURL;
@dynamic hidden;
@dynamic thumbURL;
@dynamic hiddenLocal;
@dynamic hiddenServer;

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

@end
