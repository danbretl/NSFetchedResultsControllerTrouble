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

// Modification:
/*
 The ClipView solution above worked for me, but I had to do a different -[UIView hitTest:withEvent:] implementation. Ed Marty's version didn't get user interaction working with vertical scrollviews I have inside the horizontal one.
 
 The following version worked for me:
 
 -(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
 {
 UIView* child = nil;
 if ((child = [super hitTest:point withEvent:event]) == self)
 return self.scrollView;         
 return child;
 }
 */

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView * child = nil;
    if ((child = [super hitTest:point withEvent:event]) == self) {
        return self.scrollView;
    } else {
        return child;
    }
    
//    NSLog(@"%@", event.allTouches);
//    if ([self pointInside:point withEvent:event]) {
//        return self.scrollView;
//    }
//    return nil;
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
