//
//  EWUser.m
//  allatonce
//
//  Created by Tami Wright on 6/11/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import "EWUser.h"
#import <Parse/PFObject+Subclass.h>

@implementation EWUser
@dynamic fullName;
@dynamic mobile;
@dynamic profilePictureSource;
@dynamic faceBookId;
@dynamic faceBookProfilePictureUrl;
@dynamic twitterId;
@dynamic twitterProfilePictureUrl;

// Return the current user
+ (instancetype)currentUser {
    return (EWUser *)[PFUser currentUser];
}
@end
