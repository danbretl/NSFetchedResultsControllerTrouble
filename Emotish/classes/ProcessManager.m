//
//  ProcessManager.m
//  Emotish
//
//  Created by Dan Bretl on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProcessManager.h"

@interface ProcessManager ()
@property (strong, nonatomic) NSOperationQueue * queue;
@end

@implementation ProcessManager
@synthesize queue=_queue;

+ (ProcessManager *)sharedManager {
    static ProcessManager * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ProcessManager alloc] init];
        // Do other initialization stuff here...
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)addOperationToProcessPhotos:(NSArray *)photosFromWeb {
    ProcessPhotosOperation * operation = [[ProcessPhotosOperation alloc] init];
    operation.photos = photosFromWeb;
    [self.queue addOperation:operation];
}

@end
