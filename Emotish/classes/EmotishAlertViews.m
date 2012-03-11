//
//  EmotishAlertViews.m
//  Emotish
//
//  Created by Dan Bretl on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmotishAlertViews.h"

@implementation EmotishAlertViews

+ (UIAlertView *)generalConnectionErrorAlertView {
    return [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Sorry - there was a problem connecting with Emotish. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

+ (UIAlertView *)facebookConnectionErrorAlertView {
    return [self socialNetworkConnectionErrorAlertView:@"Facebook"];

}

+ (UIAlertView *)twitterConnectionErrorAlertView {
    return [self socialNetworkConnectionErrorAlertView:@"Twitter"];
}

+ (UIAlertView *)socialNetworkConnectionErrorAlertView:(NSString *)socialNetworkName {
    return [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ Error", socialNetworkName] message:[NSString stringWithFormat:@"Sorry, we're having trouble talking to %@ right now. Please try again.", socialNetworkName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

+ (UIAlertView *)facebookAccountTakenByOtherUserAlertView {
    return [self socialNetworkAccountTakenByOtherUserAlertView:@"Facebook"];
}

+ (UIAlertView *)twitterAccountTakenByOtherUserAlertView {
    return [self socialNetworkAccountTakenByOtherUserAlertView:@"Twitter"];
}

+ (UIAlertView *)socialNetworkAccountTakenByOtherUserAlertView:(NSString *)socialNetworkName {
    return [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ Error", socialNetworkName] message:[NSString stringWithFormat:@"There is already another Emotish account associated with this %@ account.", socialNetworkName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

+ (UIAlertView *)flaggedFeedbackAlertView {
    return [[UIAlertView alloc] initWithTitle:@"Photo Flagged" message:@"Thanks for the feedback - we'll check it out, and you won't ever see that Photo again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

@end
