//
//  UIView+GetFirstResponder.m
//  Kwiqet
//
//  Created by Dan Bretl on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIView+GetFirstResponder.h"

@implementation UIView (GetFirstResponder)

- (UIView *)getFirstResponder {

    if (self.isFirstResponder) {        
        return self;     
    }
    
    for (UIView * subView in self.subviews) {
        UIView * firstResponder = [subView getFirstResponder];
        
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    
    return nil;
    
}

@end
