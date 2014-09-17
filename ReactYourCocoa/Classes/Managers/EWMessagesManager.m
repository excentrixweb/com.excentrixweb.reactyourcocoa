//
// Created by Tami Wright on 6/17/14.
// Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import "EWMessagesManager.h"
#import "EWParseObjectsApiClient.h"
#import "EWMessageSession.h"


@implementation EWMessagesManager {
    EWParseObjectsApiClient *_client;
    NSMutableArray *_messages;
    id<MessagesManagerDelegate> _delegate;
}
+ (EWMessagesManager *)sharedInstanceForUser:(EWUser *)user withDelegate:(id <MessagesManagerDelegate>)delegate {

    // 1
    static EWMessagesManager *_sharedInstance = nil;

    // 2
    static dispatch_once_t oncePredicate;

    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[EWMessagesManager alloc] initWithDelegate:delegate];
    });
    return _sharedInstance;
}

- (id)initWithDelegate:(id <MessagesManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _client = [EWParseObjectsApiClient sharedClient];
        _messages = [[NSMutableArray alloc]init];
        [self refreshMessages];
    }
    return self;
}

- (void)refreshMessages
{
    [_client userMessageSessionsListWithBlock:^(NSArray *objects, NSError *error) {
        _messages = [NSMutableArray arrayWithArray:objects];
        if([_delegate respondsToSelector:@selector(didSuccessfullyRetrieveMessages)]) {
            [_delegate didSuccessfullyRetrieveMessages];
        }
    }];
}

- (void)refreshMessagesWithBlock:(EWBooleanResultBlock)block
{
    [_client userMessageSessionsListWithBlock:^(NSArray *objects, NSError *error) {
        _messages = [NSMutableArray arrayWithArray:objects];
        block(_messages != nil, error);
        if([_delegate respondsToSelector:@selector(didSuccessfullyRetrieveMessages)]) {
            [_delegate didSuccessfullyRetrieveMessages];
        }
    }];
    
}

- (NSArray *)messages {
    return _messages;
}

- (EWMessageSession *)selectedMessage {
    return _messages[self.index];
}

- (void)setIndexForMessage:(EWMessageSession *)aMessageSession withBlock:(EWBooleanResultBlock)block
{
    NSArray *enumerateArray = [NSArray arrayWithArray:_messages];
    int counter = 0;
    for (EWMessageSession *messageSession in enumerateArray)
    {
        if ([messageSession.objectId isEqualToString:aMessageSession.objectId])
            self.index = counter;
        counter++;
    }
    
    block(self.index >= 0, nil);
}

- (void)addMessage:(EWMessageSession *)messageSession
{
    
    [_messages addObject:messageSession];
    self.index = [_messages indexOfObject:messageSession];
}

@end