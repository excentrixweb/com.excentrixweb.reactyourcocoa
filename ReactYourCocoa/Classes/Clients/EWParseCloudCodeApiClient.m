//
//  EWParseCloudCodeApiClient.m
//  allatonce
//
//  Created by Tami Wright on 6/6/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import "EWParseCloudCodeApiClient.h"
#import "NSString+ArrayCreateMethods.h"
#import "NSArray+ArrayManipulationMethods.h"

@implementation EWParseCloudCodeApiClient

+ (id)sharedClient {
    static EWParseCloudCodeApiClient *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[EWParseCloudCodeApiClient alloc] init];
    });
    return __instance;
}

- (void)sendMessage:(EWMessage *)message fromUser:(EWUser *)fromUser toRecipients:(NSArray *)recipients withBlock:(EWIdResultBlock)block {
    if (!message.messageText || [message.messageText length] <= 0)
        return;
    
    NSMutableArray *mobileNumbers = [NSMutableArray array];
    NSMutableDictionary *parameters;
    
    for (EWRecipient *recipient in recipients) {
        if (recipient.recipientType == PHONEBOOK)
            [mobileNumbers addObject:recipient.mobile];
    }
    NSString *fullMessageBody = [NSString stringWithFormat:@"From: %@ \nReply-To: %@ \n%@", fromUser.fullName, fromUser.mobile, message.messageText];
    
    if ([fullMessageBody length] > kEWTwilioMessageMaxSize && mobileNumbers.count > 0)
    {
        NSArray *messageSegmentsArray = [[NSMutableArray arrayWithArray:[fullMessageBody tokenArrayForSegmentSize:kEWTwilioMessageMaxSize]] reversedArray];
        
        int numberOfMessageSegments = [messageSegmentsArray count];
        int messageSegmentNumberSentCounter = 0;
        BOOL callBlock = NO;
        for (NSString *messageSegment in messageSegmentsArray)
        {
            parameters = [[NSMutableDictionary alloc] initWithDictionary: @{@"messageText":
                                                                                [NSString stringWithFormat:@"%@", messageSegment]
                                                                            ,@"mobileNumbers": mobileNumbers}];
            callBlock = messageSegmentNumberSentCounter == (numberOfMessageSegments - 1);
            if (callBlock && [message.images count] > 0)
            {
                [parameters setObject:message.images[0] forKey:@"mediaUrl"];
            }
            [PFCloud callFunctionInBackground:@"sendSms"
                               withParameters:parameters
                                        block:^(NSString *responseBody, NSError *error)
             {
                 if (callBlock)
                     block(responseBody, error);
             }];
            messageSegmentNumberSentCounter++;
        }

    }
    else if (mobileNumbers.count > 0)
    {
        parameters = [[NSMutableDictionary alloc] initWithDictionary: @{@"messageText":
                                                                            [NSString stringWithFormat:@"%@", fullMessageBody]
                                                                        ,@"mobileNumbers": mobileNumbers}];
        if ([message.images count] > 0)
        {
            [parameters setObject:message.images[0] forKey:@"mediaUrl"];
        }
        [PFCloud callFunctionInBackground:@"sendSms"
                           withParameters:parameters
                                    block:^(NSString *responseBody, NSError *error)
         {
             block(responseBody, error);
         }];
    }
    else
    {
        block(@"Not called", nil);
    }
    
}
@end
