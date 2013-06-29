/*
 * Copyright 2012-2013 StackMob
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Kiwi/Kiwi.h>
#import "SMNetworkReachabilityHelper.h"
#import "SMIntegrationTestHelpers.h"

SPEC_BEGIN(RelationshipsSpec)

describe(@"Upsert", ^{
    __block SMDataStore *dataStore;
    beforeAll(^{
        dataStore = [SMIntegrationTestHelpers dataStore];
    });
    afterAll(^{
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_group_t group = dispatch_group_create();
        
        __block NSArray *todos = nil;
        __block NSArray *categories = nil;
        __block NSArray *favorites = nil;
        
        SMQuery *todoQuery = [[SMQuery alloc] initWithSchema:@"todo"];
        dispatch_group_enter(group);
        [dataStore performQuery:todoQuery options:nil successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSArray *results) {
            todos = results;
            [todos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                dispatch_group_enter(group);
                [dataStore deleteObjectId:[obj valueForKey:@"todo_id"] inSchema:@"todo" options:nil successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSString *objectId, NSString *schema) {
                    dispatch_group_leave(group);
                } onFailure:^(NSError *error, NSString *objectId, NSString *schema) {
                    [error shouldBeNil];
                    dispatch_group_leave(group);
                }];
            }];
            
            dispatch_group_leave(group);
        } onFailure:^(NSError *error) {
            [error shouldBeNil];
            dispatch_group_leave(group);
        }];
        
        SMQuery *categoryQuery = [[SMQuery alloc] initWithSchema:@"category"];
        dispatch_group_enter(group);
        [dataStore performQuery:categoryQuery options:nil successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSArray *results) {
            categories = results;
            [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                dispatch_group_enter(group);
                [dataStore deleteObjectId:[obj valueForKey:@"category_id"] inSchema:@"category" options:nil successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSString *objectId, NSString *schema) {
                    dispatch_group_leave(group);
                } onFailure:^(NSError *error, NSString *objectId, NSString *schema) {
                    [error shouldBeNil];
                    dispatch_group_leave(group);
                }];
            }];
            
            dispatch_group_leave(group);
        } onFailure:^(NSError *error) {
            [error shouldBeNil];
            dispatch_group_leave(group);
        }];
        
        SMQuery *favoriteQuery = [[SMQuery alloc] initWithSchema:@"favorite"];
        dispatch_group_enter(group);
        [dataStore performQuery:favoriteQuery options:nil successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSArray *results) {
            favorites = results;
            [favorites enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                dispatch_group_enter(group);
                [dataStore deleteObjectId:[obj valueForKey:@"favorite_id"] inSchema:@"favorite" options:nil successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSString *objectId, NSString *schema) {
                    dispatch_group_leave(group);
                } onFailure:^(NSError *error, NSString *objectId, NSString *schema) {
                    [error shouldBeNil];
                    dispatch_group_leave(group);
                }];
            }];
            
            dispatch_group_leave(group);
        } onFailure:^(NSError *error) {
            [error shouldBeNil];
            dispatch_group_leave(group);
        }];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        dataStore = nil;
    });
    it(@"Create new todo and category", ^{
        // Create category object. We can specify a manual primary key if we wish, otherwise one will be automatically assigned when it's created.
        NSDictionary *categoryObject = [NSDictionary dictionaryWithObjectsAndKeys:@"Home Projects", @"name", nil];
        
        NSDictionary *todoObject = [NSDictionary dictionaryWithObjectsAndKeys:@"new todo", @"title", categoryObject, @"category", nil];
        
        // Correlate the key "category" to the StackMob "category" schema
        SMRequestOptions *options = [SMRequestOptions options];
        [options associateKey:@"category" withSchema:@"category"];
        
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_group_t group = dispatch_group_create();
        __block BOOL success = NO;
        __block BOOL timeout = YES;
        
        dispatch_group_enter(group);
        // Execute request
        [dataStore createObject:todoObject inSchema:@"todo" options:options successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSDictionary *object, NSString *schema) {
            // Result will contain the entire todo object, as well as the entire nested category object.
            success = YES;
            timeout = NO;
            dispatch_group_leave(group);
        } onFailure:^(NSError *error, NSDictionary *object, NSString *schema) {
            // Handle error
            [error shouldBeNil];
            timeout = NO;
            dispatch_group_leave(group);
        }];
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 45);
        dispatch_group_wait(group, time);
        
        [[theValue(success) should] beYes];
        [[theValue(timeout) should] beNo];
        
    });
    it(@"Create new todo and category with existing headers", ^{
        
        // Create category object. We can specify a manual primary key if we wish, otherwise one will be automatically assigned when it's created.
        NSDictionary *categoryObject = [NSDictionary dictionaryWithObjectsAndKeys:@"Home Projects", @"name", nil];
        
        NSDictionary *todoObject = [NSDictionary dictionaryWithObjectsAndKeys:@"new todo", @"title", categoryObject, @"category", nil];
        
        // Correlate the key "category" to the StackMob "category" schema
        SMRequestOptions *options = [SMRequestOptions optionsWithHeaders:[NSDictionary dictionaryWithObjectsAndKeys:@"something", @"someheader", nil]];
        [options associateKey:@"category" withSchema:@"category"];
        
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_group_t group = dispatch_group_create();
        __block BOOL success = NO;
        __block BOOL timeout = YES;
        
        dispatch_group_enter(group);
        // Execute request
        [dataStore createObject:todoObject inSchema:@"todo" options:options successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSDictionary *object, NSString *schema) {
            // Result will contain the entire todo object, as well as the entire nested category object.
            success = YES;
            timeout = NO;
            dispatch_group_leave(group);
        } onFailure:^(NSError *error, NSDictionary *object, NSString *schema) {
            // Handle error
            [error shouldBeNil];
            timeout = NO;
            dispatch_group_leave(group);
        }];
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 45);
        dispatch_group_wait(group, time);
        
        [[theValue(success) should] beYes];
        [[theValue(timeout) should] beNo];
        
    });
    it(@"Create new todo and update existing category", ^{
        // Create category object. We can specify a manual primary key if we wish, otherwise one will be automatically assigned when it's created.
        NSDictionary *categoryObject = [NSDictionary dictionaryWithObjectsAndKeys:@"Home Projects", @"name", @"1234", @"genre", nil];
        
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_group_t group = dispatch_group_create();
        __block BOOL success = NO;
        __block BOOL timeout = YES;
        __block NSString *categoryId = nil;
        
        dispatch_group_enter(group);
        // Execute request
        [dataStore createObject:categoryObject inSchema:@"category" options:nil successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSDictionary *object, NSString *schema) {
            categoryId = [object valueForKey:@"category_id"];
            success = YES;
            timeout = NO;
            dispatch_group_leave(group);
        } onFailure:^(NSError *error, NSDictionary *object, NSString *schema) {
            // Handle error
            [error shouldBeNil];
            timeout = NO;
            dispatch_group_leave(group);
        }];
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 45);
        dispatch_group_wait(group, time);
        
        [[theValue(success) should] beYes];
        [[theValue(timeout) should] beNo];
        
        if (success) {
            NSDictionary *categoryUpdate = [NSDictionary dictionaryWithObjectsAndKeys:@"Updated Name", @"name", categoryId, @"category_id", nil];
            
            NSDictionary *todoObject = [NSDictionary dictionaryWithObjectsAndKeys:@"new todo", @"title", categoryUpdate, @"category", nil];
            
            // Correlate the key "category" to the StackMob "category" schema
            SMRequestOptions *options = [SMRequestOptions options];
            [options associateKey:@"category" withSchema:@"category"];
            
            success = NO;
            timeout = YES;
            
            dispatch_group_enter(group);
            // Execute request
            [dataStore createObject:todoObject inSchema:@"todo" options:options successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSDictionary *object, NSString *schema) {
                [[[[object valueForKey:@"category"] objectForKey:@"name"] should] equal:@"Updated Name"];
                success = YES;
                timeout = NO;
                dispatch_group_leave(group);
            } onFailure:^(NSError *error, NSDictionary *object, NSString *schema) {
                // Handle error
                [error shouldBeNil];
                timeout = NO;
                dispatch_group_leave(group);
            }];
            
            dispatch_group_wait(group, time);
            
            [[theValue(success) should] beYes];
            [[theValue(timeout) should] beNo];
        }
    });
    it(@"Create new todo and update existing category, one to many", ^{
        // Create category object. We can specify a manual primary key if we wish, otherwise one will be automatically assigned when it's created.
        NSDictionary *categoryObject = [NSDictionary dictionaryWithObjectsAndKeys:@"Home Projects", @"name", @"1234", @"genre", nil];
        
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_group_t group = dispatch_group_create();
        __block BOOL success = NO;
        __block BOOL timeout = YES;
        __block NSString *categoryId = nil;
        
        dispatch_group_enter(group);
        // Execute request
        [dataStore createObject:categoryObject inSchema:@"category" options:nil successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSDictionary *object, NSString *schema) {
            categoryId = [object valueForKey:@"category_id"];
            success = YES;
            timeout = NO;
            dispatch_group_leave(group);
        } onFailure:^(NSError *error, NSDictionary *object, NSString *schema) {
            // Handle error
            [error shouldBeNil];
            timeout = NO;
            dispatch_group_leave(group);
        }];
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 45);
        dispatch_group_wait(group, time);
        
        [[theValue(success) should] beYes];
        [[theValue(timeout) should] beNo];
        
        if (success) {
            NSDictionary *categoryUpdate = [NSDictionary dictionaryWithObjectsAndKeys:@"Updated Name", @"name", categoryId, @"category_id", nil];
            
            NSDictionary *todoObject = [NSDictionary dictionaryWithObjectsAndKeys:@"new todo", @"title", [NSArray arrayWithObject:categoryUpdate], @"categories", nil];
            
            // Correlate the key "category" to the StackMob "category" schema
            SMRequestOptions *options = [SMRequestOptions options];
            [options associateKey:@"categories" withSchema:@"category"];
            
            success = NO;
            timeout = YES;
            
            dispatch_group_enter(group);
            // Execute request
            [dataStore createObject:todoObject inSchema:@"todo" options:options successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSDictionary *object, NSString *schema) {
                [[[[[object valueForKey:@"categories"] lastObject] objectForKey:@"name"] should] equal:@"Updated Name"];
                success = YES;
                timeout = NO;
                dispatch_group_leave(group);
            } onFailure:^(NSError *error, NSDictionary *object, NSString *schema) {
                // Handle error
                [error shouldBeNil];
                timeout = NO;
                dispatch_group_leave(group);
            }];
            
            dispatch_group_wait(group, time);
            
            [[theValue(success) should] beYes];
            [[theValue(timeout) should] beNo];
        }
    });
    it(@"Create new todo and update existing category with relationship to other entity", ^{
        // Create category object. We can specify a manual primary key if we wish, otherwise one will be automatically assigned when it's created.
        NSDictionary *categoryObject = [NSDictionary dictionaryWithObjectsAndKeys:@"Home Projects", @"name", nil];
        
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_group_t group = dispatch_group_create();
        __block BOOL success = NO;
        __block BOOL timeout = YES;
        __block NSString *categoryId = nil;
        
        dispatch_group_enter(group);
        // Execute request
        [dataStore createObject:categoryObject inSchema:@"category" options:nil successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSDictionary *object, NSString *schema) {
            categoryId = [object valueForKey:@"category_id"];
            success = YES;
            timeout = NO;
            dispatch_group_leave(group);
        } onFailure:^(NSError *error, NSDictionary *object, NSString *schema) {
            // Handle error
            [error shouldBeNil];
            timeout = NO;
            dispatch_group_leave(group);
        }];
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 45);
        dispatch_group_wait(group, time);
        
        [[theValue(success) should] beYes];
        [[theValue(timeout) should] beNo];
        
        if (success) {
            NSDictionary *favoriteObject = [NSDictionary dictionaryWithObjectsAndKeys:@"My Favorites", @"genre", nil];
            NSDictionary *categoryUpdate = [NSDictionary dictionaryWithObjectsAndKeys:@"Updated Name", @"name", categoryId, @"category_id", favoriteObject, @"favorite", nil];
            
            NSDictionary *todoObject = [NSDictionary dictionaryWithObjectsAndKeys:@"new todo", @"title", [NSArray arrayWithObject:categoryUpdate], @"categories", nil];
            
            // Correlate the key "category" to the StackMob "category" schema
            SMRequestOptions *options = [SMRequestOptions options];
            [options associateKey:@"categories" withSchema:@"category"];
            [options associateKey:@"categories.favorite" withSchema:@"favorite"];
            
            success = NO;
            timeout = YES;
            
            dispatch_group_enter(group);
            // Execute request
            [dataStore createObject:todoObject inSchema:@"todo" options:options successCallbackQueue:queue failureCallbackQueue:queue onSuccess:^(NSDictionary *object, NSString *schema) {
                NSDictionary *categoryResult = [[object valueForKey:@"categories"] lastObject];
                [[[categoryResult objectForKey:@"name"] should] equal:@"Updated Name"];
                [[[[categoryResult objectForKey:@"favorite"] objectForKey:@"genre"] should] equal:@"My Favorites"];
                success = YES;
                timeout = NO;
                dispatch_group_leave(group);
            } onFailure:^(NSError *error, NSDictionary *object, NSString *schema) {
                // Handle error
                [error shouldBeNil];
                timeout = NO;
                dispatch_group_leave(group);
            }];
            
            dispatch_group_wait(group, time);
            
            [[theValue(success) should] beYes];
            [[theValue(timeout) should] beNo];
        }
    });
  
});

SPEC_END