//
//  PushConstants.h
//  Emotish
//
//  Created by Dan Bretl on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

extern NSString * const PUSH_USER_CHANNEL_PREFIX; // Necessary because all channels must start with a letter

extern NSString * const PUSH_LIKER_USER_SERVER_ID; // Not currently being pushed
extern NSString * const PUSH_LIKED_PHOTO_SERVER_ID;
extern NSString * const PUSH_LIKED_USER_SERVER_ID; // Not currently being pushed
extern NSString * const PUSH_LIKED_FEELING_SERVER_ID; // Not currently being pushed

@interface PushConstants : NSObject

+ (void) updatePushNotificationSubscriptionsGivenCurrentUserServerID:(NSString *)currentUserServerID;

@end
