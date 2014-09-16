//
//  EWFacebookPermissions.m
//  AllAtOnce
//
//  Created by Tami Wright on 7/10/14.
//  Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import "EWFacebookPermissions.h"

@implementation EWFacebookPermissions
+ (NSArray *)all
{
    static NSArray *_all;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _all = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"read_friendlists", @"publish_actions"];
    });
    return _all;
}
+ (NSArray *)publish
{
    static NSArray *_publish;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _publish = @[@"publish_actions"];
    });
    return _publish;
}
+ (NSArray *)read
{
    static NSArray *_read;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _read = @[@"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"read_friendlists"];
    });
    return _read;
}
@end
