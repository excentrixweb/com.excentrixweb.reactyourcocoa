//
// Created by Tami Wright on 6/17/14.
// Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import "NSString+StringMethods.h"


@implementation NSString (StringMethods)
- (NSString *)getInitials {
    NSMutableString *resultString = [NSMutableString string];
    NSArray *listItems = [self componentsSeparatedByString:@" "];
    for (NSString *string in listItems)
    {
        if ([string length] > 0 && ![string isEqualToString:@""] )
            [resultString appendString:[NSString stringWithFormat:@"%@", [string substringToIndex:1]]];
    }

    return resultString;
}

- (NSString *)trim
{
    NSString *newString = [self stringByTrimmingCharactersInSet:
     [NSCharacterSet whitespaceCharacterSet]];
    return newString;
}

@end