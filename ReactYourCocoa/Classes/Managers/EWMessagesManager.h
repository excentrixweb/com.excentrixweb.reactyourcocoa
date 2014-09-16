//
// Created by Tami Wright on 6/17/14.
// Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWUser.h"
#import "EWMessageSession.h"

@class EWMessagesManager;
@protocol MessagesManagerDelegate <NSObject>

@required
- (void)didSuccessfullyRetrieveMessages;

@end

@interface EWMessagesManager : NSObject

+ (EWMessagesManager *)sharedInstanceForUser:(EWUser *)user withDelegate:(id <MessagesManagerDelegate>)delegate;
- (id)initWithDelegate:(id <MessagesManagerDelegate>)delegate;

- (void)refreshMessages;
- (void)setIndexForMessage:(EWMessageSession *)aMessageSession withBlock:(EWBooleanResultBlock)block;
- (void)refreshMessagesWithBlock:(EWBooleanResultBlock)block;
- (void)addMessage:(EWMessageSession *)messageSession;

@property (readonly, strong) NSArray *messages;
@property (readonly, strong) EWMessageSession *selectedMessage;
@property (assign) NSInteger index;
@end