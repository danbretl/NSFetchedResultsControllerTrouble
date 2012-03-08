//
//  UIImage+Crop.m
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Crop.h"
#import "ViewConstants.h"
#import "GalleryConstants.h"

@implementation UIImage(Crop)

static inline double radians (double degrees) { return degrees * M_PI/180; }

// This new version wasn't going well at all. Probably didn't stick with it / work with it long enough.
//- (UIImage *)imageWithEmotishCrop {
//    
//    NSLog(@"imageWithEmotishCrop for image with size %@, orientation %@", NSStringFromCGSize(self.size), [UIImage stringForImageOrientation:self.imageOrientation]);
//    
//    BOOL verticalImage = self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationRight;
//    
//    CGFloat imageCropLength = MIN(self.size.width, self.size.height);
//    CGFloat imageCropLongerSideOriginPercentage = CAMERA_OVERLAY_TOP_BAR_HEIGHT / CAMERA_VIEW_SCREEN_HEIGHT;
//    NSLog(@"imageCropLongerSideOriginPercentage = CAMERA_OVERLAY_TOP_BAR_HEIGHT (%f) / CAMERA_VIEW_SCREEN_HEIGHT (%f) = (%f)", CAMERA_OVERLAY_TOP_BAR_HEIGHT, CAMERA_VIEW_SCREEN_HEIGHT, imageCropLongerSideOriginPercentage);
//    CGFloat imageCropX = verticalImage ? 0 : floorf(imageCropLongerSideOriginPercentage * self.size.width);
//    CGFloat imageCropY = verticalImage ? floorf(imageCropLongerSideOriginPercentage * self.size.height) : 0;
//    return [self croppedImage:CGRectMake(0, 0, imageCropLength, imageCropLength)];
////    return [self imageWithCrop:CGRectMake(imageCropX, imageCropY, imageCropLength, imageCropLength)];
//    
//}

- (UIImage *)imageWithEmotishCameraViewCrop {
//    BOOL verticalImage = self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationRight;
    
//    NSLog(@"imageWithEmotishCrop\n  size : \t\t%@\n  verticalImage : \t%d", NSStringFromCGSize(self.size), verticalImage);
    
    CGFloat imageCropLength = MIN(self.size.width, self.size.height);
    BOOL isImageWiderThanTall = self.size.width > self.size.height;
    
    CGFloat imageCropLongerSideOriginPercentage = CAMERA_VIEW_SCREEN_DISPLAY_ORIGIN_Y / CAMERA_VIEW_SCREEN_HEIGHT;
    CGFloat imageCropX =  isImageWiderThanTall ? floorf(imageCropLongerSideOriginPercentage * self.size.width)  : 0;
    CGFloat imageCropY = !isImageWiderThanTall ? floorf(imageCropLongerSideOriginPercentage * self.size.height) : 0;
    return [self imageWithCrop:CGRectMake(imageCropX, imageCropY, imageCropLength, imageCropLength)];
}

//- (UIImage *)imageWithSmarterCrop {
//    
//    BOOL verticalImage = self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationRight;
//    
////    NSLog(@"imageWithEmotishCrop\n  size : \t\t%@\n  verticalImage : \t%d", NSStringFromCGSize(self.size), verticalImage);
//    
//    CGFloat imageCropLength = MIN(self.size.width, self.size.height);
//    
//    CGFloat imageCropLongerSideOriginPercentage = CAMERA_VIEW_SCREEN_DISPLAY_ORIGIN_Y / CAMERA_VIEW_SCREEN_HEIGHT;
//    CGFloat imageCropX = verticalImage ? 0 : floorf(imageCropLongerSideOriginPercentage * self.size.width);
//    CGFloat imageCropY = verticalImage ? floorf(imageCropLongerSideOriginPercentage * self.size.height) : 0;
//    return [self imageWithCrop:CGRectMake(imageCropX, imageCropY, imageCropLength, imageCropLength)];
//    
//}

- (UIImage *)imageWithCrop:(CGRect)cropRect {
    NSLog(@"    Cropping image with size %@ to rect %@", NSStringFromCGSize(self.size), NSStringFromCGRect(cropRect));
    if (self.scale > 1.0f) {
        NSLog(@"      Scale is greater than 1.0f");
        cropRect = CGRectMake(cropRect.origin.x     * self.scale,
                              cropRect.origin.y     * self.scale,
                              cropRect.size.width   * self.scale,
                              cropRect.size.height  * self.scale);
    }
    if (self.imageOrientation == UIImageOrientationLeft ||
        self.imageOrientation == UIImageOrientationRight) {
        cropRect = CGRectMake(cropRect.origin.y, cropRect.origin.x, cropRect.size.height, cropRect.size.width);
    }
    
    NSLog(@"      Original image scale=%f orientation=%@", self.scale, [UIImage stringForImageOrientation:self.imageOrientation]);
    NSLog(@"      Original imageRef size is %lu %lu", CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    NSLog(@"      Cropped imageRef size is %lu %lu", CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    UIImage * result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    NSLog(@"    Ended with image with size %@", NSStringFromCGSize(result.size));
    return result;
}

//- (UIImage *)imageWithCrop:(CGRect)cropRect {
//    if (self.scale > 1.0f) {
//        cropRect = CGRectMake(cropRect.origin.x     * self.scale,
//                              cropRect.origin.y     * self.scale,
//                              cropRect.size.width   * self.scale,
//                              cropRect.size.height  * self.scale);
//    }
//    
//    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
//    UIImage * result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:UIImageOrientationUp];
//    CGImageRelease(imageRef);
//    return result;
//}

+ (NSString *) stringForImageOrientation:(UIImageOrientation)orientation {
    NSString * string = nil;
    switch (orientation) {
        case UIImageOrientationUp: 
            string = @"UIImageOrientationUp"; break;
        case UIImageOrientationDown:
            string = @"UIImageOrientationDown"; break;
        case UIImageOrientationLeft:
            string = @"UIImageOrientationLeft"; break;
        case UIImageOrientationRight:
            string = @"UIImageOrientationRight"; break;
        case UIImageOrientationUpMirrored:
            string = @"UIImageOrientationUpMirrored"; break;
        case UIImageOrientationDownMirrored:
            string = @"UIImageOrientationDownMirrored"; break;
        case UIImageOrientationLeftMirrored:
            string = @"UIImageOrientationLeftMirrored"; break;
        case UIImageOrientationRightMirrored:
            string = @"UIImageOrientationRightMirrored"; break;
        default:
            break;
    }
    return string;
}

- (UIImage *)imageScaledToSize:(CGSize)imageSize {
    UIGraphicsBeginImageContext(imageSize);
    [self drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageScaledDownToSize:(CGSize)imageSize {
    if (self.size.width > imageSize.width ||
        self.size.height > imageSize.height) {
        return [self imageScaledToSize:imageSize];
    } else {
        return self;
    }
}

- (UIImage *)imageScaledDownToEmotishThumb {
    CGFloat thumbDimension2X = GC_FEELING_IMAGE_SIDE_LENGTH * 2.0;
    return [self imageScaledDownToSize:CGSizeMake(thumbDimension2X, thumbDimension2X)];
}

- (UIImage *)imageScaledDownToEmotishFull {
    CGFloat screenMinDimension2X = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) * 2.0;
    return [self imageScaledDownToSize:CGSizeMake(screenMinDimension2X, screenMinDimension2X)];
}

- (UIImage *) imageByScalingToSize:(CGSize)targetSize {
    
    UIImage* sourceImage = self; 
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }       
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage; 
    
}

@end
