//
//  WebManager.m
//  Emotish
//
//  Created by Dan Bretl on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebManager.h"
#import "SDNetworkActivityIndicator.h"
#import "WebUtil.h"
#import <Parse/Parse.h>

//NSString * const WEB_RELOAD_ALL_DATE_KEY = @"WEB_RELOAD_ALL_DATE_KEY";

@interface WebManager ()
@property (strong, nonatomic, readonly) NSOperationQueue * operationQueue;
@property (strong, nonatomic) NSMutableSet * photosQueries;
@end

@implementation WebManager
@synthesize operationQueue=_operationQueue;
@synthesize photosQueries=_photosQueries;

+ (WebManager *)sharedManager {
    static WebManager * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WebManager alloc] init];
        // Do other initialization stuff here...
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.photosQueries = [NSMutableSet set];
    }
    return self;
}

- (void) getPhotosForGroupClassName:(NSString *)groupClassName matchingGroupServerID:(NSString *)groupServerID visibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey chronologicalSortIsAscending:(NSNumber *)ascending limit:(NSNumber *)limit {
    
    GetAndProcessPhotosOperation * operation = [[GetAndProcessPhotosOperation alloc] initWithGroupClassName:groupClassName matchingGroupServerID:groupServerID visibleOnly:visibleOnly beforeEndDate:endDate afterStartDate:startDate dateKey:dateKey chronologicalSortIsAscending:ascending limit:limit];
    [self.photosQueries addObject:operation.photosQuery];
    [self.operationQueue addOperation:operation];
    
}

- (NSOperationQueue *)operationQueue {
    if (_operationQueue == nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return _operationQueue;
}

- (void)cancelAll {
    NSLog(@"WebManager cancelAll");
    for (PFQuery * photosQuery in self.photosQueries) {
        NSLog(@"  Cancelled photosQuery");
        [photosQuery cancel];
    }
    [self.photosQueries removeAllObjects];
//    for (GetAndProcessPhotosOperation * operation in self.operationQueue.operations) {
//        NSLog(@"GetAndProcessPhotosOperation is there");
//    }
    //    NSLog(@"  Should cancel %d operations", self.operationQueue.operationCount);
    [self.operationQueue cancelAllOperations];
}

@end
