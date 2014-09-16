//
//  NSArray+ArrayManipulationMethods.m
//  AllAtOnce
//
//  Created by Tami Wright on 6/21/14.
//  Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import "NSArray+ArrayManipulationMethods.h"

@implementation NSArray (ArrayManipulationMethods)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end
