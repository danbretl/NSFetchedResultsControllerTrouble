//
//  PhotoView.m
//  Emotish
//
//  Created by Dan Bretl on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoView.h"
#import "ViewConstants.h"
#import "UIColor+Emotish.h"

const CGFloat PC_PHOTO_CELL_LABEL_FONT_SIZE =           20.0;

@interface PhotoView()
- (void) initWithFrameOrCoder;
- (void) buttonTouched:(UIButton *)button;
@end

@implementation PhotoView

@synthesize button=_button;
@synthesize photoImageView=_photoImageView;
@synthesize photoCaptionLabel=_photoCaptionLabel;
@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithFrameOrCoder];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initWithFrameOrCoder];
    }
    return self;
}

- (void) initWithFrameOrCoder {
    
    self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, 0, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH, PC_PHOTO_CELL_IMAGE_SIDE_LENGTH)];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.photoImageView];
    
    self.photoCaptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.photoImageView.frame.origin.x, CGRectGetMaxY(self.photoImageView.frame) + PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM, self.photoImageView.frame.size.width, PC_PHOTO_CELL_LABEL_HEIGHT)];
    self.photoCaptionLabel.textAlignment = UITextAlignmentRight;
    self.photoCaptionLabel.font = [UIFont boldSystemFontOfSize:PC_PHOTO_CELL_LABEL_FONT_SIZE];
    [self addSubview:self.photoCaptionLabel];
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = self.bounds;
    self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];
    
//    self.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    
    BOOL debugging = NO;
    if (debugging) {
        self.photoImageView.backgroundColor = [UIColor blueColor];
        self.photoCaptionLabel.backgroundColor = [UIColor greenColor];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    
}

- (void)buttonTouched:(UIButton *)button {
    [self.delegate photoViewTouched:self];
}

@end