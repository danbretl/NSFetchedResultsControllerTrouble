//
//  EmotishURLManager.m
//  Emotish
//
//  Created by Dan Bretl on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmotishURLManager.h"

@implementation EmotishURLManager

//+ (void) openTumblrURLForUsername:(NSString *)tumblrUsername {
//    // tumblr:///link?url=mobelux.com/tumblr/iphone&name=Mobelux
//    // should handle username given like 'emotish' and 'emotish.tumblr.com'
//    
//    tumblrUsername = [tumblrUsername stringByReplacingOccurrencesOfString:@".tumblr.com" withString:@""];
//    
//    NSURL * tumblrURL = [NSURL URLWithString:[NSString stringWithFormat:@"tumblr://link?url=%@.com/tumblr/iphone&name=%@", tumblrUsername, tumblrUsername]];
//    // Try to open the native Twitter app
//    if ([[UIApplication sharedApplication] canOpenURL:tumblrURL]) {
//        [[UIApplication sharedApplication] openURL:tumblrURL];
//    } else {
//        // Fall back on Safari
//        [self openGeneralURLForString:[NSString stringWithFormat:@"%@.tumblr.com", tumblrUsername]];
//    }
//}

+ (void) openTwitterURLForUsername:(NSString *)twitterUsername {
    if ([[twitterUsername substringToIndex:1] isEqualToString:@"@"]) {
        twitterUsername = [twitterUsername substringFromIndex:1];
    }
    NSURL * twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", twitterUsername]];
    // Try to open the native Twitter app
    if ([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
        [[UIApplication sharedApplication] openURL:twitterURL];
    } else {
        // Fall back on Safari
        [self openGeneralURLForString:[NSString stringWithFormat:@"twitter.com/%@", twitterUsername]];
    }
}

+ (void) openGeneralURLForString:(NSString *)urlString {
    if (![[urlString substringToIndex:4] isEqualToString:@"http"]) {
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end
