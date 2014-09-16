//
//  NSString+ArrayCreateMethods.m
//  AllAtOnce
//
//  Created by Tami Wright on 6/21/14.
//  Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import "NSString+ArrayCreateMethods.h"

@implementation NSString (ArrayCreateMethods)
- (NSArray *)tokenArrayForSegmentSize:(NSInteger)segmentSize
{
    NSMutableArray *tokenArray = [[NSMutableArray alloc] init];
    if([self length] >= segmentSize)
    {
        for (int i = 0; i < [self length]; i = i + segmentSize)
        {
            NSString *subString = @"";
            if ((i + segmentSize) < [self length])
                subString = [self substringWithRange:NSMakeRange(i,segmentSize)];
            else
                subString = [self substringFromIndex:i];
            [tokenArray addObject:subString];
        }
    }
    return tokenArray;
}
@end
