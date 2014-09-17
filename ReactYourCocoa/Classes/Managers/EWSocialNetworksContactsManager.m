//
//  EWSocialNetworksRecipientsManager.m
//  AllAtOnce
//
//  Created by Tami Wright on 6/25/14.
//  Copyright (c) 2014 Excentrix Web, Inc. All rights reserved.
//

#import "EWSocialNetworksContactsManager.h"
#import "EWFacebookGraphApiClient.h"
#import "EWTwitterApiParseUserClient.h"
#import "NSTimer+Blocks.h"

static NSString * const kEWCacheFacebookContactsManagerData = @"cacheFacebookContactsManagerData";
static NSString * const kEWCacheTwitterContactsManagerData = @"cacheTwitterContactsManagerData";

@implementation EWSocialNetworksContactsManager
{    
    EWFacebookGraphApiClient *_faceBookClient;
    EWTwitterApiParseUserClient *_twitterClient;
    NSMutableArray *_contacts;
    NSMutableArray *_filteredContacts;
    NSMutableArray *_cachedContacts;
    NSMutableDictionary *_pagination;
    NSString *_searchText;
    BOOL _fromFiltered;
    id<SocialNetworksContactsManagerDelegate> _delegate;
    dispatch_queue_t _queue;
}

@synthesize contacts = _contacts;
@synthesize filteredContacts = _filteredContacts;

#pragma mark - Class methods
+ (NSMutableArray *)contactsArrayForFacebookContacts:(NSArray *)objects
{
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    for (NSDictionary *user in objects)
    {
        EWRecipient *contact;
        NSString *name = [user objectForKey:@"name"];
        contact = [[EWRecipient alloc] initWithFirstName:nil lastName:nil name:name mobile:nil email:nil type:FACEBOOK faceBookId:[user objectForKey:@"id"] faceBookProfilePictureUrl:[((NSDictionary *)[((NSDictionary*)[user objectForKey:@"picture"]) objectForKey:@"data"]) objectForKey:@"url"]  twitterId:nil twitterProfilePictureUrl:nil];
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:@{@"contact": contact, @"actualImage": [NSNull null]}];
        [resultArray addObject:item];
    }
    return resultArray;
}

+ (NSMutableArray *)contactsArrayForTwitterContacts:(NSArray *)objects
{
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    for (NSDictionary *user in objects)
    {
        EWRecipient *contact;
        NSString *name = [user objectForKey:@"name"];
        contact = [[EWRecipient alloc] initWithFirstName:nil lastName:nil name:name mobile:nil email:nil type:TWITTER faceBookId:nil faceBookProfilePictureUrl:nil twitterId:[user objectForKey:@"id_str"] twitterProfilePictureUrl:[user objectForKey:@"profile_image_url"]];
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:@{@"contact": contact, @"actualImage": [NSNull null]}];
        [resultArray addObject:item];
    }
    return resultArray;
}

+ (NSMutableArray *)contacts:(NSArray *)objects withFilterText:(NSString *)filterText
{
    if (filterText)
    {
        NSArray *enumerateArray = [NSArray arrayWithArray:objects];
        NSMutableArray *contactsArray = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *item in enumerateArray)
        {
            EWRecipient *contact = [item objectForKey:@"contact"];
            if ([contact.name rangeOfString:filterText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [contactsArray addObject:item];
            }
        }
        return contactsArray;
    }
    else
        return [[NSMutableArray alloc] initWithArray: objects];
}

#pragma mark - Class life cycle
- (id)initWithDelegate:(id <SocialNetworksContactsManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _faceBookClient = [EWFacebookGraphApiClient sharedClient];
        _twitterClient = [EWTwitterApiParseUserClient sharedClient];
        _contacts = [[NSMutableArray alloc] init];
        _cachedContacts = [[NSMutableArray alloc] init];
        _pagination = [[NSMutableDictionary alloc] init];
        _queue = dispatch_queue_create("com.excentrixweb.contactsqueue", 0);
        [self retrieveCachedData];
        [self refreshContacts];
    }
    return self;
}

- (void)dealloc
{
    _cachedContacts = nil;
    _contacts = nil;
    _pagination = nil;
    _delegate = nil;
    _filteredContacts = nil;
    _searchText = nil;
}

#pragma mark - Private
- (void)refreshContacts
{
    @synchronized(self)
    {
        if (!_cachedContacts || [_cachedContacts count] <= 0)
        {
            if (_delegate.socialNetworkType == FACEBOOK)
            {
                [_faceBookClient taggableFriendsDataWithBlock:^(id result, NSError *error) {
                    [self loadContactsDataFromModel:(NSDictionary *)result isInit:YES];
                }];
            }
            if (_delegate.socialNetworkType == TWITTER)
            {
                [_twitterClient followersOfUser:[EWUser currentUser].twitterId withNextCursor:nil withBlock:^(id result, NSError *error) {
                    [self loadContactsDataFromModel:(NSDictionary *)result isInit:YES];
                }];
            }
        }
        else
        {
            _contacts = [[NSMutableArray alloc] initWithArray: _cachedContacts] ;
            [_filteredContacts removeAllObjects];
            _filteredContacts = [NSMutableArray arrayWithCapacity:[_contacts count]];
            if([_delegate respondsToSelector:@selector(socialNetworksContactsManagerDidSuccessfullyRetrieveContacts)]) {
                [_delegate socialNetworksContactsManagerDidSuccessfullyRetrieveContacts];
            }        }
    }
}

-(void)loadMoreContacts
{
    if (_delegate.socialNetworkType == FACEBOOK)
    {
        NSString *nextUrl = [_pagination objectForKey:@"next"];
        if (nextUrl)
        {
            [_faceBookClient taggableFriendsPaginated:nextUrl withBlock:^(id result, NSError *error) {
                [self loadContactsDataFromModel:(NSDictionary *)result isInit:NO];
            }];
        }
    }
    if (_delegate.socialNetworkType == TWITTER)
    {
        NSString *nextCursor = [_pagination objectForKey:@"next_cursor"];
        if (nextCursor)
        {
            [_twitterClient followersOfUser:[EWUser currentUser].twitterId withNextCursor:nextCursor withBlock:^(id result, NSError *error) {
                [self loadContactsDataFromModel:(NSDictionary *)result isInit:NO];
            }];
        }
    }
}

- (void)loadContactsDataFromModel:(NSDictionary *)model isInit:(BOOL)init
{
    @synchronized(self)
    {
        _pagination = [model objectForKey:@"paging"];
        if (init) {
            dispatch_async(_queue, ^{
                _contacts = [NSMutableArray arrayWithArray:((_delegate.socialNetworkType == FACEBOOK) ? [EWSocialNetworksContactsManager contactsArrayForFacebookContacts:[model objectForKey:@"friends"]] : [EWSocialNetworksContactsManager contactsArrayForTwitterContacts:[model objectForKey:@"friends"]])];
                _cachedContacts = [NSMutableArray arrayWithArray:_contacts];
                [_filteredContacts removeAllObjects];
                _filteredContacts = [NSMutableArray arrayWithCapacity:[_contacts count]];
                [self saveCachedData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([_delegate respondsToSelector:@selector(socialNetworksContactsManagerDidSuccessfullyRetrieveContacts)]) {
                        [_delegate socialNetworksContactsManagerDidSuccessfullyRetrieveContacts];
                    }
                });
            });

        }
        else {
            dispatch_async(_queue, ^{
                [_cachedContacts addObjectsFromArray:((_delegate.socialNetworkType == FACEBOOK) ? [EWSocialNetworksContactsManager contactsArrayForFacebookContacts:[model objectForKey:@"friends"]] : [EWSocialNetworksContactsManager contactsArrayForTwitterContacts:[model objectForKey:@"friends"]])];
                [_contacts removeAllObjects];
                _contacts = [[NSMutableArray alloc] initWithArray:_cachedContacts];
                [self filterContentForSearchText:nil scope:nil];
                _fromFiltered = (_searchText && [_searchText length] > 0);
                [self saveCachedDataAsyncWithBlock:^(BOOL succeeded, NSError *error) {                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([_delegate respondsToSelector:@selector(socialNetworksContactsManagerDidSuccessfullyRetrieveNextPageContacts)]) {
                            [_delegate socialNetworksContactsManagerDidSuccessfullyRetrieveNextPageContacts];
                        }
                    });
                }];
            });
        }
    }
}

#pragma mark - KeyValue caching
- (void)saveCachedData
{
    @synchronized(self)
    {
        NSMutableDictionary *contactsManagerData = [[NSMutableDictionary alloc] initWithDictionary:@{@"contactsData": _cachedContacts, @"pagingData": _pagination}];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:contactsManagerData];
        NSString *key = _delegate.socialNetworkType == FACEBOOK ? kEWCacheFacebookContactsManagerData : kEWCacheTwitterContactsManagerData;
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    }
}

- (void)saveCachedDataAsyncWithBlock:(EWBooleanResultBlock)block
{
    dispatch_async(_queue, ^{
        [self saveCachedData];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(true, nil);
        });
    });
}

- (void)retrieveCachedData
{
    NSString *key = _delegate.socialNetworkType == FACEBOOK ? kEWCacheFacebookContactsManagerData : kEWCacheTwitterContactsManagerData;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (data)
    {
        NSMutableDictionary *contactsManagerData = [NSKeyedUnarchiver unarchiveObjectWithData:data];        
        @synchronized(self)
        {
            _cachedContacts = [contactsManagerData objectForKey:@"contactsData"];
            _pagination = [contactsManagerData objectForKey:@"pagingData"];
        }
    }
}

#pragma mark - Properties methods
- (NSArray *)contacts {
    @synchronized(self)
    {
        return (NSArray *)_contacts;
    }
}

- (EWRecipient *)selectedContact {
    
    @synchronized(self)
    {
        if (_fromFiltered)
            return ((self.index <= ([_filteredContacts count] - 1)) ? (EWRecipient *)[((NSDictionary *)_filteredContacts[self.index]) objectForKey:@"contact"] : nil);
        else
            return ((self.index <= ([_contacts count] - 1)) ? (EWRecipient *)[((NSDictionary *)_contacts[self.index]) objectForKey:@"contact"] : nil);
    }
}

- (EWRecipient *)contactAtSelectedRowIndex:(NSInteger)rowIndex fromFiltered:(BOOL)fromFiltered {
    @synchronized(self)
    {
        _fromFiltered = fromFiltered;
        self.index = rowIndex;
        return [self selectedContact];
    }
}

- (void)setIndexForContact:(EWRecipient *)aContact withBlock:(EWBooleanResultBlock)block
{
    @synchronized(self)
    {
        dispatch_async(_queue, ^{
            NSArray *enumerateArray = [NSArray arrayWithArray:_contacts];
            int counter = 0;
            for (NSDictionary *item in enumerateArray)
            {
                EWRecipient *contact = (EWRecipient *)[item objectForKey:@"contact"];
                if ([contact.objectId isEqualToString:aContact.objectId])
                {
                    self.index = counter;
                    break;
                }
                counter++;
            }
            
            block(self.index >= 0, nil);
        });
    }
}

- (void)addContact:(EWRecipient *)contact
{
    @synchronized(self)
    {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:@{@"contact": contact, @"actualImage": [NSNull null]}];
        [_contacts addObject:item];
        self.index = [_contacts indexOfObject:item];
    }
}

- (void)updateContactItem:(NSDictionary *)item
{
    @synchronized(self)
    {
        dispatch_async(_queue, ^{
            EWRecipient *contact = [item objectForKey:@"contact"];
            
            NSArray *enumerateArray = [NSArray arrayWithArray:_cachedContacts];
            int counter = 0;
            for (NSMutableDictionary *entry in enumerateArray)
            {
                EWRecipient *entryContact = [entry objectForKey:@"contact"];
                if (_delegate.socialNetworkType == FACEBOOK)
                {
                    if ([entryContact.faceBookId isEqualToString:contact.faceBookId])
                    {
                        [_cachedContacts replaceObjectAtIndex:counter withObject:item];
                        
                    }
                }
                else
                {
                    if ([entryContact.twitterId isEqualToString:contact.twitterId])
                    {
                    }
                }
                counter++;
            }                
        });
    }
}

#pragma mark - Filtering

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    searchText = searchText ?: _searchText;
    if (searchText)
    {
        [_filteredContacts removeAllObjects];
        // Filter the array using NSPredicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.contact.name contains[c] %@",searchText];
        _filteredContacts = [NSMutableArray arrayWithArray:[_contacts filteredArrayUsingPredicate:predicate]];
        _searchText = searchText;
    }
}

#pragma mark - Pagination
- (BOOL)morePagesToLoad
{
    @synchronized(self)
    {
        NSString *next = (_delegate.socialNetworkType == FACEBOOK) ? [_pagination objectForKey:@"next"] : [_pagination objectForKey:@"next_cursor"];
        return (next && [next length] > 0 && ![next isEqualToString:@"0"]);
    }
}

- (void)loadNextPage
{
    if ([self morePagesToLoad])
        [self loadMoreContacts];
    else
        NSLog(@"No more contacts to load");
}
@end
