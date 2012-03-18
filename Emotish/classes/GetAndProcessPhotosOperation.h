//
//  GetAndProcessPhotosOperation.h
//  Emotish
//
//  Created by Dan Bretl on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GetAndProcessPhotosOperationDelegate;

@interface GetAndProcessPhotosOperation : NSOperation

- (id) initWithGroupClassName:(NSString *)groupClassName matchingGroupServerID:(NSString *)groupServerID visibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey chronologicalSortIsAscending:(NSNumber *)ascending limit:(NSNumber *)limit delegate:(id<GetAndProcessPhotosOperationDelegate>)delegate;

@end

@protocol GetAndProcessPhotosOperationDelegate <NSObject>
- (void) getAndProcessPhotosOperation:(GetAndProcessPhotosOperation *)operation finishedWithSuccess:(BOOL)success;
@end