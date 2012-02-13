//
//  UITextFieldWithInset.m
//  Emotish
//
//  Created by Dan Bretl on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITextFieldWithInset.h"

@interface UITextFieldWithInset()
- (CGRect) rectWithInsetForBounds:(CGRect)bounds;
@end

@implementation UITextFieldWithInset

@synthesize textFieldInsets=_textFieldInsets;

- (void)setTextFieldInsets:(UIEdgeInsets)textFieldInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_textFieldInsets, textFieldInsets)) {
        _textFieldInsets = textFieldInsets;
        [self setNeedsLayout];
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [self rectWithInsetForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self rectWithInsetForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return [self rectWithInsetForBounds:bounds];
}

- (CGRect)rectWithInsetForBounds:(CGRect)bounds {
    return CGRectMake(self.textFieldInsets.left, self.textFieldInsets.top, bounds.size.width - self.textFieldInsets.left - self.textFieldInsets.right, bounds.size.height - self.textFieldInsets.top - self.textFieldInsets.bottom);
}

@end
