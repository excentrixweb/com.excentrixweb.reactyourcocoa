//
//  EWUser.h
//  allatonce
//
//  Created by Tami Wright on 6/11/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactYourCocoa-Bridging-Header.h"

@interface EWUser : PFUser <PFSubclassing>
+ (instancetype)currentUser;
@property (retain) NSString *mobile;
@property (retain) NSString *fullName;
@property (retain) NSString *profilePictureSource;
@property (retain) NSString *faceBookId;
@property (retain) NSString *faceBookProfilePictureUrl;
@property (retain) NSString *twitterId;
@property (retain) NSString *twitterProfilePictureUrl;
@end
