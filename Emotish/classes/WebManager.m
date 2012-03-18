//
//  WebManager.m
//  Emotish
//
//  Created by Dan Bretl on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebManager.h"
#import "SDNetworkActivityIndicator.h"

@interface WebTask ()
@property (strong, nonatomic) PFQuery * query;
@property (strong, nonatomic) NSOperationQueue * operationQueue;
- (void) cancelWebTask;
@end

@implementation WebTask
@synthesize delegate=_delegate, query=_query, operationQueue=_operationQueue;
- (void)cancelWebTask {
    if (self.query) {
        NSLog(@"Cancelling query");
        [self.query cancel];
        self.query = nil;
    }
    if (self.operationQueue) {
        NSLog(@"Cancelling all operations");
        for (ProcessPhotosOperation * operation in self.operationQueue.operations) {
            operation.delegate = nil;
        }
        [self.operationQueue cancelAllOperations];
        self.operationQueue = nil;
    }
    NSLog(@"[self.delegate webTask:%@ finishedWithSuccess:NO];", self);
    [self.delegate webTask:self finishedWithSuccess:NO];
    self.delegate = nil;
}
- (void)operationFinishedWithSuccess:(NSNumber *)success {
    NSLog(@"[self.delegate webTask:%@ finishedWithSuccess:%d];", self, success.boolValue);
    [self.delegate webTask:self finishedWithSuccess:success.boolValue];
    self.query = nil;
    self.operationQueue = nil;
    self.delegate = nil;
}
@end

const BOOL WEB_GET_PHOTOS_CHRONOLOGICAL_SORT_IS_ASCENDING_DEFAULT = NO;
const BOOL WEB_GET_PHOTOS_VISIBLE_ONLY_DEFAULT = YES;
const int WEB_GET_PHOTOS_LIMIT_DEFAULT = 10;
static NSString * WEB_GET_PHOTOS_DATE_KEY_DEFAULT = @"createdAt"; // (or @"updatedAt")
NSString * const WEB_RELOAD_ALL_DATE_KEY = @"WEB_RELOAD_ALL_DATE_KEY";
//NSString * const WEB_RELOAD_FEELING_DATE_KEY_PREFIX = @"WRD_F_";
//NSString * const WEB_RELOAD_USER_DATE_KEY_PREFIX = @"WRD_U_";

@implementation WebManager
@synthesize webTasks;

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
        self.webTasks = [NSMutableSet set];
    }
    return self;
}

- (WebTask *) getPhotosForGroupClassName:(NSString *)groupClassName matchingGroupServerID:(NSString *)groupServerID visibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey chronologicalSortIsAscending:(NSNumber *)ascending limit:(NSNumber *)limit delegate:(id<WebTaskDelegate>)delegate {
    
    NSLog(@"Setting up photosQuery");

    PFQuery * photosQuery = [PFQuery queryWithClassName:@"Photo"];
    
    if (groupClassName != nil && groupServerID != nil) {
        [photosQuery whereKey:groupClassName.lowercaseString equalTo:[PFPointer pointerWithClassName:groupClassName objectId:groupServerID]];
        NSLog(@"  whereKey:%@ equalTo:%@", groupClassName.lowercaseString, groupServerID);
    }
    
    if (visibleOnly != nil && visibleOnly.boolValue) {
        [photosQuery whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
        [photosQuery whereKey:@"flagged" notEqualTo:[NSNumber numberWithBool:YES]];
        NSLog(@"  whereKey:deleted notEqualTo:YES");
        NSLog(@"  whereKey:flagged notEqualTo:YES");
    }
    
    if (dateKey == nil) {
        dateKey = WEB_GET_PHOTOS_DATE_KEY_DEFAULT;
    }
    
    if (endDate != nil) {
        [photosQuery whereKey:dateKey lessThanOrEqualTo:endDate];
        NSLog(@"  whereKey:%@ lessThanOrEqualTo:%@", dateKey, endDate);
    }
    if (startDate != nil) {
        [photosQuery whereKey:dateKey greaterThanOrEqualTo:startDate];
        NSLog(@"  whereKey:%@ greaterThanOrEqualTo:%@", dateKey, startDate);
    }
    
    BOOL ascendingValue = WEB_GET_PHOTOS_CHRONOLOGICAL_SORT_IS_ASCENDING_DEFAULT;
    if (ascending != nil) {
        ascendingValue = ascending.boolValue;
    }
    if (ascendingValue) {
        [photosQuery orderByAscending:dateKey];
        NSLog(@"  orderByAscending:%@", dateKey);
    } else {
        [photosQuery orderByDescending:dateKey];
        NSLog(@"  orderByDescending:%@", dateKey);
    }
    
    int limitValue = WEB_GET_PHOTOS_LIMIT_DEFAULT;
    if (limit != nil) {
        limitValue = limit.intValue;
    }
    [photosQuery setLimit:[NSNumber numberWithInt:limitValue]];
    NSLog(@"  setLimit:%d", limitValue);
    
    [photosQuery includeKey:@"feeling"];
    NSLog(@"  includeKey:feeling");
    [photosQuery includeKey:@"user"];
    NSLog(@"  includeKey:user");
    
    NSOperationQueue * operationQueue = [[NSOperationQueue alloc] init];
    WebTask * webTask = [[WebTask alloc] init];
    webTask.query = photosQuery;
    webTask.operationQueue = operationQueue;
    webTask.delegate = delegate;
    [self.webTasks addObject:webTask];
    
    NSLog(@"Executing photosQuery in background");
    [photosQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"  Found objects");
        NSLog(@"    Error: %@ %@ %@", error, error.description, error.userInfo);
        NSLog(@"    Objects: (%d)", objects.count);
        for (PFObject * object in objects) {
            NSLog(@"      %@ %@ %@", object.objectId, [[object objectForKey:@"feeling"] objectForKey:@"word"], [[object objectForKey:@"user"] objectForKey:@"username"]);
        }
        if (!error) {
            if (objects && objects.count > 0) {
                ProcessPhotosOperation * processPhotosOperation = [[ProcessPhotosOperation alloc] init];
                processPhotosOperation.photos = objects;
//                processPhotosOperation.dateRangeOld = startDate;
//                processPhotosOperation.dateRangeRecent = endDate;
                processPhotosOperation.delegate = webTask;
                [operationQueue addOperation:processPhotosOperation];
            } else {
                [webTask.delegate webTask:webTask finishedWithSuccess:YES];
            }
        } else {
            [webTask.delegate webTask:webTask finishedWithSuccess:NO];
        }
    }];
    
    return webTask;
    
}

- (void)cancelWebTask:(WebTask *)webTaskToCancel {
    NSLog(@"Attempting to cancel web task");
    if ([self.webTasks containsObject:webTaskToCancel]) {
        NSLog(@"Cancelling web task");
        [webTaskToCancel cancelWebTask];
        [self.webTasks removeObject:webTaskToCancel];
    }
}

@end
