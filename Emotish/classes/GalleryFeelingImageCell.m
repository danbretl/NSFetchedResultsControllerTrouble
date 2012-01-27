//
//  GalleryFeelingImageCell.m
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryFeelingImageCell.h"
#import "GalleryConstants.h"

@implementation GalleryFeelingImageCell

//@synthesize feelingImageView=_feelingImageView;
@synthesize button=_button;
@synthesize feelingIndex=_feelingIndex, imageIndex=_imageIndex;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        BOOL debugging = NO;
        
//        self.feelingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, GC_FEELING_IMAGE_MARGIN_VERTICAL, GC_FEELING_IMAGE_SIDE_LENGTH, GC_FEELING_IMAGE_SIDE_LENGTH)];
//        self.feelingImageView.backgroundColor = [UIColor clearColor];
//        self.feelingImageView.contentMode = UIViewContentModeScaleAspectFit;
//        [self addSubview:self.feelingImageView];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = self.bounds;
        self.button.adjustsImageWhenHighlighted = NO;
        self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.button.contentEdgeInsets = UIEdgeInsetsMake(GC_FEELING_IMAGE_MARGIN_VERTICAL, 0, GC_FEELING_IMAGE_MARGIN_VERTICAL, GC_FEELING_IMAGE_MARGIN_RIGHT);
        [self addSubview:self.button];
        
        self.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        
        if (debugging) {
//            self.feelingImageView.backgroundColor = [UIColor cyanColor];
        }
        
    }
    return self;
}

@end
