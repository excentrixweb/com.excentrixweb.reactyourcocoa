//
// Created by Tami Wright on 6/6/14.
// Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Frameworks.h"
#import "EWUser.h"

static NSString * const TwitterBaseURLString = @"https://api.twitter.com/1.1/";

@interface EWTwitterApiParseUserClient : NSObject
+ (id)sharedClient;
- (void)verifyCredentials:(void (^)(PFUser *user))success
             failure:(void (^)(NSError *error))failure;
- (void)showUser:(NSString*)userId
            success:(void (^)(PFUser *user))success
            failure:(void (^)(NSError *error))failure;
- (void)followersOfUser:(NSString *)userId
          withNextCursor:(NSString *)nextCursor
         withBlock:(EWIdResultBlock)block;
- (void)directMessage:(NSString *)message
                toUser:(NSString *)userId
           withBlock:(EWBooleanResultBlock)block;
- (void)directMessage:(NSString *)message
              toUsers:(NSArray *)userIds
     withBlock:(EWBooleanResultBlock)block;
@end