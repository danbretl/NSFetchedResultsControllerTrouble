//
//  AboutBlurbLinksView.m
//  Emotish
//
//  Created by Dan Bretl on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutBlurbView.h"
#import "UIColor+Emotish.h"

const CGFloat ABLV_PADDING_HORIZONTAL = 20.0;
const CGFloat ABLV_PADDING_TOP = 5.0;
const CGFloat ABLV_PADDING_BOTTOM = 15.0;
const CGFloat ABLV_BLURB_MARGIN_BOTTOM = 10.0;

@interface AboutBlurbView ()
@property (strong, nonatomic) UILabel * blurbLabel;
@property (nonatomic, strong) AboutLinksView * linksView;
@end

@implementation AboutBlurbView
@synthesize blurbLabel=_blurbLabel;
//@synthesize linkButtonsContainer=_linkButtonsContainer;
//@synthesize linkButtons=_linkButtons;
//@synthesize heightNeeded=_heightNeeded;
@synthesize linksView=_linksView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.blurbLabel = [[UILabel alloc] init];
        self.blurbLabel.font = [UIFont boldSystemFontOfSize:19.0];
        self.blurbLabel.textColor = [UIColor accountInputColor];
        self.blurbLabel.numberOfLines = 0;
        self.blurbLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.blurbLabel.textAlignment = UITextAlignmentLeft;
        [self addSubview:self.blurbLabel];
        
        self.linksView = [[AboutLinksView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.linksView];
        
//        self.linkButtonsContainer = [[UIView alloc] init];
//        [self addSubview:self.linkButtonsContainer];
//        
//        self.linkButtons = [NSMutableArray array];
        
    }
    return self;
}

- (void)layoutSubviews {
    
    CGRect blurbLabelFrame = self.blurbLabel.frame;
    if (self.blurbLabel.text) {
        CGSize blurbLabelTextSize = [self.blurbLabel.text sizeWithFont:self.blurbLabel.font constrainedToSize:CGSizeMake(self.bounds.size.width - 2 * ABLV_PADDING_HORIZONTAL, 5000) lineBreakMode:self.blurbLabel.lineBreakMode];
//        CGSize blurbLabelTextSize = [self.blurbLabel.text sizeWithFont:self.blurbLabel.font forWidth:self.bounds.size.width - 2 * ABLV_PADDING_HORIZONTAL lineBreakMode:UILineBreakModeWordWrap];
        blurbLabelFrame = CGRectMake(ABLV_PADDING_HORIZONTAL, ABLV_PADDING_TOP, self.bounds.size.width - 2 * ABLV_PADDING_HORIZONTAL, blurbLabelTextSize.height);
    } else {
        blurbLabelFrame = CGRectZero;
    }
    self.blurbLabel.frame = blurbLabelFrame;
    
    [self.linksView layoutIfNeeded];
    self.linksView.frame = CGRectMake(ABLV_PADDING_HORIZONTAL, CGRectGetMaxY(self.blurbLabel.frame) + ABLV_BLURB_MARGIN_BOTTOM, self.bounds.size.width - 2 * ABLV_PADDING_HORIZONTAL, self.linksView.frame.size.height);
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height = CGRectGetMaxY(self.linksView.frame) + ABLV_PADDING_BOTTOM;
    self.frame = selfFrame;
    
}

//- (CGFloat) heightNeeded {
//
//    CGFloat heightNeeded = ABLV_PADDING_TOP;
//    
//    if (self.blurbLabel.text) {
//        CGSize blurbLabelTextSize = [self.blurbLabel.text sizeWithFont:self.blurbLabel.font constrainedToSize:CGSizeMake(self.bounds.size.width - 2 * ABLV_PADDING_HORIZONTAL, 5000) lineBreakMode:self.blurbLabel.lineBreakMode];
//        heightNeeded += blurbLabelTextSize.height;
//    }
//    
//    heightNeeded += ABLV_BLURB_MARGIN_BOTTOM;
//    
//    if (self.linkButtons.count > 0) {
//        UIButton * linkButton = [self.linkButtons lastObject];
//        heightNeeded += [linkButton sizeThatFits:CGSizeMake(5000, 5000)].height * self.linkButtons.count;
//    }
//    
//    heightNeeded += ABLV_PADDING_BOTTOM;
//    
//    return heightNeeded;
//}

- (void)setBlurbText:(NSString *)blurbText {
    self.blurbLabel.text = blurbText;
    [self setNeedsLayout];
}

@end
