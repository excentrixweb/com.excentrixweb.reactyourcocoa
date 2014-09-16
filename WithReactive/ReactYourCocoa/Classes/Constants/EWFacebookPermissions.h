//
//  EWFacebookPermissions.h
//  AllAtOnce
//
//  Created by Tami Wright on 7/10/14.
//  Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EWFacebookPermissions : NSObject
+ (NSArray *)all;
+ (NSArray *)publish;
+ (NSArray *)read;
@end
