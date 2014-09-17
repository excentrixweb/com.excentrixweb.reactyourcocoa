//
//  EWRecipient.m
//  allatonce
//
//  Created by Tami Wright on 6/2/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import "EWRecipient.h"
#import <Parse/PFObject+Subclass.h>

@implementation EWRecipient

@dynamic firstName;
@dynamic lastName;
@dynamic name;
@dynamic mobile;
@dynamic email;
@dynamic recipientType;
@dynamic faceBookId;
@dynamic faceBookProfilePictureUrl;
@dynamic twitterId;
@dynamic twitterProfilePictureUrl;

- (instancetype)initWithFirstName:(NSString *)aFirstName lastName:(NSString *)aLastName name:(NSString *)aName mobile:(NSString *)aMobile email:(NSString *)anEmail type:(RecipientType)aType faceBookId:(NSString *)aFaceBookId faceBookProfilePictureUrl:(NSString *)aFaceBookProfilePictureUrl twitterId:(NSString *)aTwitterId twitterProfilePictureUrl:(NSString *)aTwitterProfilePictureUrl {
    self = [super init];
    if (self) {
        self.firstName = aFirstName;
        self.lastName = aLastName;
        self.name = aName;
        self.mobile = aMobile;
        self.email = anEmail;
        self.recipientType = aType;
        self.faceBookId = aFaceBookId;
        self.faceBookProfilePictureUrl = aFaceBookProfilePictureUrl;
        self.twitterId = aTwitterId;
        self.twitterProfilePictureUrl = aTwitterProfilePictureUrl;
    }

    return self;
}

+ (instancetype)recipientWithFirstName:(NSString *)firstName lastName:(NSString *)lastName name:(NSString *)name mobile:(NSString *)mobile email:(NSString *)email type:(RecipientType)type faceBookId:(NSString *)faceBookId faceBookProfilePictureUrl:(NSString *)faceBookProfilePictureUrl twitterId:(NSString *)twitterId twitterProfilePictureUrl:(NSString *)twitterProfilePictureUrl {
    return [[self alloc] initWithFirstName:firstName lastName:lastName name:name mobile:mobile email:email type:type faceBookId:faceBookId faceBookProfilePictureUrl:faceBookProfilePictureUrl twitterId:twitterId twitterProfilePictureUrl:twitterProfilePictureUrl];
}

+ (NSString *)parseClassName
{
    return kPFRecipientClassName;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.firstName = [decoder decodeObjectForKey:@"firstName"];
    self.lastName = [decoder decodeObjectForKey:@"lastName"];
    self.name = [decoder decodeObjectForKey:@"name"];
    self.mobile = [decoder decodeObjectForKey:@"mobile"];
    self.email = [decoder decodeObjectForKey:@"email"];
    self.recipientType = [decoder decodeIntegerForKey:@"recipientType"];
    self.faceBookId = [decoder decodeObjectForKey:@"faceBookId"];
    self.faceBookProfilePictureUrl = [decoder decodeObjectForKey:@"faceBookProfilePictureUrl"];
    self.twitterId = [decoder decodeObjectForKey:@"twitterId"];
    self.twitterProfilePictureUrl = [decoder decodeObjectForKey:@"twitterProfilePictureUrl"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.firstName forKey:@"title"];
    [encoder encodeObject:self.lastName forKey:@"author"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.mobile forKey:@"mobile"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeInteger:self.recipientType forKey:@"recipientType"];
    [encoder encodeObject:self.faceBookId forKey:@"faceBookId"];
    [encoder encodeObject:self.faceBookProfilePictureUrl forKey:@"faceBookProfilePictureUrl"];
    [encoder encodeObject:self.twitterId forKey:@"twitterId"];
    [encoder encodeObject:self.twitterProfilePictureUrl forKey:@"twitterProfilePictureUrl"];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[EWRecipient class]])
    {
        EWRecipient *compareObject = (EWRecipient *)object;
        [compareObject fetchIfNeeded];
        [self fetchIfNeeded];
        return
        (self.firstName && compareObject.firstName && [self.firstName isEqualToString:compareObject.firstName])
        && (self.lastName && compareObject.lastName && [self.lastName isEqualToString:compareObject.lastName])
        && (self.name && compareObject.name && [self.name isEqualToString:compareObject.name])
        && (self.mobile && compareObject.mobile && [self.mobile isEqualToString:compareObject.mobile])
        && (self.email && compareObject.email && [self.email isEqualToString:compareObject.email])
        && self.recipientType == compareObject.recipientType
        && (self.faceBookId && compareObject.faceBookId && [self.faceBookId isEqualToString:compareObject.faceBookId])
        && (self.faceBookProfilePictureUrl && compareObject.faceBookProfilePictureUrl && [self.faceBookProfilePictureUrl isEqualToString:compareObject.faceBookProfilePictureUrl])
        && (self.twitterId && compareObject.twitterId && [self.twitterId isEqualToString:compareObject.twitterId])
        && (self.twitterProfilePictureUrl && compareObject.twitterProfilePictureUrl && [self.twitterProfilePictureUrl isEqualToString:compareObject.twitterProfilePictureUrl]);
    }
    else
        return NO;
}

- (NSUInteger)hash {
    [self fetchIfNeeded];
    NSString *firstName = self.firstName ?: @"";
    NSString *lastName = self.lastName ?: @"";
    NSString *name = self.name ?: @"";
    NSString *mobile = self.mobile ?: @"";
    NSString *email = self.email ?: @"";
    NSString *faceBookId = self.faceBookId ?: @"";
    NSString *faceBookProfilePictureUrl = self.faceBookProfilePictureUrl ?: @"";
    NSString *twitterId = self.twitterId ?: @"";
    NSString *twitterProfilePictureUrl = self.twitterProfilePictureUrl ?: @"";
    return [firstName hash] ^ [lastName hash] ^ [name hash] ^ [mobile hash] ^ [email hash] ^ self.recipientType ^ [faceBookId hash] ^ [faceBookProfilePictureUrl hash] ^ [twitterId hash] ^ [twitterProfilePictureUrl hash];
}

@end
