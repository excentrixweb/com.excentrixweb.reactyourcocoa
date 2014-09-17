//
//  EWMessage.h
//  allatonce
//
//  Created by Tami Wright on 6/10/14.
//  Copyright (c) 2014 Excentrix Web Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWMessageSession.h"

static NSString * const kPFMessageClassName = @"Message";
static NSString * const kPFMessageTextFieldName = @"messageText";
static NSString * const kPFImagesFieldName = @"images";

@interface EWMessage : PFObject <PFSubclassing>
@property (nonatomic, strong) NSString *messageText;
@property (nonatomic, strong) NSMutableArray *images;

- (instancetype)initWithMessageText:(NSString *)aMessageText images:(NSMutableArray *)imagesArray;

+ (instancetype)messageWithMessageText:(NSString *)messageText images:(NSMutableArray *)images;

+ (NSString *)parseClassName;
@end
