//
//  EmotishURLManager.h
//  Emotish
//
//  Created by Dan Bretl on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmotishURLManager : NSObject

//+ (void) openTumblrURLForUsername:(NSString *)tumblrUsername; // This doesn't seem to work. Can't find reliable resources online about tumblr openURL scheme.
+ (void) openTwitterURLForUsername:(NSString *)twitterUsername;
+ (void) openGeneralURLForString:(NSString *)urlString;

@end
