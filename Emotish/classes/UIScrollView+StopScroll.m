//
//  UIScrollView+StopScroll.m
//  Emotish
//
//  Created by Dan Bretl on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIScrollView+StopScroll.h"

@implementation UIScrollView (StopScroll)

- (void)stopScroll {
    CGPoint offset = self.contentOffset;
    offset.x -= 1.0;
    offset.y -= 1.0;
    [self setContentOffset:offset animated:NO];
    offset.x += 1.0;
    offset.y += 1.0;
    [self setContentOffset:offset animated:NO];
}

@end
