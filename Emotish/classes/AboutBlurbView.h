//
//  AboutBlurbLinksView.h
//  Emotish
//
//  Created by Dan Bretl on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutLinksView.h"

@interface AboutBlurbView : UIView

- (void) setBlurbText:(NSString *)blurbText;
@property (nonatomic, strong, readonly) AboutLinksView * linksView;

//@property (nonatomic, readonly) CGFloat heightNeeded;

@end