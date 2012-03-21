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

+ (UIAlertView *)emailInvalidAlertView {
    return [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"You must enter a valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

+ (UIAlertView *) anotherAccountWithUsernameExistsDeadEndAlertView {
    return [[UIAlertView alloc] initWithTitle:@"Account with Username Exists" message:@"There is already an Emotish account associated with that username. Please enter a different one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

+ (UIAlertView *) anotherAccountWithEmailExistsDeadEndAlertView {
    return [[UIAlertView alloc] initWithTitle:@"Account with Email Exists" message:@"There is already an Emotish account associated with that email address. Please enter a different one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

+ (UIAlertView *)userEditedAlertView {
    return [[UIAlertView alloc] initWithTitle:@"User Updated" message:@"Your user account has successfully been updated." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

+ (UIAlertView *)photoLikedAlertViewWithRemoteNotificationUserInfo:(NSDictionary *)userInfo delegate:(id<UIAlertViewDelegate>)delegate {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Emotish" message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Show Me", nil];
    alertView.delegate = delegate;
    return alertView;
}

@end
