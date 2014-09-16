//
//  NSArray+EnumExtensions.m
//  AllAtOnce
//
//  Created by Tami Wright on 07/01/14.
//  Copyright (c) 2014 Excentrix Web. All rights reserved.
//  Based on SO answer found at http://stackoverflow.com/questions/1242914/converting-between-c-enum-and-xml/1243622#1243622

#import "NSArray+EnumExtensions.h"

@implementation NSArray (EnumExtensions)

- (NSString*) stringWithEnum: (NSUInteger) e;
{
    return [self objectAtIndex:e];
}

- (NSUInteger) enumFromString: (NSString*) s default: (NSUInteger) def;
{
    NSUInteger n = [self indexOfObject:s];
    if ( n == NSNotFound ) {
        n = def;
    }
    return n;
}

- (NSUInteger) enumFromString: (NSString*) s;
{
    return [self enumFromString:s default:0];
}

@end
