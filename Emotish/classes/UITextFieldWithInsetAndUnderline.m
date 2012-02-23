//
//  UITextFieldWithInsetAndUnderline.m
//  Emotish
//
//  Created by Dan Bretl on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITextFieldWithInsetAndUnderline.h"

@interface UITextFieldWithInsetAndUnderline()
- (void) initWithFrameOrCoder;
@end

@implementation UITextFieldWithInsetAndUnderline

@synthesize underlineView=_underlineView;

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
    self.underlineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bounds) - 1, self.bounds.size.width, 1)];
    self.underlineView.backgroundColor = [UIColor colorWithRed:207.0/255.0 green:205.0/255.0 blue:205.0/255.0 alpha:1.0];
    self.underlineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.underlineView];
}

@end
