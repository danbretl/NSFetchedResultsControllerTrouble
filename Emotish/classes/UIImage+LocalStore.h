//
//  UIImage+LocalStore.h
//  Emotish
//
//  Created by Dan Bretl on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * LOCAL_IMAGE_SEED_PREFIX = @"emotish_seed_data_";

@interface UIImage (LocalStore)

+ (void) saveImage:(UIImage*)image withFilename:(NSString *)filename;
+ (UIImage *) loadImageWithFilename:(NSString *)filename;
+ (NSString *) pathForLocalImageWithFilename:(NSString *)filename;

+ (UIImage *) localTestImageWithFilename:(NSString *)filename;


@end