//
//  NSArray+EnumExtensions.h
//  AllAtOnce
//
//  Created by Tami Wright on 07/01/14.
//  Copyright (c) 2014 Excentrix Web. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (EnumExtensions)
- (NSString*) stringWithEnum: (NSUInteger) e;
- (NSUInteger) enumFromString: (NSString*) s default: (NSUInteger) def;
- (NSUInteger) enumFromString: (NSString*) s;
@end
