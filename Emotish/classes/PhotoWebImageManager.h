//
//  PhotoWebImageManager.h
//  Emotish
//
//  Created by Dan Bretl on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageManager.h"

@protocol PhotoWebImageManagerDelegate;

@interface PhotoWebImageManager : NSObject <SDWebImageManagerDelegate>

@property (strong, nonatomic) NSString * photoServerID;
@property (unsafe_unretained, nonatomic) id<PhotoWebImageManagerDelegate> delegate;

+ (PhotoWebImageManager *) photoWebImageManagerForPhotoServerID:(NSString *)photoServerID withDelegate:(id<PhotoWebImageManagerDelegate>)delegate;

@end

@protocol PhotoWebImageManagerDelegate <NSObject>
- (void)photoWebImageManager:(PhotoWebImageManager *)photoWebImangeManager withWebImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image;
- (void)photoWebImageManager:(PhotoWebImageManager *)photoWebImangeManager withWebImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error;
@end
