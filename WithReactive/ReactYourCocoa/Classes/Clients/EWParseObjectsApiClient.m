//
// Created by Tami Wright on 6/17/14.
// Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import "EWParseObjectsApiClient.h"
#import "EWMessageSession.h"
#import "EWUser.h"
#import "NSDate+DateFormatMethods.h"


@implementation EWParseObjectsApiClient {

}

+ (id)sharedClient {
    static EWParseObjectsApiClient *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[EWParseObjectsApiClient alloc] init];
    });
    return __instance;
}

- (void)userMessageSessionsListWithBlock:(EWArrayResultBlock)block {

    PFQuery *query = [EWMessageSession query];
    [query whereKey:@"userId" equalTo:([EWUser currentUser]).objectId];
    [query includeKey:@"recipients"];
    [query includeKey:@"messages"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d message sessions.", objects.count);
            block(objects, error);
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            block(nil, error);
        }
    }];
}

@end