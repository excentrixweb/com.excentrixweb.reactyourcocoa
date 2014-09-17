//
//  EWMessageSessionManager.m
//  allatonce
//
//  Created by Tami Wright on 6/10/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import <Parse/Parse.h>
#import "EWMessagingManager.h"
#import "EWMessageSession.h"
#import "EWParseCloudCodeApiClient.h"
#import "EWFacebookGraphApiClient.h"
#import "EWTwitterApiParseUserClient.h"
#import "NSString+StringMethods.h"

@interface EWMessagingManager()
{
    EWMessageSession            *_messageSession;
    EWUser                      *_user;
    EWParseCloudCodeApiClient   *_parseCloudCodeApiClient;
    EWFacebookGraphApiClient    *_facebookGraphApiClient;
    EWTwitterApiParseUserClient *_twitterApiParseUserClient;
}
@end

@implementation EWMessagingManager

#pragma mark - Class methods
+ (EWMessagingManager *)sharedInstanceForUser:(EWUser *)user
                                withMessageSession:(EWMessageSession *)messageSession
                                  outgoingDiameter:(CGFloat)outgoingDiameter
                                  incomingDiameter:(CGFloat)incomingDiameter {
    // 1
    static EWMessagingManager *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[EWMessagingManager alloc] initWithUser:user withMessageSession:messageSession outgoingDiameter:outgoingDiameter incomingDiameter:incomingDiameter];
    });
    return _sharedInstance;
}

+ (void)getFacebookGraphUsersFromRecipientsForMessageSessionManagerInstance:(EWMessagingManager *)instance withBlock:(EWArrayResultBlock)block
{
    [instance getRecipientsForRecipientType:FACEBOOK withBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *graphUsers = [[NSMutableArray alloc] init];
        if (!error)
        {
            for (EWRecipient *recipient in objects)
            {
                id<FBGraphUser> user = (id<FBGraphUser>)[FBGraphObject graphObject];
                user.objectID = recipient.faceBookId;
                user.name = recipient.name;
                [graphUsers addObject:user];
            }
        }
        block(graphUsers, error);
    }];
}

#pragma mark - Instance methods
- (id)initWithUser:(EWUser *)user withMessageSession:(EWMessageSession *)messageSession outgoingDiameter:(CGFloat)outgoingDiameter incomingDiameter:(CGFloat)incomingDiameter {
    self = [super init];
    if (self) {
        _messageSession = messageSession ?: [[EWMessageSession alloc] initWithMessages:nil recipients:nil userId:user.objectId mobile:user.mobile title:nil];
        _parseCloudCodeApiClient = [EWParseCloudCodeApiClient sharedClient];
        _facebookGraphApiClient = [EWFacebookGraphApiClient sharedClient];
        _twitterApiParseUserClient = [EWTwitterApiParseUserClient sharedClient];
        _user = user;
    }
    return self;
}

- (NSArray *)getRecipients
{
    return _messageSession.recipients;
}

- (void)getRecipientsForRecipientType:(RecipientType)type withBlock:(EWArrayResultBlock)block
{
    NSArray *enumerateArray = [NSArray arrayWithArray:_messageSession.recipients];
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (EWRecipient *recipient in enumerateArray)
    {
        if (recipient.recipientType == type)
            [newArray addObject:recipient];
    }
    block(newArray, nil);
}

- (void)addRecipient:(EWRecipient *)recipient
{
    [_messageSession.recipients addObject:recipient];
    [self saveCurrentMessageSession];
}

- (void)addRecipient:(EWRecipient *)recipient atIndex:(int)index
{
    [_messageSession.recipients insertObject:recipient atIndex:index];
    [self saveCurrentMessageSession];
}

- (void)deleteRecipientAtIndex:(int)index
{
    [_messageSession.recipients removeObjectAtIndex:index];
    [self saveCurrentMessageSession];
}

- (void)deleteRecipient:(EWRecipient *)recipient withBlock:(EWArrayResultBlock)block
{
    int counter = 0;
    NSArray *enumerateArray = [NSArray arrayWithArray:_messageSession.recipients];
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:_messageSession.recipients];
    for (EWRecipient *object in enumerateArray)
    {
        if ([object isEqual:recipient])
        {
            [newArray removeObjectAtIndex:counter];
        }
        counter++;
    }
    _messageSession.recipients = [NSMutableArray arrayWithArray:newArray];
    [self saveCurrentMessageSession];
    block(_messageSession.recipients, nil);
}

- (void)addMessage:(EWMessage *)message withBlock:(EWIdResultBlock)block {
    [_messageSession.messages insertObject:message atIndex:[self.jsqMessages count] - 1];
    [_parseCloudCodeApiClient sendMessage:message fromUser:_user toRecipients:_messageSession.recipients withBlock:^(id object, NSError *error) {
        if (error)
        {
            NSLog(@"Error sending message %@", (NSString *) object);
            [_messageSession saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                block(_messageSession, error);
            }];
        }
        else
        {
            NSArray *facebookIdsArray = [self socialNetworkIdsForRecipientType:FACEBOOK];
            NSArray *twitterIdsArray = [self socialNetworkIdsForRecipientType:TWITTER];
            if (facebookIdsArray && facebookIdsArray.count > 0)
            {
                [_facebookGraphApiClient postStatusUpdate:message.messageText withTaggableFriends:facebookIdsArray withBlock:^(BOOL succeeded, NSError *error) {
                    if (!error && twitterIdsArray && twitterIdsArray.count > 0) {
                        [_twitterApiParseUserClient directMessage:message.messageText toUsers:twitterIdsArray withBlock:^(BOOL succeeded, NSError *error) {
                            [_messageSession saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                block(_messageSession, error);
                            }];
                        }];
                    }
                    else
                    {
                        [_messageSession saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            block(_messageSession, error);
                        }];
                    }
                }];
            }
            else if (twitterIdsArray && twitterIdsArray.count > 0)
            {
                [_twitterApiParseUserClient directMessage:message.messageText toUsers:twitterIdsArray withBlock:^(BOOL succeeded, NSError *error) {
                    [_messageSession saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        block(_messageSession, error);
                    }];
                }];
            }
            else
            {
                [_messageSession saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    block(_messageSession, error);
                }];
            }
        }
        
    }];
}

- (void)addMessage:(NSString *)messageText withImages:(NSMutableArray *)images withBlock:(EWIdResultBlock)block {
    [self addMessage:[EWMessage messageWithMessageText:messageText images:images] withBlock:block];
}

- (void)deleteMessageAtIndex:(int)index
{
    [_messageSession.messages removeObjectAtIndex:index];
}

- (NSArray *)getMessages {
    return _messageSession.messages;
}

- (void)setMessageSessionWithId:(NSString *)withId withBlock:(EWBooleanResultBlock)block
{
    if (withId)
    {
        EWMessageSession *messageSession = [EWMessageSession objectWithoutDataWithObjectId:withId];
        [messageSession fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            _messageSession = (EWMessageSession *)object;
            block(!error, error);
        }];
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:@"DoodaParseError" code:1 userInfo:nil];
        block(false, error);
    }
}

- (void)saveMessageSessionWithBlock:(EWBooleanResultBlock)block {
    [_messageSession saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        block(!error, error);
    }];
}

#pragma mark - Private methods

- (void)saveCurrentMessageSession
{
    if (_messageSession.objectId && _messageSession.messages.count > 0)
    {
        [_messageSession saveInBackground];
    }
}

- (NSArray *)socialNetworkIdsForRecipientType:(RecipientType)recipientType
{
    if (_messageSession.recipients.count > 0)
    {
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        NSArray *enumerateArray = [[NSArray alloc] initWithArray:_messageSession.recipients copyItems:NO];
        for (EWRecipient *recipient in enumerateArray)
        {
            if (recipient.recipientType == recipientType)
            {
                if (recipientType == FACEBOOK && recipient.faceBookId && [recipient.faceBookId length] > 0)
                    [resultArray addObject:recipient.faceBookId];
                else if (recipientType == TWITTER && recipient.twitterId && [recipient.twitterId length] > 0)
                    [resultArray addObject:recipient.twitterId];
            }
        }
        return resultArray;
    }
    return nil;
}

@end
