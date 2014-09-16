//
// Created by Tami Wright on 6/6/14.
// Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import "EWTwitterApiParseUserClient.h"


static NSString * const kEWAccountSettingsURLString = @"account/settings.json";
static NSString * const kEWAccountVerifyCredentialsURLString = @"account/verify_credentials.json";
static NSString * const kEWUsersShowURLString = @"users/show.json";
static NSString * const kEWFriendsListURLString = @"friends/list.json";
static NSString * const kEWFollowersListURLString = @"followers/list.json";
static NSString * const kEWDirectMessageNewURLString = @"direct_messages/new.json";

@implementation EWTwitterApiParseUserClient {

}

+ (id)sharedClient {
    static EWTwitterApiParseUserClient *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[EWTwitterApiParseUserClient alloc] init];
    });
    return __instance;
}

#pragma mark - GET
/** 
 * account/verify_credentials.json
 */
- (void)verifyCredentials:(void (^)(PFUser *user))success
             failure:(void (^)(NSError *error))failure
{
    /** Local variables
     */
    NSError* error;
    NSURLResponse *response = nil;
    NSData *data = nil;
    NSMutableString *urlString = [NSMutableString string];
    NSMutableURLRequest *request = nil;
    NSURL *url = nil;
    NSDictionary *userData = nil;

    [urlString appendString:TwitterBaseURLString];
    url = [NSURL URLWithString:[urlString stringByAppendingString:kEWAccountVerifyCredentialsURLString]];
    request = [NSMutableURLRequest requestWithURL:url];
    [[PFTwitterUtils twitter] signRequest:request];
    data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    userData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"Twitter call results for %@: %@", kEWAccountVerifyCredentialsURLString, userData);
    EWUser *currentUser = [EWUser currentUser];
    currentUser.twitterId = [((NSNumber *)userData[@"id"]) stringValue];
    NSString *normalImageUrl = (NSString*)userData[@"profile_image_url"];
    NSArray *imageUrlArray = [normalImageUrl componentsSeparatedByString:@"png"];
    NSRange range = [((NSString*)imageUrlArray[0]) rangeOfString:@"_" options:NSBackwardsSearch];
    NSString *imageUrlPrefix = [((NSString*)imageUrlArray[0]) substringToIndex:range.location+1];
    currentUser.twitterProfilePictureUrl = [NSString stringWithFormat:@"%@400x400.png", imageUrlPrefix];
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
            failure(error);
        else {
            success(currentUser);
        }
    }];
}

/** 
 * users/show.json
 */
- (void)showUser:(NSString *)userId
            success:(void (^)(PFUser *))success
            failure:(void (^)(NSError *))failure
{
    /** Local variables
     */
    NSError *error;
    NSURLResponse *response = nil;
    NSData *data = nil;
    NSMutableString *urlString = [NSMutableString string];
    NSMutableURLRequest *request = nil;
    NSURL *url = nil;
    NSDictionary *userData = nil;
    
    urlString = [NSMutableString string];
    [urlString appendString:TwitterBaseURLString];
    [urlString appendString:kEWUsersShowURLString];
    url = [NSURL URLWithString:[urlString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@", userId]]];
    request = [NSMutableURLRequest requestWithURL:url];
    [[PFTwitterUtils twitter] signRequest:request];
    data = [NSURLConnection sendSynchronousRequest:request
                                 returningResponse:&response
                                             error:&error];
    
    userData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSLog(@"Twitter call results for %@: %@", kEWUsersShowURLString, userData);
    EWUser *currentUser = [EWUser currentUser];
    currentUser.twitterId = [((NSNumber *)userData[@"id"]) stringValue];
    NSString *normalImageUrl = (NSString*)userData[@"profile_image_url"];
    NSArray *imageUrlArray = [normalImageUrl componentsSeparatedByString:@"png"];
    NSRange range = [((NSString*)imageUrlArray[0]) rangeOfString:@"_" options:NSBackwardsSearch];
    NSString *imageUrlPrefix = [((NSString*)imageUrlArray[0]) substringToIndex:range.location+1];
    currentUser.twitterProfilePictureUrl = [NSString stringWithFormat:@"%@400x400.png", imageUrlPrefix];
    
}


/**
 * followers/list.json
 */
- (void)followersOfUser:(NSString *)userId
             withNextCursor:(NSString *)nextCursor
            withBlock:(EWIdResultBlock)block
{
    /** Local variables
     */
    NSMutableString *urlString = [NSMutableString string];
    NSMutableURLRequest *request = nil;
    NSURL *url = nil;
    
    urlString = [NSMutableString string];
    [urlString appendString:TwitterBaseURLString];
    [urlString appendString:kEWFollowersListURLString];
    url = [NSURL URLWithString:[urlString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@&cursor=%@&skip_status=true&include_user_entities=false&count=200", userId, nextCursor?: @"-1"]]];
    request = [NSMutableURLRequest requestWithURL:url];
    [[PFTwitterUtils twitter] signRequest:request];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError* error;
        NSDictionary *result;
        if (!connectionError)
        {
            NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
#if DEBUG
            NSLog(@"Twitter call results for %@: %@", kEWFollowersListURLString, userData);
#endif
            if (!error)
            {
                if ([userData objectForKey:@"users"] != [NSNull null])
                {
                    result = @{@"friends": [userData objectForKey:@"users"], @"paging": @{@"next_cursor": [[userData objectForKey:@"next_cursor"] stringValue]}};
                }
                else
                {
#warning Log and alert when rate limited by Twitter
                    result = @{@"friends": [[NSArray alloc] init], @"paging": @{@"next_cursor": @"0"}};                    
                }
            }
            block(result, error);
        }
        else
            block(result, connectionError);
    }];
    
}

#pragma mark - POST
/**
 * direct_messages/new.json
 */
- (void)directMessage:(NSString *)message
               toUser:(NSString *)userId
     withBlock:(EWBooleanResultBlock)block
{
    /** Local variables
     */
    NSMutableString *urlString = [NSMutableString string];
    NSMutableURLRequest *request = nil;
    NSURL *url = nil;
    
    urlString = [NSMutableString string];
    [urlString appendString:TwitterBaseURLString];
    [urlString appendString:kEWDirectMessageNewURLString];
    message = ([message length] > kEWTwitterMessageMaxSize) ? [NSString stringWithFormat:@"%@...", [message substringToIndex:kEWTwitterMessageMaxSize - 3]] : message;
    NSString *bodyString = [NSString stringWithFormat:@"text=%@&user_id=%@", [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], userId];
    
    // Explicitly percent-escape the '!' character.
    bodyString = [bodyString stringByReplacingOccurrencesOfString:@"!" withString:@"%21"];
    url = [NSURL URLWithString:urlString];
    request = [NSMutableURLRequest requestWithURL:url];
    // Specify that it will be a POST request
    request.HTTPMethod = @"POST";
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [[PFTwitterUtils twitter] signRequest:request];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
#if DEBUG
            if (connectionError)
                NSLog(@"Direct message error: %@", connectionError);
#endif
            block(!connectionError, connectionError);
    }];
    
}

/**
 * direct_messages/new.json
 */
- (void)directMessage:(NSString *)message
              toUsers:(NSArray *)userIds
            withBlock:(EWBooleanResultBlock)block
{
    /** Local variables
     */
    NSMutableString *urlString = [NSMutableString string];
    NSURL *url = nil;
    
    urlString = [NSMutableString string];
    [urlString appendString:TwitterBaseURLString];
    [urlString appendString:kEWDirectMessageNewURLString];
    message = ([message length] > kEWTwitterMessageMaxSize) ? [NSString stringWithFormat:@"%@...", [message substringToIndex:kEWTwitterMessageMaxSize - 3]] : message;
    NSError* error;
    for (NSString *userId in userIds)
    {
        NSURLResponse *response = nil;
        NSMutableURLRequest *request = nil;
        NSData *data = nil;
        NSString *bodyString = [NSString stringWithFormat:@"text=%@&user_id=%@", [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], userId];
        
        // Explicitly percent-escape the '!' character.
        bodyString = [bodyString stringByReplacingOccurrencesOfString:@"!" withString:@"%21"];
        url = [NSURL URLWithString:urlString];
        request = [NSMutableURLRequest requestWithURL:url];
        // Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
            
        [[PFTwitterUtils twitter] signRequest:request];
            
        data = [NSURLConnection sendSynchronousRequest:request
                                     returningResponse:&response
                                                 error:&error];
        if (error)
            break;
    }
    block(!error, error);
}
@end