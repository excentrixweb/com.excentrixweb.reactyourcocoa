//
//  Constants.h
//  ReactYourCocoa
//
//  Created by Tami Wright on 9/16/14.
//  Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#ifndef ReactYourCocoa_Constants_h
#define ReactYourCocoa_Constants_h


#pragma mark - DEV
#define TWITTER_API_KEY @"ve6wQxLQHkADBnj7YEgCMyIy4"
#define TWITTER_API_SECRET @"gyBOeZUBIAnvcjhokaeIK1hMvU55UIxUhH63wB3mzinYoN8fCQ"
#define PARSE_APPLICATION_ID @"EXcJvb9n5KZUGosZq87cm86ijeSxYiHc8cH7yLDk"
#define PARSE_CLIENT_KEY @"lqUsCaNLSdzhGzGj7xWwUljdrumsrlFwmLCsKqpH"
#define FACEBOOK_APP_PAGE_ID @"355436947966583"

#pragma mark - Facebook Config
static NSString * const kEWFacebookGraphBaseURLString = @"http://graph.facebook.com/";
static NSString * const kEWFacebookPictureSuffixURLString = @"/picture?type=large&return_ssl_resources=1";

#pragma mark - Blocks
typedef void (^EWBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^EWArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^EWIdResultBlock)(id object, NSError *error);

#pragma mark - Twilio Config
static NSInteger const kEWTwilioMessageMaxSize = 160;

#pragma mark - Twitter Config
static NSInteger const kEWTwitterMessageMaxSize = 140;

#pragma mark - Error domains
static NSString * const EWErrorDomain = @"com.excentrixweb.ErrorDomain";

#endif
