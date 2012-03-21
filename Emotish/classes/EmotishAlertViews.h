//
//  EmotishAlertViews.h
//  Emotish
//
//  Created by Dan Bretl on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmotishAlertViews : NSObject

+ (UIAlertView *) generalConnectionErrorAlertView;

+ (UIAlertView *) facebookConnectionErrorAlertView;
+ (UIAlertView *) twitterConnectionErrorAlertView;
+ (UIAlertView *) socialNetworkConnectionErrorAlertView:(NSString *)socialNetworkName;

+ (UIAlertView *) facebookAccountTakenByOtherUserAlertView;
+ (UIAlertView *) twitterAccountTakenByOtherUserAlertView;
+ (UIAlertView *) socialNetworkAccountTakenByOtherUserAlertView:(NSString *)socialNetworkName;

+ (UIAlertView *) flaggedFeedbackAlertView;

+ (UIAlertView *) emailInvalidAlertView;
+ (UIAlertView *) anotherAccountWithUsernameExistsDeadEndAlertView;
+ (UIAlertView *) anotherAccountWithEmailExistsDeadEndAlertView;

+ (UIAlertView *) userEditedAlertView;

+ (UIAlertView *) photoLikedAlertViewWithRemoteNotificationUserInfo:(NSDictionary *)userInfo delegate:(id<UIAlertViewDelegate>)delegate;

+ (UIAlertView *) emailAddedToPasteboardAlertView:(NSString *)emailAddress;

@end
