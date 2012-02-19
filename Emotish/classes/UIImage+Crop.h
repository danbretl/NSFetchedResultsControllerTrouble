//
//  UIImage+Crop.h
//  Emotish
//
//  Created by Dan Bretl on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Crop)

- (UIImage *)imageWithEmotishCameraViewCrop;
//- (UIImage *)imageWithCrop:(CGRect)cropRect;
- (UIImage *)imageWithCrop:(CGRect)cropRect;
- (UIImage *)imageScaledDownToEmotishThumb;
- (UIImage *)imageScaledDownToEmotishFull;
- (UIImage *)imageScaledDownToSize:(CGSize)imageSize;
- (UIImage *)imageScaledToSize:(CGSize)imageSize;

+ (NSString *) stringForImageOrientation:(UIImageOrientation)orientation;

- (UIImage *) imageByScalingToSize:(CGSize)targetSize;


@end
