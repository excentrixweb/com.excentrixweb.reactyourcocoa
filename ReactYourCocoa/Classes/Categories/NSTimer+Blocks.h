//
//  NSTimer+Blocks.h
//  AllAtOnce
//
//  Created by Tami Wright on 07/01/14.
//  Copyright (c) 2014 Excentrix Web. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Blocks)
+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
@end
