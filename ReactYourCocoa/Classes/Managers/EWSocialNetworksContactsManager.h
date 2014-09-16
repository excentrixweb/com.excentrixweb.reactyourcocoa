//
//  EWSocialNetworksRecipientsManager.h
//  AllAtOnce
//
//  Created by Tami Wright on 6/25/14.
//  Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWRecipient.h"

static NSString * const kEWSocialContactsCoderNotification = @"SocialContactsCoderNotification";
static NSString * const kEWSocialContactsLoadMoreNotification = @"SocialContactsLoadMoreNotification";

@class EWSocialNetworksContactsManager;
@protocol SocialNetworksContactsManagerDelegate <NSObject>

@required
- (void)socialNetworksContactsManagerDidSuccessfullyRetrieveContacts;
- (void)socialNetworksContactsManagerDidSuccessfullyRetrieveNextPageContacts;
@property (assign) RecipientType socialNetworkType;
@end

@interface EWSocialNetworksContactsManager : NSObject
+ (NSMutableArray *)contactsArrayForFacebookContacts:(NSArray *)objects;
+ (NSMutableArray *)contactsArrayForTwitterContacts:(NSArray *)objects;
+ (NSMutableArray *)contacts:(NSArray *)objects withFilterText:(NSString *)filterText;
- (id)initWithDelegate:(id <SocialNetworksContactsManagerDelegate>)delegate;
- (void)setIndexForContact:(EWRecipient *)aContact withBlock:(EWBooleanResultBlock)block;
- (void)addContact:(EWRecipient *)recipient;
- (void)updateContactItem:(NSDictionary *)item;
- (EWRecipient *)contactAtSelectedRowIndex:(NSInteger)rowIndex fromFiltered:(BOOL)fromFiltered;
- (void)saveCachedDataAsyncWithBlock:(EWBooleanResultBlock)block;
- (BOOL)morePagesToLoad;
- (void)loadNextPage;
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope ;

@property (readonly, strong) NSArray *contacts;
@property (strong, readonly) NSArray *filteredContacts;
@property (readonly, strong) EWRecipient *selectedContact;
@property (assign) NSInteger index;
@end
