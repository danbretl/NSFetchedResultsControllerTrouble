//
//  ProcessManager.h
//  Emotish
//
//  Created by Dan Bretl on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProcessPhotosOperation.h"

@interface ProcessManager : NSObject

+ (ProcessManager *) sharedManager;

- (void) addOperationToProcessPhotos:(NSArray *)photosFromWeb;

@end
