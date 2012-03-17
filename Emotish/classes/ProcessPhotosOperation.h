//
//  ProcessPhotosOperation.h
//  Emotish
//
//  Created by Dan Bretl on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProcessPhotosOperationDelegate;

@interface ProcessPhotosOperation : NSOperation

@property (strong, nonatomic) NSArray * photos;
@property (unsafe_unretained, nonatomic) id<ProcessPhotosOperationDelegate> delegate;

@end

@protocol ProcessPhotosOperationDelegate <NSObject>
- (void)operationFinishedWithSuccess:(BOOL)success;
@end