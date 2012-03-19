//
//  WebUtil.h
//  Emotish
//
//  Created by Dan Bretl on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const WEB_GET_PHOTOS_FINISHED_NOTIFICATION;
extern NSString * const WEB_GET_PHOTOS_FINISHED_NOTIFICATION_SUCCESS_KEY;
extern NSString * const WEB_GET_PHOTOS_FINISHED_NOTIFICATION_GROUP_IDENTIFIER_KEY;

@interface WebUtil : NSObject

+ (NSString *) getPhotosGroupIdentifierForGroupClassName:(NSString *)groupClassName groupServerID:(NSString *)groupServerID;

@end
