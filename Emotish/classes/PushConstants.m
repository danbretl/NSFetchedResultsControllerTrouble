//
//  PushConstants.m
//  Emotish
//
//  Created by Dan Bretl on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PushConstants.h"

NSString * const PUSH_USER_CHANNEL_PREFIX = @"u"; // Necessary because all channels must start with a letter
NSString * const PUSH_LIKER_USER_SERVER_ID = @"lr_u_id"; // Not currently being pushed
NSString * const PUSH_LIKED_PHOTO_SERVER_ID = @"l_p_id";
NSString * const PUSH_LIKED_USER_SERVER_ID = @"l_u_id"; // Not currently being pushed
NSString * const PUSH_LIKED_FEELING_SERVER_ID = @"l_f_id"; // Not currently being pushed

@implementation PushConstants

+ (void)updatePushNotificationSubscriptionsGivenCurrentUserServerID:(NSString *)currentUserServerID {
    
    NSLog(@"Updating push notification subscriptions, given current user (id=%@)", currentUserServerID);
    
    // Check what channels we are currently subscribed to. Make sure we are only subscribed to the empty "" channel, and the user-specific channel (if a user is currently logged in).
    [PFPush getSubscribedChannelsInBackgroundWithBlock:^(NSSet * channels, NSError * error) {
        if (!error) {
            BOOL subscribedToGeneral = NO;
            BOOL subscribedToUser = currentUserServerID == nil;
            for (NSString * channelName in channels) {
                NSLog(@"  Analyzing existing subscription to channel \"%@\"", channelName);
                if (!subscribedToGeneral && [channelName isEqualToString:@""]) {
                    NSLog(@"    Already subscribed to general push channel \"\"");
                    subscribedToGeneral = YES;
                } else if (!subscribedToUser && [channelName isEqualToString:[NSString stringWithFormat:@"%@%@", PUSH_USER_CHANNEL_PREFIX, currentUserServerID]]) {
                    NSLog(@"    Already subscribed to user push channel \"%@\"", channelName);
                    subscribedToUser = YES;
                } else {
                    NSLog(@"    Unsubscribing from push channel \"%@\"", channelName);
                    [PFPush unsubscribeFromChannelInBackground:channelName];
                }
            }
            if (!subscribedToGeneral) {
                NSLog(@"  Subscribing to general push channel \"\"");
                // Subscribe to the global broadcast channel.
                [PFPush subscribeToChannelInBackground:@""];
            }
            if (!subscribedToUser) {
                NSLog(@"  Subscribing to user push channel \"%@%@\"", PUSH_USER_CHANNEL_PREFIX, currentUserServerID);
                [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"%@%@", PUSH_USER_CHANNEL_PREFIX, currentUserServerID]];
            }
        } else {
            NSLog(@"  Error retrieving existing subscription channels %@", error);
        }
    }];
    
}




@end
