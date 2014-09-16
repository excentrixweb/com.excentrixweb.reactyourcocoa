//
// Created by Tami Wright on 6/17/14.
// Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DateFormatMethods)

+ (NSString *)localDateTimeForDate:(NSDate *)date;

+ (NSString *)localDateTimeForDate:(NSDate *)date withFormat:(NSString *)format;

- (NSString *)localDateTime;

- (NSString *)localDateTimeWithFormat:(NSString *)format;
@end