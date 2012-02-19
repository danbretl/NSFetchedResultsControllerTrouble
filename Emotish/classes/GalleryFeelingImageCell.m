//
//  GalleryFeelingImageCell.m
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryFeelingImageCell.h"
#import "GalleryConstants.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat GFIC_HIGHLIGHT_TAB_VISIBLE_OPACITY = 0.75;
const CGFloat GFIC_HIGHLIGHT_TAB_VISIBLE_ANIMATION_DURATION = 0.25;

@interface GalleryFeelingImageCell()
- (void) buttonTouched:(UIButton *)button;
@end

@implementation GalleryFeelingImageCell

//@synthesize feelingImageView=_feelingImageView;
@synthesize button=_button, highlightTab=_highlightTab;
@synthesize feelingIndex=_feelingIndex, imageIndex=_imageIndex;
@synthesize feelingCell=_feelingCell;
@synthesize delegate=_delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        BOOL debugging = NO;
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = self.bounds;
        self.button.adjustsImageWhenHighlighted = NO;
        self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.button.contentEdgeInsets = UIEdgeInsetsMake(GC_FEELING_IMAGE_MARGIN_VERTICAL, 0, GC_FEELING_IMAGE_MARGIN_VERTICAL, GC_FEELING_IMAGE_MARGIN_RIGHT);
        [self.button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        
        UIImage * highlightTabImage = [UIImage imageNamed:@"gallery_image_highlight_tab.png"];
        self.highlightTab = [[UIView alloc] initWithFrame:CGRectMake(self.button.frame.origin.x, CGRectGetMaxY(self.button.frame) - GC_FEELING_IMAGE_MARGIN_VERTICAL - highlightTabImage.size.height, highlightTabImage.size.width, highlightTabImage.size.height)];
        self.highlightTab.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        self.highlightTab.backgroundColor = [UIColor colorWithPatternImage:highlightTabImage];
        [self addSubview:self.highlightTab];
        [self setHighlightTabVisible:NO animated:NO];
        
        self.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        
        if (debugging) {
//            self.feelingImageView.backgroundColor = [UIColor cyanColor];
        }
        
    }
    return self;
}

- (void)buttonTouched:(UIButton *)button {
    [self.delegate feelingImageCellButtonTouched:self];
}

- (void)setHighlightTabVisible:(BOOL)visibility animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? GFIC_HIGHLIGHT_TAB_VISIBLE_ANIMATION_DURATION : 0.0 animations:^{
        self.highlightTab.alpha = visibility ? GFIC_HIGHLIGHT_TAB_VISIBLE_OPACITY : 0.0;
    }];
}

@end
