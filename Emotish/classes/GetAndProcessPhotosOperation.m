//
//  GetAndProcessPhotosOperation.m
//  Emotish
//
//  Created by Dan Bretl on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GetAndProcessPhotosOperation.h"

const BOOL WEB_GET_PHOTOS_CHRONOLOGICAL_SORT_IS_ASCENDING_DEFAULT = NO;
const BOOL WEB_GET_PHOTOS_VISIBLE_ONLY_DEFAULT = YES;
const int WEB_GET_PHOTOS_LIMIT_DEFAULT = 10;
static NSString * WEB_GET_PHOTOS_DATE_KEY_DEFAULT = @"createdAt"; // (or @"updatedAt")

@implementation GetAndProcessPhotosOperation

- (id)initWithGroupClassName:(NSString *)groupClassName matchingGroupServerID:(NSString *)groupServerID visibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey chronologicalSortIsAscending:(NSNumber *)ascending limit:(NSNumber *)limit delegate:(id<GetAndProcessPhotosOperationDelegate>)delegate {
    
    
    
    
    
    
    
    
}

@end
