//
// Created by Tami Wright on 6/17/14.
// Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Frameworks.h"

@interface EWParseObjectsApiClient : NSObject

+ (id)sharedClient;

- (void)userMessageSessionsListWithBlock:(EWArrayResultBlock)block;
@end