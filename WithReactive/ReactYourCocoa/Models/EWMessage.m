//
//  EWMessage.m
//  allatonce
//
//  Created by Tami Wright on 6/10/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import "EWMessage.h"
#import <Parse/PFObject+Subclass.h>

@implementation EWMessage
@dynamic messageText;
@dynamic images;

- (instancetype)initWithMessageText:(NSString *)aMessageText images:(NSMutableArray *)imagesArray {
    self = [super init];
    if (self) {
        self.messageText = aMessageText;
        self.images = imagesArray ?: [[NSMutableArray alloc] init];
    }

    return self;
}

+ (instancetype)messageWithMessageText:(NSString *)messageText images:(NSMutableArray *)images {
    return [[self alloc] initWithMessageText:messageText images:images];
}


+ (NSString *)parseClassName
{
    return kPFMessageClassName;
}
@end
