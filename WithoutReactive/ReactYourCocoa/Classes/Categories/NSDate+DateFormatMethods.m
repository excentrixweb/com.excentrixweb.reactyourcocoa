//
// Created by Tami Wright on 6/17/14.
// Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import "NSDate+DateFormatMethods.h"


@implementation NSDate (DateFormatMethods)
+ (NSString *)localDateTimeForDate:(NSDate *)date {
    return [NSDate localDateTimeForDate:date withFormat:@"MM-dd-yyyy '('hh:mm:ss a')'"];
}

+ (NSString *)localDateTimeForDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone systemTimeZone]];
    [df_local setDateFormat:format];
    return [df_local stringFromDate:date];
}

- (NSString *)localDateTime {
    return [NSDate localDateTimeForDate:self withFormat:@"MM-dd-yyyy '('hh:mm:ss a')'"];
}

- (NSString *)localDateTimeWithFormat:(NSString *)format {
    return [NSDate localDateTimeForDate:self withFormat:format];
}


@end