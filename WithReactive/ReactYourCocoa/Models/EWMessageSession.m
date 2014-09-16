//
//  EWMessageSession.m
//  allatonce
//
//  Created by Tami Wright on 6/10/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import "EWMessageSession.h"
#import <Parse/PFObject+Subclass.h>
#import "NSDate+DateFormatMethods.h"

@implementation EWMessageSession
@dynamic messages;
@dynamic recipients;
@dynamic userId;
@dynamic mobile;
@dynamic title;

- (NSString *)friendlyDate {
    return [self.createdAt localDateTime];
}

- (instancetype)initWithMessages:(NSMutableArray *)messagesArray recipients:(NSMutableArray *)recipientsArray userId:(NSString *)aUserId mobile:(NSString *)aMobile title:(NSString *)aTitle {
    self = [super init];
    if (self) {
        self.messages = messagesArray ?: [[NSMutableArray alloc]init];
        self.recipients = recipientsArray ?: [[NSMutableArray alloc]init];
        self.userId = aUserId;
        self.mobile = aMobile;
        self.title = aTitle;
    }

    return self;
}

+ (instancetype)messageSessionWithMessages:(NSMutableArray *)messages recipients:(NSMutableArray *)recipients userId:(NSString *)userId mobile:(NSString *)mobile title:(NSString *)title {
    return [[self alloc] initWithMessages:messages recipients:recipients userId:userId mobile:mobile title:title];
}

+ (NSString *)parseClassName
{
    return kPFMessageSessionClassName;
}
@end
