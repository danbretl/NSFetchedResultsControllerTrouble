//
//  AboutLinksView.m
//  Emotish
//
//  Created by Dan Bretl on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutLinksView.h"
#import "UIColor+Emotish.h"

const CGFloat ALV_LINK_MARGIN_BOTTOM = 5.0;

@interface AboutLinksView ()
@property (strong, nonatomic) NSMutableArray * linkButtons;
@end

@implementation AboutLinksView
@synthesize linkButtons=_linkButtons;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.linkButtons = [NSMutableArray array];
    }
    return self;
}

- (void)addLinkButtonWithText:(NSString *)linkText target:(id)target selector:(SEL)selector {
    
    UIButton * linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    linkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [linkButton setTitle:linkText forState:UIControlStateNormal];
    [linkButton setTitle:linkText forState:UIControlStateHighlighted];
    [linkButton setTitleColor:[UIColor emotishColor] forState:UIControlStateNormal];
    [linkButton setTitleColor:[UIColor lightEmotishColor] forState:UIControlStateHighlighted];
    linkButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    
    [linkButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:linkButton];
    [self.linkButtons addObject:linkButton];
    
    [self setNeedsLayout];
    
}

- (void)removeAllLinkButtons {
    for (UIButton * linkButton in self.linkButtons) {
        [linkButton removeFromSuperview];
    }
    [self.linkButtons removeAllObjects];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    
    if (self.linkButtons.count > 0) {
        CGFloat linkButtonOriginY = 0;
        for (UIButton * linkButton in self.linkButtons) {
            [linkButton sizeToFit];
            linkButton.frame = CGRectMake(0, linkButtonOriginY, self.bounds.size.width, linkButton.frame.size.height);
            linkButtonOriginY = CGRectGetMaxY(linkButton.frame) + ALV_LINK_MARGIN_BOTTOM;
        }
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, linkButtonOriginY);
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, 0);
    }
    
}

@end
