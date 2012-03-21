//
//  AboutLinksView.h
//  Emotish
//
//  Created by Dan Bretl on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutLinksView : UIView

- (void) addLinkButtonWithText:(NSString *)linkText target:(id)target selector:(SEL)selector;
- (void) removeAllLinkButtons;

@end
