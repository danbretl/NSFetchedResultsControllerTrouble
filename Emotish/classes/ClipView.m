//
//  ClipView.m
//  Emotish
//
//  Created by Dan Bretl on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ClipView.h"

@implementation ClipView

@synthesize scrollView=_scrollView;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    NSLog(@"%@", event.allTouches);
    if ([self pointInside:point withEvent:event]) {
        return self.scrollView;
    }
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
