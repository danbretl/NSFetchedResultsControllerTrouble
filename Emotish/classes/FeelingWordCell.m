//
//  FeelingWordCell.m
//  Emotish
//
//  Created by Dan Bretl on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeelingWordCell.h"
#import "UIColor+Emotish.h"
#import "ViewConstants.h"

@implementation FeelingWordCell

@synthesize textLabelPadding=_textLabelPadding;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.textColor = [UIColor feelingColor];
        self.textLabel.highlightedTextColor = [UIColor userColor];
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabelPadding = UIEdgeInsetsMake(-1, -1, -1, -1);
        self.textLabelPadding = UIEdgeInsetsZero;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.textLabel.highlighted = highlighted;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.textLabel.highlighted = selected;
}

- (void)setTextLabelPadding:(UIEdgeInsets)textLabelPadding {
    if (!UIEdgeInsetsEqualToEdgeInsets(_textLabelPadding, textLabelPadding)) {
        _textLabelPadding = textLabelPadding;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(self.textLabelPadding.left, self.textLabelPadding.top, self.bounds.size.width - self.textLabelPadding.left - self.textLabelPadding.right, self.bounds.size.height - self.textLabelPadding.top - self.textLabelPadding.bottom);
}

@end
