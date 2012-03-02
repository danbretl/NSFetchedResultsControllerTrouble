//
//  EmotishAlertViews.m
//  Emotish
//
//  Created by Dan Bretl on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmotishAlertViews.h"

@implementation EmotishAlertViews

+ (UIAlertView *)facebookConnectionErrorAlertView {
    return [self socialNetworkConnectionErrorAlertView:@"Facebook"];

}

+ (UIAlertView *)twitterConnectionErrorAlertView {
    return [self socialNetworkConnectionErrorAlertView:@"Twitter"];
}

+ (UIAlertView *)socialNetworkConnectionErrorAlertView:(NSString *)socialNetworkName {
    return [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ Error", socialNetworkName] message:[NSString stringWithFormat:@"Sorry, we're having trouble talking to %@ right now. Please try again.", socialNetworkName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

@end
