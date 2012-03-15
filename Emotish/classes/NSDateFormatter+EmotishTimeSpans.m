//
//  NSDateFormatter+EmotishTimeSpans.m
//  Emotish
//
//  Created by Dan Bretl on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDateFormatter+EmotishTimeSpans.h"

@implementation NSDateFormatter (EmotishTimeSpans)

+ (NSString *) emotishTimeSpanStringForDatetime:(NSDate *)datetime countSeconds:(BOOL)shouldCountSeconds {
    int timeValue = 0;
    NSString * timeUnit = nil;
    int seconds = abs((int)[datetime timeIntervalSinceNow]);
    if (seconds < 60 && shouldCountSeconds) {
        timeValue = seconds;
        timeUnit = @"s";
    } else if (seconds < (60 * 60)) {
        timeValue = seconds / (60);
        timeUnit = @"m";
    } else if (seconds < (60 * 60 * 24)) {
        timeValue = seconds / (60 * 60);
        timeUnit = @"h";
    } else if (seconds < (60 * 60 * 24 * 7 * 2)) { // Note that we are switching from d to w at the 2 week point, rather than the 1.
        timeValue = seconds / (60 * 60 * 24);
        timeUnit = @"d";
    } else if (seconds < (60 * 60 * 24 * 7 * 52)) {
        timeValue = seconds / (60 * 60 * 24 * 7);
        timeUnit = @"w";
    } else {
        timeValue = seconds / (60 * 60 * 24 * 7 * 52);
        timeUnit = @"y";
    }
    return [NSString stringWithFormat:@"%d%@", timeValue, timeUnit];
}

@end
