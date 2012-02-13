//
//  UIImage+LocalStore.m
//  Emotish
//
//  Created by Dan Bretl on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+LocalStore.h"

@implementation UIImage (LocalStore)

+ (void) saveImage:(UIImage*)image withFilename:(NSString *)filename {
    
    NSString * imagePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpg", [filename stringByReplacingOccurrencesOfString:@".jpg" withString:@""]]];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath atomically:YES];
//    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    
}

+ (UIImage *) loadImageWithFilename:(NSString *)filename {
    
    NSString  * imagePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.png", [filename stringByReplacingOccurrencesOfString:@".png" withString:@""]]];
    UIImage * image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
    
}

+ (NSString *)pathForLocalImageWithFilename:(NSString *)filename {
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpg", [filename stringByReplacingOccurrencesOfString:@".jpg" withString:@""]]];
    NSLog(@"pathForLocalImageWithFilename:%@ = %@", filename, path);
    return path;
}

+ (UIImage *)localTestImageWithFilename:(NSString *)filename {
    
    UIImage * localImage = nil;
    
    if ([filename rangeOfString:LOCAL_IMAGE_SEED_PREFIX].location == NSNotFound) {
//        localImage = [UIImage loadImageWithFilename:filename];
    } else {
        filename = [filename stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
        localImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", filename]];
    }
    
    return localImage;
    
}

@end
