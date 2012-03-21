//
//  SettingsSectionHeaderView.m
//  Emotish
//
//  Created by Dan Bretl on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsSectionHeaderView.h"

const CGFloat SSHV_PADDING_LEFT_DEFAULT  = 20.0;
const CGFloat SSHV_PADDING_RIGHT_DEFAULT = 20.0;

@interface SettingsSectionHeaderView ()
@property (nonatomic, strong) UIView * borderBottomView;
@property (nonatomic, strong) UILabel * label;
@end

@implementation SettingsSectionHeaderView

@synthesize borderBottomColor=_borderBottomColor, labelText=_labelText, labelTextColor=_labelTextColor;
@synthesize borderBottomView=_borderBottomView, label=_label, button=_button;
@synthesize paddingLeft=_paddingLeft, paddingRight=_paddingRight;
@synthesize borderBottomVisible=_borderBottomVisible;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.paddingLeft  = SSHV_PADDING_LEFT_DEFAULT;
        self.paddingRight = SSHV_PADDING_RIGHT_DEFAULT;
        
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        
        self.borderBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
        self.borderBottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.borderBottomView];
        self.borderBottomVisible = YES;
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(self.paddingLeft, 0, self.frame.size.width - (self.paddingLeft + self.paddingRight), self.frame.size.height)];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.label.font = [UIFont boldSystemFontOfSize:40.0];
        self.label.textAlignment = UITextAlignmentLeft;
        self.label.adjustsFontSizeToFitWidth = NO;
        self.label.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = self.bounds;
        self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.button];
        
    }
    return self;
}

- (void)layoutSubviews {
    self.label.frame = CGRectMake(self.paddingLeft, 0, self.frame.size.width - (self.paddingLeft + self.paddingRight), self.frame.size.height);
}

- (void)setPaddingLeft:(CGFloat)paddingLeft {
    _paddingLeft = paddingLeft;
    [self setNeedsLayout];
}

- (void)setPaddingRight:(CGFloat)paddingRight {
    _paddingRight = paddingRight;
    [self setNeedsLayout];
}

- (void)setBorderBottomColor:(UIColor *)borderBottomColor {
    _borderBottomColor = borderBottomColor;
    self.borderBottomView.backgroundColor = [self.borderBottomColor colorWithAlphaComponent:0.8];
}

- (void)setBorderBottomVisible:(BOOL)borderBottomVisible {
    _borderBottomVisible = borderBottomVisible;
    self.borderBottomView.hidden = !self.borderBottomVisible;
}

- (void)setLabelTextColor:(UIColor *)labelTextColor {
    _labelTextColor = labelTextColor;
    self.label.textColor = self.labelTextColor;
}

- (void)setLabelText:(NSString *)labelText {
    _labelText = labelText;
    self.label.text = self.labelText;
}

@end
