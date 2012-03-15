//
//  NSDateFormatter+EmotishTimeSpans.h
//  Emotish
//
//  Created by Dan Bretl on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (EmotishTimeSpans)

+ (NSString *) emotishTimeSpanStringForDatetime:(NSDate *)datetime countSeconds:(BOOL)shouldCountSeconds;

@end
