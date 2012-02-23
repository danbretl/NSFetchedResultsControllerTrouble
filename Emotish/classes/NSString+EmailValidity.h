//
//  NSString+EmailValidity.h
//  Emotish
//
//  Created by Dan Bretl on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EmailValidity)

@property (nonatomic, readonly) BOOL isPotentialEmailAddress;
@property (nonatomic, readonly) BOOL isValidEmailAddress;

@end
