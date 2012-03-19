//
//  ProcessPhotosOperation.h
//  Emotish
//
//  Created by Dan Bretl on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataManager.h"

@interface ProcessPhotosOperation : NSOperation

@property (strong, nonatomic) NSArray * photos;

- (id) initWithPhotos:(NSArray *)photos;

+ (void) processPhotos:(NSArray *)photos withCoreDataManager:(CoreDataManager *)coreDataManager;

@end