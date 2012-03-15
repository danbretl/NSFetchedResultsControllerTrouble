//
//  PhotoWebImageManager.m
//  Emotish
//
//  Created by Dan Bretl on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoWebImageManager.h"
#import "SDImageCache.h"

@implementation PhotoWebImageManager

@synthesize photoServerID=_photoServerID;
@synthesize delegate=_delegate;

+ (PhotoWebImageManager *)photoWebImageManagerForPhotoServerID:(NSString *)photoServerID withDelegate:(id<PhotoWebImageManagerDelegate>)delegate {
    PhotoWebImageManager * photoWebImageManager = [[PhotoWebImageManager alloc] init];
    photoWebImageManager.photoServerID = photoServerID;
    photoWebImageManager.delegate = delegate;
    return photoWebImageManager;
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    NSLog(@"PhotoWebImageManager %@ - webImageManager:%@ didFinishWithImage:%@ - forwarding to delegate %@", self, imageManager, image, self.delegate);
    [self.delegate photoWebImageManager:self withWebImageManager:imageManager didFinishWithImage:image];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error {
    NSLog(@"PhotoWebImageManager %@ - webImageManager:%@ didFailWithError:%@ - forwarding to delegate %@", self, imageManager, error, self.delegate);
    [self.delegate photoWebImageManager:self withWebImageManager:imageManager didFailWithError:error];
}

@end
