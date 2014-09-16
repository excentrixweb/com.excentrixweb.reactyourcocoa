//
//  EWFacebookParseUserClient.h
//  allatonce
//
//  Created by Tami Wright on 6/6/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWFacebookGraphApiClient.h"

@interface EWFacebookParseUserClient : NSObject

- (void)getRequestForMe:(void (^)(PFUser *user))success
             failure:(void (^)(NSError *error))failure;
@end
