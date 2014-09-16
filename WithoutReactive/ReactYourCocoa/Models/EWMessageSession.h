//
//  EWMessageSession.h
//  allatonce
//
//  Created by Tami Wright on 6/10/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Frameworks.h"

static NSString * const kPFMessageSessionClassName = @"MessageSession";
static NSString * const kPFUserFieldName = @"user";
static NSString * const kPFMessagesFieldName = @"messages";
static NSString * const kPFRecipientsFieldName = @"recipients";
static NSString * const kPFMessageSessionFieldName = @"messageSession";

@interface EWMessageSession : PFObject<PFSubclassing>
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *recipients;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *title;
@property (readonly, strong) NSString *friendlyDate;

- (instancetype)initWithMessages:(NSMutableArray *)messagesArray recipients:(NSMutableArray *)recipientsArray userId:(NSString *)aUserId mobile:(NSString *)aMobile title:(NSString *)aTitle;

+ (instancetype)messageSessionWithMessages:(NSMutableArray *)messages recipients:(NSMutableArray *)recipients userId:(NSString *)userId mobile:(NSString *)mobile title:(NSString *)title;

+ (NSString *)parseClassName;
@end
