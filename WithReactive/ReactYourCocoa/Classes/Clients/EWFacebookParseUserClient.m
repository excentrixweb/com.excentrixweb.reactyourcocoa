//
//  EWFacebookParseUserClient.m
//  allatonce
//
//  Created by Tami Wright on 6/6/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "EWFacebookParseUserClient.h"

@implementation EWFacebookParseUserClient

- (void)getRequestForMe:(void (^)(PFUser *user))success
             failure:(void (^)(NSError *error))failure
{
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            PFUser *currentUser = [PFUser currentUser];

            NSMutableString *url = [NSMutableString string];
            [url appendString:kEWFacebookGraphBaseURLString];
            [url appendString:userData[@"id"]];
            currentUser[@"faceBookProfilePictureUrl"] = [url stringByAppendingString:kEWFacebookPictureSuffixURLString];
            currentUser[@"faceBookId"] = userData[@"id"];
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error)
                    failure(error);
                else {
                    success(currentUser);
                }
            }];
        }
        else
        {
            failure(error);
        }
    }];
}
@end
