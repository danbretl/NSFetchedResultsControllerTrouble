//
//  SettingsItemTableViewCell.m
//  Emotish
//
//  Created by Dan Bretl on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsItemTableViewCell.h"

@implementation SettingsItemTableViewCell

@synthesize arrowView;
@synthesize textLabelPaddingLeft=_textLabelPaddingLeft, textLabelPaddingRight=_textLabelPaddingRight;
@synthesize highlightedBackgroundColor=_highlightedBackgroundColor;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabelPaddingLeft = 70.0;
        self.textLabelPaddingRight = 25.0;
        self.textLabel.font = [UIFont boldSystemFontOfSize:19.0];
        self.textLabel.textColor = [UIColor colorWithRed:130.0/255.0 green:150.0/255.0 blue:170.0/255.0 alpha:1.0];
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
        self.textLabel.textAlignment = UITextAlignmentLeft;
        self.textLabel.adjustsFontSizeToFitWidth = NO;
        self.highlightedBackgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        UIImage * arrowImage = [UIImage imageNamed:@"settings_arrow.png"];
        self.arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, arrowImage.size.width, arrowImage.size.height)];
        arrowView.contentMode = UIViewContentModeCenter;
        arrowView.image = arrowImage;
        [self.contentView addSubview:self.arrowView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(self.textLabelPaddingLeft, 0, self.contentView.frame.size.width - self.textLabelPaddingLeft - self.textLabelPaddingRight - self.arrowView.frame.size.width, self.contentView.frame.size.height);
    self.arrowView.frame = CGRectMake(self.contentView.frame.size.width - self.textLabelPaddingRight - self.arrowView.frame.size.width, 0, self.arrowView.frame.size.width, self.contentView.frame.size.height);
}

- (void)setTextLabelPaddingLeft:(CGFloat)textLabelPaddingLeft {
    _textLabelPaddingLeft = textLabelPaddingLeft;
    [self setNeedsLayout];
}

- (void)setTextLabelPaddingRight:(CGFloat)textLabelPaddingRight {
    _textLabelPaddingRight = textLabelPaddingRight;
    [self setNeedsLayout];
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor {
    _highlightedBackgroundColor = highlightedBackgroundColor;
    UIView * backgroundView = [[UIView alloc] initWithFrame:self.selectedBackgroundView.frame];
    backgroundView.backgroundColor = self.highlightedBackgroundColor;
    self.selectedBackgroundView = backgroundView;
}

@end
