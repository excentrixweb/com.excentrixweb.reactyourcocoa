//
//  EWParseCloudCodeApiClient.h
//  allatonce
//
//  Created by Tami Wright on 6/6/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Frameworks.h"
#import "EWMessage.h"
#import "EWRecipient.h"
#import "EWUser.h"

@interface EWParseCloudCodeApiClient : NSObject
+ (id)sharedClient;

- (void)sendMessage:(EWMessage *)message fromUser:(EWUser *)fromUser toRecipients:(NSArray *)recipients withBlock:(EWIdResultBlock)block;
@end
