//
//  EWFacebookGraphApiClient.m
//  allatonce
//
//  Created by Tami Wright on 6/6/14.
//  Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import "EWFacebookGraphApiClient.h"

@implementation EWFacebookGraphApiClient

+ (id)sharedClient {
    static EWFacebookGraphApiClient *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[EWFacebookGraphApiClient alloc] init];
    });
    return __instance;
}

- (void)taggableFriendsWithBlock:(EWArrayResultBlock)block
{
    /* make the API call */
    [FBRequestConnection startWithGraphPath:@"/me/taggable_friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:
     ^(
       FBRequestConnection *connection
       , NSDictionary* result
       , NSError *error
       )
    {
        NSLog(@"%@", result);
        
        NSArray* friends = [result objectForKey:@"data"];
        block(friends, error);
    }];
}

- (void)taggableFriendsDataWithBlock:(EWIdResultBlock)block
{
    /* make the API call */
    [FBRequestConnection startWithGraphPath:@"/me/taggable_friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:
     ^(
       FBRequestConnection *connection
       , NSDictionary* result
       , NSError *error
       )
     {
         NSLog(@"%@", result);
         NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:@{@"friends": [result objectForKey:@"data"], @"paging": [result objectForKey:@"paging"]}];
         block(dictionary, error);
     }];
}

- (void)taggableFriendsPaginated:(NSString *)paginationUrl withBlock:(EWIdResultBlock)block
{
    /* make the API call */
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:nil];
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:@{@"friends": [result objectForKey:@"data"], @"paging": [result objectForKey:@"paging"]}];
        NSLog(@"%@", dictionary);
        block(dictionary, error);
    }];
    
    // Override the URL using the one passed back in 'next|previous'.
    NSURL *url = [NSURL URLWithString:paginationUrl];
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
    connection.urlRequest = urlRequest;
    
    [connection start];
}

- (void)friendsListWithBlock:(EWArrayResultBlock)block
{
    /* make the API call */
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        
        NSLog(@"%@", result);
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %lu friends", (unsigned long)friends.count);
        block(friends, error);
    }];
}

- (void)searchUsersByName:(NSString *)name withBlock:(EWArrayResultBlock)block
{
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:name, @"q", @"user", @"type", nil];
    /* make the API call */
    [FBRequestConnection startWithGraphPath:@"/search" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"%@", result);
        NSArray *objects = [result objectForKey:@"data"];
        block(objects, error);
    }];
}

- (void)searchFriendsByNameFQL:(NSString *)name withBlock:(EWArrayResultBlock)block
{
    NSString *query = [NSString stringWithFormat:@"select uid, name, pic_small from user where uid in (SELECT uid2 FROM friend WHERE uid1 = me()) and (strpos(lower(name),'%@')>=0 OR strpos(name,'%@')>=0)", name, name];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    query, @"q",
                                    nil];
    /* make the API call */
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection,
                                                                                                            id result,
                                                                                                            NSError *error) {
        
        NSLog(@"%@", result);
        NSArray *objects = [result objectForKey:@"data"];
        block(objects, error);
    }];
}

- (void)friendsListFQLWithCursorPosition:(NSInteger)position withBlock:(EWArrayResultBlock)block
{
    NSInteger secondPosition = kLimit + position;
    NSString *query = [NSString stringWithFormat:@"select uid, name, pic_small from user where uid in (SELECT uid2 FROM friend WHERE uid1 = me()) LIMIT %li,%li", (long)position, (long)secondPosition];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    query, @"q",
                                    nil];
    /* make the API call */
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection,
                                                                                                            id result,
                                                                                                            NSError *error) {
        
        NSLog(@"%@", result);
        NSArray *objects = [result objectForKey:@"data"];
        block(objects, error);
    }];
}

- (void)postStatusUpdate:(NSString *)statusUpdate withTaggableFriends:(NSArray *)taggableFriends withBlock:(EWBooleanResultBlock)block
{
    // -- Note --
    // "taggableFriends" array is simply an array of NSStrings of
    // Facebook graph ids retrieved via, and distilled from,
    // the "taggableFriendsWithBlock" method of this class
    
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // permission does not exist
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"User has not given the application sufficient permissions.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Have you tried unlinking and relinking your Facebook account in the Profile tab?", nil)
                                   };
        NSError *error = [NSError errorWithDomain:EWErrorDomain
                                             code:-55
                                         userInfo:userInfo];
        block(false, error);
    } else {
        [FBRequestConnection startForPostStatusUpdate:statusUpdate place:FACEBOOK_APP_PAGE_ID tags:taggableFriends completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            block(!error, error);
        }];
    }
}
@end
