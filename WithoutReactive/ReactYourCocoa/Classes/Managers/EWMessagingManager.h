//
//  EWMessageSessionManager.h
//  allatonce
//
//  Created by Tami Wright on 6/10/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWMessageSession.h"
#import "EWMessage.h"
#import "EWRecipient.h"
#import "EWUser.h"

@interface EWMessagingManager : NSObject

/** Properties **/
@property (strong, nonatomic) NSMutableArray *jsqMessages;
@property (copy, nonatomic) NSDictionary *avatars;

/** Methods **/
// Class Methods
+ (EWMessagingManager *)sharedInstanceForUser:(EWUser *)user withMessageSession:(EWMessageSession *)messageSession outgoingDiameter:(CGFloat)outgoingDiameter incomingDiameter:(CGFloat)incomingDiameter;
+ (void)getFacebookGraphUsersFromRecipientsForMessageSessionManagerInstance:(EWMessagingManager *)instance withBlock:(EWArrayResultBlock)block;

//Instance Methods
- (id)initWithUser:(EWUser *)user withMessageSession:(EWMessageSession *)messageSession outgoingDiameter:(CGFloat)outgoingDiameter incomingDiameter:(CGFloat)incomingDiameter;

// Recipients
- (void)addRecipient:(EWRecipient *)recipient;
- (void)addRecipient:(EWRecipient *)recipient atIndex:(int)index;
- (void)deleteRecipientAtIndex:(int)index;
- (void)deleteRecipient:(EWRecipient *)recipient withBlock:(EWArrayResultBlock)block;
- (NSArray *)getRecipients;
- (void)getRecipientsForRecipientType:(RecipientType)type withBlock:(EWArrayResultBlock)block;

// Messages
- (void)addMessage:(EWMessage *)message withBlock:(EWIdResultBlock)block;
- (void)addMessage:(NSString *)messageText withImages:(NSMutableArray *)images withBlock:(EWIdResultBlock)block;
- (void)deleteMessageAtIndex:(int)index;
- (NSArray *)getMessages;

// MessageSession
- (void)setMessageSessionWithId:(NSString *)withId withBlock:(EWBooleanResultBlock)block;
- (void)saveMessageSessionWithBlock:(EWBooleanResultBlock)block;
@end
