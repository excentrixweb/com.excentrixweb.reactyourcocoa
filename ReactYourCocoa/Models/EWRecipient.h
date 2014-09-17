//
//  EWRecipient.h
//  allatonce
//
//  Created by Tami Wright on 6/2/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWMessageSession.h"

typedef enum {
PHONEBOOK = 0,
FACEBOOK,
TWITTER,
EMAIL
} RecipientType ;

static NSString * const kPFRecipientClassName = @"Recipient";
static NSString * const kPFFirstNameFieldName = @"firstName";
static NSString * const kPFLastNameFieldName = @"lastName";
static NSString * const kPFNameFieldName = @"name";
static NSString * const kPFMobileFieldName = @"mobile";
static NSString * const kPFEmailFieldName = @"email";
static NSString * const kPFTypeFieldName = @"type";
static NSString * const kPFFaceBookIdFieldName = @"faceBookId";
static NSString * const kPFFaceBookProfilePictureUrlFieldName = @"faceBookProfilePictureUrl";
static NSString * const kPFTwitterIdFieldName = @"twitterId";
static NSString * const kPFtwitterProfilePictureUrlFieldName = @"twitterProfilePictureUrl";

@interface EWRecipient : PFObject <PFSubclassing, NSCoding>

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *mobile;
@property (strong, nonatomic) NSString *email;
@property (assign) RecipientType recipientType;
@property (strong, nonatomic) NSString *faceBookId;
@property (strong, nonatomic) NSString *faceBookProfilePictureUrl;
@property (strong, nonatomic) NSString *twitterId;
@property (strong, nonatomic) NSString *twitterProfilePictureUrl;

- (instancetype)initWithFirstName:(NSString *)aFirstName lastName:(NSString *)aLastName name:(NSString *)aName mobile:(NSString *)aMobile email:(NSString *)anEmail type:(RecipientType)aType faceBookId:(NSString *)aFaceBookId faceBookProfilePictureUrl:(NSString *)aFaceBookProfilePictureUrl twitterId:(NSString *)aTwitterId twitterProfilePictureUrl:(NSString *)aTwitterProfilePictureUrl;

+ (instancetype)recipientWithFirstName:(NSString *)firstName lastName:(NSString *)lastName name:(NSString *)name mobile:(NSString *)mobile email:(NSString *)email type:(RecipientType)type faceBookId:(NSString *)faceBookId faceBookProfilePictureUrl:(NSString *)faceBookProfilePictureUrl twitterId:(NSString *)twitterId twitterProfilePictureUrl:(NSString *)twitterProfilePictureUrl;

+ (NSString *)parseClassName;
@end
