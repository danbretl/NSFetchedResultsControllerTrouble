//
//  WebManager.h
//  Emotish
//
//  Created by Dan Bretl on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "GetAndProcessPhotosOperation.h"

// THIS CLASS SHOULD BE ABLE TO HANDLE LOTS OF CONNECTIONS SIMULTANEOUSLY, BUT IT CAN'T. THIS CLASS IS A MESS. THIS CLASS IS DEPLORABLE. EVERYTHING WEB-RELATED IS CURRENTLY DEPLORABLE.

//extern NSString * const WEB_RELOAD_ALL_DATE_KEY;

@interface WebManager : NSObject

+ (WebManager *) sharedManager;

- (void) getPhotosForGroupClassName:(NSString *)groupClassName matchingGroupServerID:(NSString *)groupServerID visibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey chronologicalSortIsAscending:(NSNumber *)ascending limit:(NSNumber *)limit;

- (void) cancelAll;

@end