//
//  EWFacebookGraphApiClient.h
//  allatonce
//
//  Created by Tami Wright on 6/6/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Frameworks.h"

static NSInteger  const kLimit = 400;

@interface EWFacebookGraphApiClient : NSObject
+ (id)sharedClient;
- (void)taggableFriendsWithBlock:(EWArrayResultBlock)block;
- (void)taggableFriendsDataWithBlock:(EWIdResultBlock)block;
- (void)taggableFriendsPaginated:(NSString *)paginationUrl withBlock:(EWIdResultBlock)block;
- (void)friendsListWithBlock:(EWArrayResultBlock)block;
- (void)searchUsersByName:(NSString *)name withBlock:(EWArrayResultBlock)block;
- (void)searchFriendsByNameFQL:(NSString *)name withBlock:(EWArrayResultBlock)block;
- (void)friendsListFQLWithCursorPosition:(NSInteger)position withBlock:(EWArrayResultBlock)block;
- (void)postStatusUpdate:(NSString *)statusUpdate withTaggableFriends:(NSArray *)taggableFriends withBlock:(EWBooleanResultBlock)block;
@end
