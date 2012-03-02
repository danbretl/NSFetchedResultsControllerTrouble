//
//  WebManager.m
//  Emotish
//
//  Created by Dan Bretl on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebManager.h"

@implementation WebManager

+ (WebManager *)sharedManager {
    static WebManager * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WebManager alloc] init];
        // Do other initialization stuff here...
    });
    return sharedInstance;
}

@end
