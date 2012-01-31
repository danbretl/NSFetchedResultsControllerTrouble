//
//  PhotoCell.m
//  Emotish
//
//  Created by Dan Bretl on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoCell.h"
#import "ViewConstants.h"
#import "UIColor+Emotish.h"

const CGFloat PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM =       10.0;
const CGFloat PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL =   5.0;

@implementation PhotoCell

@synthesize photoImageView=_photoImageView;
@synthesize photoCaptionLabel=_photoCaptionLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PC_PHOTO_CELL_IMAGE_MARGIN_HORIZONTAL, 0, VC_PHOTO_CELL_IMAGE_SIDE_LENGTH, VC_PHOTO_CELL_IMAGE_SIDE_LENGTH)];
        self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.photoImageView];
        
        self.photoCaptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.photoImageView.frame.origin.x, CGRectGetMaxY(self.photoImageView.frame) + PC_PHOTO_CELL_IMAGE_MARGIN_BOTTOM, self.photoImageView.frame.size.width, 40.0)];
        self.photoCaptionLabel.textAlignment = UITextAlignmentRight;
        self.photoCaptionLabel.font = [UIFont boldSystemFontOfSize:18.0];
        [self addSubview:self.photoCaptionLabel];
        
        self.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        
    }
    return self;
}

@end
