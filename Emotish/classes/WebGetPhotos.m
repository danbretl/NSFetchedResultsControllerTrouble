//
//  WebGetPhotos.m
//  Emotish
//
//  Created by Dan Bretl on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebGetPhotos.h"
#import <Parse/Parse.h>

NSString * const WEB_RELOAD_ALL_DATE_KEY = @"WEB_RELOAD_ALL_DATE_KEY";

const BOOL WEB_GET_PHOTOS_VISIBLE_ONLY_DEFAULT = YES;
const int WEB_GET_PHOTOS_LIMIT_DEFAULT = 10;
static NSString * WEB_GET_PHOTOS_DATE_KEY_DEFAULT = @"createdAt"; // (or @"updatedAt")

@interface WebGetPhotos()
@property (strong, nonatomic) PFQuery * query;
- (id) initWithGroupClassName:(NSString *)groupClassName matchingGroupServerID:(NSString *)groupServerID visibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey limit:(NSNumber *)limit delegate:(id<WebGetPhotosDelegate>)delegate;
@property (strong, nonatomic) NSDate * datetimeExecuted;
@property (nonatomic) BOOL isExecuting;
@property (nonatomic) BOOL isGeneral;
@property (nonatomic, strong) NSNumber * limit;
@property (nonatomic, strong) NSString * groupServerID;
@end

@implementation WebGetPhotos

@synthesize delegate=_delegate;
@synthesize query=_query;
@synthesize datetimeExecuted=_datetimeExecuted, isExecuting=_isExecuting;
@synthesize isGeneral=_isGeneral;
@synthesize limit=_limit;
@synthesize groupServerID=_groupServerID;

- (id)initForPhotosAllWithOptionsVisibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey limit:(NSNumber *)limit delegate:(id<WebGetPhotosDelegate>)delegate {
    return [self initWithGroupClassName:nil matchingGroupServerID:nil visibleOnly:visibleOnly beforeEndDate:endDate afterStartDate:startDate dateKey:dateKey limit:limit delegate:delegate];
}

- (id)initForPhotosWithFeelingServerID:(NSString *)feelingServerID visibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey limit:(NSNumber *)limit delegate:(id<WebGetPhotosDelegate>)delegate {
    return [self initWithGroupClassName:@"Feeling" matchingGroupServerID:feelingServerID visibleOnly:visibleOnly beforeEndDate:endDate afterStartDate:startDate dateKey:dateKey limit:limit delegate:delegate];    
}

- (id)initForPhotosWithUserServerID:(NSString *)userServerID visibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey limit:(NSNumber *)limit delegate:(id<WebGetPhotosDelegate>)delegate {
    return [self initWithGroupClassName:@"User" matchingGroupServerID:userServerID visibleOnly:visibleOnly beforeEndDate:endDate afterStartDate:startDate dateKey:dateKey limit:limit delegate:delegate];
}

- (id)initWithGroupClassName:(NSString *)groupClassName matchingGroupServerID:(NSString *)groupServerID visibleOnly:(NSNumber *)visibleOnly beforeEndDate:(NSDate *)endDate afterStartDate:(NSDate *)startDate dateKey:(NSString *)dateKey limit:(NSNumber *)limit delegate:(id<WebGetPhotosDelegate>)delegate {
    
    self = [super init];
    
    if (self) {
        self.query = [PFQuery queryWithClassName:@"Photo"];
        NSLog(@"Setting up PFQuery for Photo objects");
        
        self.isGeneral = (groupServerID == nil);
        
        if (groupClassName != nil && groupServerID != nil) {
            if ([groupClassName.lowercaseString isEqualToString:@"feeling"]) {
                [self.query whereKey:groupClassName.lowercaseString equalTo:[PFPointer pointerWithClassName:groupClassName objectId:groupServerID]];    
            } else {
                PFUser * user = [PFUser user];
                user.objectId = groupServerID;
                [self.query whereKey:groupClassName.lowercaseString equalTo:user];
            }
            NSLog(@"  whereKey:%@ equalTo:%@", groupClassName.lowercaseString, groupServerID);
            self.groupServerID = groupServerID;
        } else {
            self.groupServerID = nil;
        }
        
        if (visibleOnly != nil && visibleOnly.boolValue) {
            [self.query whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
            [self.query whereKey:@"flagged" notEqualTo:[NSNumber numberWithBool:YES]];
            NSLog(@"  whereKey:deleted notEqualTo:YES");
            NSLog(@"  whereKey:flagged notEqualTo:YES");
        }
        
        if (dateKey == nil) {
            dateKey = WEB_GET_PHOTOS_DATE_KEY_DEFAULT;
        }
        
        if (endDate != nil) {
            [self.query whereKey:dateKey lessThanOrEqualTo:endDate];
            NSLog(@"  whereKey:%@ lessThanOrEqualTo:%@", dateKey, endDate);
        }
        if (startDate != nil) {
            [self.query whereKey:dateKey greaterThanOrEqualTo:startDate];
            NSLog(@"  whereKey:%@ greaterThanOrEqualTo:%@", dateKey, startDate);
        }
        
        [self.query orderByDescending:dateKey];
        
        int limitValue = WEB_GET_PHOTOS_LIMIT_DEFAULT;
        if (limit != nil) {
            limitValue = limit.intValue;
        }
        [self.query setLimit:[NSNumber numberWithInt:limitValue]];
        NSLog(@"  setLimit:%d", limitValue);
        self.limit = [NSNumber numberWithInt:limitValue];
        
        [self.query includeKey:@"feeling"];
        NSLog(@"  includeKey:feeling");
        [self.query includeKey:@"user"];
        NSLog(@"  includeKey:user");
        
        self.delegate = delegate;
    }
    
    return self;
    
}

- (void)startWebGetPhotos {
    if (!self.isExecuting) {
        self.isExecuting = YES;
        self.datetimeExecuted = [NSDate date];

        [self.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    //        NSLog(@"  Found objects");
    //        NSLog(@"    Error: %@ %@ %@", error, error.description, error.userInfo);
    //        NSLog(@"    Objects: (%d)", objects.count);
    //        for (PFObject * object in objects) {
    //            NSLog(@"      %@ %@ %@", object.objectId, [[object objectForKey:@"feeling"] objectForKey:@"word"], [[object objectForKey:@"user"] objectForKey:@"username"]);
    //        }
            self.isExecuting = NO;
            if (!error) {
                [self.delegate webGetPhotos:self succeededWithPhotos:objects];
            } else {
                [self.delegate webGetPhotos:self failedWithError:error];
            }
        }];
    }
}

- (void)cancelWebGetPhotos {
    if (self.isExecuting) {
        NSLog(@"cancelWebGetPhotos received");
        [self.query cancel]; // No callback
    }
}


@end
