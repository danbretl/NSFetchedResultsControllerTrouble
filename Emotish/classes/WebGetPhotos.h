//
//  WebGetPhotos.h
//  Emotish
//
//  Created by Dan Bretl on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const WEB_RELOAD_ALL_DATE_KEY;

@protocol WebGetPhotosDelegate;

@interface WebGetPhotos : NSObject

- (id) initForPhotosAllWithOptionsVisibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey limit:(NSNumber *)limit delegate:(id<WebGetPhotosDelegate>)delegate;
- (id) initForPhotosWithFeelingServerID:(NSString *)feelingServerID visibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey limit:(NSNumber *)limit delegate:(id<WebGetPhotosDelegate>)delegate;
- (id) initForPhotosWithUserServerID:(NSString *)userServerID visibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey limit:(NSNumber *)limit delegate:(id<WebGetPhotosDelegate>)delegate;

@property (unsafe_unretained, nonatomic) id<WebGetPhotosDelegate>delegate;
@property (strong, nonatomic, readonly) NSDate * datetimeExecuted;
@property (nonatomic, readonly) BOOL isExecuting;
@property (nonatomic, readonly) BOOL isGeneral;
@property (nonatomic, strong, readonly) NSNumber * limit;
@property (nonatomic, strong, readonly) NSString * groupServerID;

- (void) startWebGetPhotos;
- (void) cancelWebGetPhotos; // Does not produce a delegate callback

@end

@protocol WebGetPhotosDelegate <NSObject>
- (void) webGetPhotos:(WebGetPhotos *)webGetPhotos succeededWithPhotos:(NSArray *)photosFromWeb;
- (void) webGetPhotos:(WebGetPhotos *)webGetPhotos failedWithError:(NSError *)error;
@end
