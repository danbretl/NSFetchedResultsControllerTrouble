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

@synthesize feelingImageView=_feelingImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        BOOL debugging = NO;
        
        self.feelingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, GC_FEELING_IMAGE_MARGIN_VERTICAL, GC_FEELING_IMAGE_SIDE_LENGTH, GC_FEELING_IMAGE_SIDE_LENGTH)];
        self.feelingImageView.backgroundColor = [UIColor clearColor];
        self.feelingImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.feelingImageView];
        
        self.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        
        if (debugging) {
            self.feelingImageView.backgroundColor = [UIColor cyanColor];
            self.feelingImageView.image = [UIImage imageNamed:@"protoImage1.jpg"];
        }
        
    }
    return self;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

@end
