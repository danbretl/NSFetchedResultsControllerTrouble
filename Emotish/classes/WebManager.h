//
//  WebManager.h
//  Emotish
//
//  Created by Dan Bretl on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ProcessPhotosOperation.h"

extern NSString * const WEB_RELOAD_ALL_DATE_KEY;
//extern NSString * const WEB_RELOAD_FEELING_DATE_KEY_PREFIX;
//extern NSString * const WEB_RELOAD_USER_DATE_KEY_PREFIX;

@protocol WebTaskDelegate;
@interface WebTask : NSObject <ProcessPhotosOperationDelegate>
@property (unsafe_unretained, nonatomic) id<WebTaskDelegate> delegate;
@end

@protocol WebTaskDelegate <NSObject>
- (void)webTask:(WebTask *)webTask finishedWithSuccess:(BOOL)success;
@end

@interface WebManager : NSObject

+ (WebManager *) sharedManager;

- (WebTask *) getPhotosForGroupClassName:(NSString *)groupClassName matchingGroupServerID:(NSString *)groupServerID visibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey chronologicalSortIsAscending:(NSNumber *)ascending limit:(NSNumber *)limit delegate:(id<WebTaskDelegate>)delegate;

@property (strong, nonatomic) NSMutableSet * webTasks;
- (void) cancelWebTask:(WebTask *)webTaskToCancel;

@end