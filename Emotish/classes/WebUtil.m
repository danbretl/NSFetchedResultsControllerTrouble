//
//  WebUtil.m
//  Emotish
//
//  Created by Dan Bretl on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebUtil.h"

NSString * const WEB_GET_PHOTOS_FINISHED_NOTIFICATION = @"WEB_GET_PHOTOS_FINISHED_NOTIFICATION";
NSString * const WEB_GET_PHOTOS_FINISHED_NOTIFICATION_SUCCESS_KEY = @"WEB_GET_PHOTOS_FINISHED_NOTIFICATION_SUCCESS_KEY";
NSString * const WEB_GET_PHOTOS_FINISHED_NOTIFICATION_GROUP_IDENTIFIER_KEY = @"WEB_GET_PHOTOS_FINISHED_NOTIFICATION_GROUP_IDENTIFIER_KEY";

static NSString * WEB_GET_PHOTOS_GROUP_NONE = @"WEB_GET_PHOTOS_GROUP_NONE";
static NSString * WEB_GET_PHOTOS_GROUP_FEELING_PREFIX = @"EMOTISH_WGP_GF_";
static NSString * WEB_GET_PHOTOS_GROUP_USER_PREFIX = @"EMOTISH_WGP_GU_";

@implementation WebUtil

+ (NSString *)getPhotosRequestIdentifierForGroupClassName:(NSString *)groupClassName groupServerID:(NSString *)groupServerID {
    BOOL none = (groupClassName == nil || groupServerID == nil);
    NSString * groupIdentifier = WEB_GET_PHOTOS_GROUP_NONE;
    if (!none) {
        NSString * prefix = [groupClassName.lowercaseString isEqualToString:@"feeling"] ? WEB_GET_PHOTOS_GROUP_FEELING_PREFIX : WEB_GET_PHOTOS_GROUP_USER_PREFIX;
        groupIdentifier = [NSString stringWithFormat:@"%@%@", prefix, groupServerID];
    }
    return groupIdentifier;
}

@end
