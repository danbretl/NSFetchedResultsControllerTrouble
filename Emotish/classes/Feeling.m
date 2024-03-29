//
//  Feeling.m
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Feeling.h"
#import "Photo.h"


@implementation Feeling

@dynamic word;
@dynamic photos;
@dynamic serverID;
@dynamic datetimeMostRecentPhoto;
@dynamic webLoadDate;

- (NSSet *)photosVisible {
    return [self.photos filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"hidden == NO"]];
}

- (NSNumber *)photosVisibleExist {
    return [NSNumber numberWithBool:self.photosVisible.count > 0];
}

- (NSArray *)mostRecentPhotosVisible {
    NSArray * sortedPhotos = [self.photosVisible sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO]]];
    return [sortedPhotos subarrayWithRange:NSMakeRange(0, MIN(10, sortedPhotos.count))];
}

- (Photo *)mostRecentPhotoVisible {
    NSArray * mostRecentPhotosVisible = self.mostRecentPhotosVisible;
    Photo * mostRecentPhotoVisible = nil;
    if (mostRecentPhotosVisible != nil && mostRecentPhotosVisible.count > 0) {
        mostRecentPhotoVisible = [mostRecentPhotosVisible objectAtIndex:0];
    }
    return mostRecentPhotoVisible;
}

- (void)updateDatetimeMostRecentPhoto {
    self.datetimeMostRecentPhoto = self.mostRecentPhotoVisible.datetime;
}

@end