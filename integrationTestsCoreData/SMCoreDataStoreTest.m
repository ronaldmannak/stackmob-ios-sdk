/**
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
#import "SMCoreDataIntegrationTestHelpers.h"
#import "SMIntegrationTestHelpers.h"
#import "SMTestProperties.h"

SPEC_BEGIN(SMCoreDataStoreTest)

describe(@"create an instance of SMCoreDataStore from SMClient", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
    });
    it(@"obtaining a managedObjectContext hooked to SM is not nil", ^{
        testProperties.moc = [testProperties.cds contextForCurrentThread];
        [testProperties.moc shouldNotBeNil];
    });
});
describe(@"with a managedObjectContext from SMCoreDataStore", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
    });
    afterEach(^{
        [[testProperties.client.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"first_name == 'the'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [testProperties.moc deleteObject:[results objectAtIndex:0]];
            error = nil;
            [testProperties.moc saveAndWait:&error];
        }
    });
    it(@"a call to save should not fail", ^{
        [[testProperties.client.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        
        NSManagedObject *aPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:testProperties.moc];
        [aPerson setValue:@"the" forKey:@"first_name"];
        [aPerson setValue:@"dude" forKey:@"last_name"];
        [aPerson setValue:[aPerson assignObjectId] forKey:[aPerson primaryKeyField]];
        
        [[theValue([[testProperties.moc insertedObjects] count]) should] beGreaterThan:theValue(0)];
        
        NSError *error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        [[theValue([[testProperties.moc insertedObjects] count]) should] equal:theValue(0)];
    });
});

describe(@"with a managedObjectContext from SMCoreDataStore", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
        
        NSManagedObject *aPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:testProperties.moc];
        [aPerson setValue:@"the" forKey:@"first_name"];
        [aPerson setValue:@"dude" forKey:@"last_name"];
        [aPerson setValue:[aPerson assignObjectId] forKey:[aPerson primaryKeyField]];
        NSError *error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
    });
    afterEach(^{
        [[testProperties.client.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"first_name == 'the'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [testProperties.moc deleteObject:[results objectAtIndex:0]];
            error = nil;
            [testProperties.moc saveAndWait:&error];
        }
    });
    it(@"reads the object", ^{
        [[testProperties.client.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"last_name = 'dude'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [error shouldBeNil];
        [[theValue([results count]) should] equal:theValue(1)];
        NSManagedObject *theDude = [results objectAtIndex:0];
        [[[theDude valueForKey:@"first_name"] should] equal:@"the"];
    });
});

describe(@"with a managedObjectContext from SMCoreDataStore", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
    });
    afterEach(^{
        [[testProperties.client.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"first_name == 'matt'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [testProperties.moc deleteObject:[results objectAtIndex:0]];
            error = nil;
            [testProperties.moc saveAndWait:&error];
        }
    });
    it(@"updates the object", ^{
        NSManagedObject *aPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:testProperties.moc];
        [aPerson setValue:@"the" forKey:@"first_name"];
        [aPerson setValue:@"dude" forKey:@"last_name"];
        [aPerson setValue:[aPerson assignObjectId] forKey:[aPerson primaryKeyField]];
        NSError *error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        [[testProperties.client.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        [aPerson setValue:@"matt" forKey:@"first_name"];
        [aPerson setValue:@"StackMob" forKey:@"company"];
        [[theValue([[testProperties.moc updatedObjects] count]) should] beGreaterThan:theValue(0)];
        error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
    });
});

describe(@"after sending a request for a field that doesn't exist", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
    });
    it(@"the fetch request should fail, and the error should contain the info", ^{
        [[testProperties.client.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Favorite"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"not_a_field = 'hello'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [error shouldNotBeNil];
        [results shouldBeNil];
    });
});

describe(@"after sending a request for a field that doesn't exist", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
    });
    it(@"a call to save: should fail, and the error should contain the info", ^{
        [[testProperties.client.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Oauth2test" inManagedObjectContext:testProperties.moc];
        [newManagedObject setValue:@"fail" forKey:@"name"];
        [newManagedObject setValue:[newManagedObject assignObjectId] forKey:[newManagedObject primaryKeyField]];
        
        __block BOOL saveSuccess = NO;
        
        NSError *anError = nil;
        saveSuccess = [testProperties.moc saveAndWait:&anError];
        [anError shouldNotBeNil];
        [[theValue(saveSuccess) should] beNo];
    });
});


describe(@"Writing Default Values Online, Strings", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
    });
    afterEach(^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"todoId == '1234'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [testProperties.moc deleteObject:[results objectAtIndex:0]];
            error = nil;
            [testProperties.moc saveAndWait:&error];
        }
    });
    it(@"Works when online", ^{
        NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
        [todo setValue:@"1234" forKey:[todo primaryKeyField]];
        
        NSError *error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"todoId == '1234'"]];
        error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [[[[results objectAtIndex:0] valueForKey:@"title"] should] equal:@"What!"];
        }
        
    });
});
 
describe(@"Writing Default Values Online with Update, Integers", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
    });
    afterEach(^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"person_id == '1234'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [testProperties.moc deleteObject:[results objectAtIndex:0]];
            error = nil;
            [testProperties.moc saveAndWait:&error];
        }
    });
    it(@"Works when online", ^{
        
        // Insert 
        NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:testProperties.moc];
        [todo setValue:@"1234" forKey:[todo primaryKeyField]];
        [todo setValue:[NSNumber numberWithInt:13] forKey:@"armor_class"];
        
        NSError *error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"person_id == '1234'"]];
        error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [[[[results objectAtIndex:0] valueForKey:@"armor_class"] should] equal:theValue(13)];
        }
        
        // Update
        
        NSManagedObject *fetchedTodo = [results objectAtIndex:0];
        [fetchedTodo setValue:@"bobby" forKey:@"first_name"];
        
        error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        // Fetch should still return original armor class, default value should not overwrite
        
        NSFetchRequest *fetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch2 setPredicate:[NSPredicate predicateWithFormat:@"person_id == '1234'"]];
        error = nil;
        NSArray *results2 = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results2 should] haveCountOf:1];
        
        if ([results2 count] == 1) {
            [[[[results2 objectAtIndex:0] valueForKey:@"armor_class"] should] equal:theValue(13)];
        }
        
    });
});

describe(@"Writing Default Values Online with Update, Boolean", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
    });
    afterEach(^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"randomId == '1234'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [testProperties.moc deleteObject:[results objectAtIndex:0]];
            error = nil;
            [testProperties.moc saveAndWait:&error];
        }
    });
    it(@"Works when online", ^{
        
        // Insert
        NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Random" inManagedObjectContext:testProperties.moc];
        [todo setValue:@"1234" forKey:[todo primaryKeyField]];
        [todo setValue:[NSNumber numberWithBool:YES] forKey:@"done"];
        
        NSError *error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"randomId == '1234'"]];
        error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [[[[results objectAtIndex:0] valueForKey:@"done"] should] equal:theValue(YES)];
        }
        
        // Update
        
        NSManagedObject *fetchedTodo = [results objectAtIndex:0];
        [fetchedTodo setValue:@"bobby" forKey:@"name"];
        
        error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        // Fetch should still return original done value, default value should not overwrite
        
        NSFetchRequest *fetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        [fetch2 setPredicate:[NSPredicate predicateWithFormat:@"randomId == '1234'"]];
        error = nil;
        NSArray *results2 = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results2 should] haveCountOf:1];
        
        if ([results2 count] == 1) {
            [[[[results2 objectAtIndex:0] valueForKey:@"done"] should] equal:theValue(YES)];
        }
        
    });
});

describe(@"Writing Default Values Online, Integers", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
    });
    afterEach(^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"person_id == '1234'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [testProperties.moc deleteObject:[results objectAtIndex:0]];
            error = nil;
            [testProperties.moc saveAndWait:&error];
        }
    });
    it(@"Works when online", ^{
        NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:testProperties.moc];
        [todo setValue:@"1234" forKey:[todo primaryKeyField]];
        
        NSError *error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"person_id == '1234'"]];
        error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [[[[results objectAtIndex:0] valueForKey:@"armor_class"] should] equal:theValue(1)];
        }
        
    });
});

describe(@"Writing Default Values Online, Boolean", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
    });
    afterEach(^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"randomId == '1234'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [testProperties.moc deleteObject:[results objectAtIndex:0]];
            error = nil;
            [testProperties.moc saveAndWait:&error];
        }
    });
    it(@"Works when online", ^{
        NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Random" inManagedObjectContext:testProperties.moc];
        [todo setValue:@"1234" forKey:[todo primaryKeyField]];
        
        NSError *error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"randomId == '1234'"]];
        error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [[[[results objectAtIndex:0] valueForKey:@"done"] should] equal:theValue(NO)];
        }
        
    });
});

describe(@"Writing Default Values Offline, Strings", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        SM_CACHE_ENABLED = YES;
        testProperties = [[SMTestProperties alloc] init];
    });
    afterEach(^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"todoId == '1234'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [testProperties.moc deleteObject:[results objectAtIndex:0]];
            error = nil;
            [testProperties.moc saveAndWait:&error];
        }
        SM_CACHE_ENABLED = NO;
    });
    it(@"Works before and after sync", ^{
        
        NSArray *persistentStores = [testProperties.cds.persistentStoreCoordinator persistentStores];
        SMIncrementalStore *store = [persistentStores lastObject];
        [store stub:@selector(SM_checkNetworkAvailability) andReturn:theValue(NO)];
        
        NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:testProperties.moc];
        [todo setValue:@"1234" forKey:[todo primaryKeyField]];
        
        NSError *error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        [store stub:@selector(SM_checkNetworkAvailability) andReturn:theValue(YES)];
        
        [[theValue([testProperties.cds isDirtyObject:[todo objectID]]) should] beYes];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"todoId == '1234'"]];
        error = nil;
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [[[[results objectAtIndex:0] valueForKey:@"title"] should] equal:@"What!"];
        }
        
        // Sync
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_group_t group = dispatch_group_create();
        
        [testProperties.cds setSyncCallbackQueue:queue];
        [testProperties.cds setDefaultSMMergePolicy:SMMergePolicyClientWins];
        [testProperties.cds setSyncCompletionCallback:^(NSArray *objects) {
            [[objects should] haveCountOf:1];
            if ([objects count] == 1) {
                [[theValue([[objects objectAtIndex:0] actionTaken]) should] equal:theValue(SMSyncActionInsertedOnServer)];
            }
            dispatch_group_leave(group);
        }];
        
        dispatch_group_enter(group);
        
        [testProperties.cds syncWithServer];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:cacheFetch error:&error];
        [[results should] haveCountOf:1];
        [[[[results objectAtIndex:0] valueForKey:@"title"] should] equal:@"What!"];
        
        // Check server
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *serverFetch = [[NSFetchRequest alloc] initWithEntityName:@"Todo"];
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:serverFetch error:&error];
        [[results should] haveCountOf:1];
        [[[[results objectAtIndex:0] valueForKey:@"title"] should] equal:@"What!"];
        
        [[theValue([testProperties.cds isDirtyObject:[[results objectAtIndex:0] objectID]]) should] beNo];
    });
});

describe(@"Writing Default Values Offline, Integer", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        SM_CACHE_ENABLED = YES;
        testProperties = [[SMTestProperties alloc] init];
    });
    afterEach(^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"person_id == '1234'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [testProperties.moc deleteObject:[results objectAtIndex:0]];
            error = nil;
            [testProperties.moc saveAndWait:&error];
        }
        SM_CACHE_ENABLED = NO;
    });
    it(@"Works before and after sync", ^{
        
        NSArray *persistentStores = [testProperties.cds.persistentStoreCoordinator persistentStores];
        SMIncrementalStore *store = [persistentStores lastObject];
        [store stub:@selector(SM_checkNetworkAvailability) andReturn:theValue(NO)];
        
        NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:testProperties.moc];
        [todo setValue:@"1234" forKey:[todo primaryKeyField]];
        
        NSError *error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        [store stub:@selector(SM_checkNetworkAvailability) andReturn:theValue(YES)];
        
        [[theValue([testProperties.cds isDirtyObject:[todo objectID]]) should] beYes];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"person_id == '1234'"]];
        error = nil;
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [[[[results objectAtIndex:0] valueForKey:@"armor_class"] should] equal:theValue(1)];
        }
        
        // Sync
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_group_t group = dispatch_group_create();
        
        [testProperties.cds setSyncCallbackQueue:queue];
        [testProperties.cds setDefaultSMMergePolicy:SMMergePolicyClientWins];
        [testProperties.cds setSyncCompletionCallback:^(NSArray *objects) {
            [[objects should] haveCountOf:1];
            if ([objects count] == 1) {
                [[theValue([[objects objectAtIndex:0] actionTaken]) should] equal:theValue(SMSyncActionInsertedOnServer)];
            }
            dispatch_group_leave(group);
        }];
        
        dispatch_group_enter(group);
        
        [testProperties.cds syncWithServer];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:cacheFetch error:&error];
        [[results should] haveCountOf:1];
        [[[[results objectAtIndex:0] valueForKey:@"armor_class"] should] equal:theValue(1)];
        
        // Check server
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *serverFetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:serverFetch error:&error];
        [[results should] haveCountOf:1];
        [[[[results objectAtIndex:0] valueForKey:@"armor_class"] should] equal:theValue(1)];
        
        [[theValue([testProperties.cds isDirtyObject:[[results objectAtIndex:0] objectID]]) should] beNo];
    });
});

describe(@"Writing Default Values Offline with Update, Integer", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        SM_CACHE_ENABLED = YES;
        testProperties = [[SMTestProperties alloc] init];
    });
    afterEach(^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"person_id == '1234'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [testProperties.moc deleteObject:[results objectAtIndex:0]];
            error = nil;
            [testProperties.moc saveAndWait:&error];
        }
        SM_CACHE_ENABLED = NO;
    });
    it(@"Works before and after sync", ^{
        
        NSArray *persistentStores = [testProperties.cds.persistentStoreCoordinator persistentStores];
        SMIncrementalStore *store = [persistentStores lastObject];
        [store stub:@selector(SM_checkNetworkAvailability) andReturn:theValue(NO)];
        
        NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:testProperties.moc];
        [todo setValue:@"1234" forKey:[todo primaryKeyField]];
        [todo setValue:[NSNumber numberWithInt:13] forKey:@"armor_class"];
        
        NSError *error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        [[theValue([testProperties.cds isDirtyObject:[todo objectID]]) should] beYes];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"person_id == '1234'"]];
        error = nil;
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [[[[results objectAtIndex:0] valueForKey:@"armor_class"] should] equal:theValue(13)];
        }
        
        // Update
        NSManagedObject *person = [results objectAtIndex:0];
        [person setValue:@"bobby" forKey:@"first_name"];
        
        error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        [[theValue([testProperties.cds isDirtyObject:[todo objectID]]) should] beYes];
        
        NSFetchRequest *fetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        [fetch2 setPredicate:[NSPredicate predicateWithFormat:@"person_id == '1234'"]];
        error = nil;
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSArray *results2 = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results2 should] haveCountOf:1];
        
        if ([results2 count] == 1) {
            [[[[results2 objectAtIndex:0] valueForKey:@"armor_class"] should] equal:theValue(13)];
        }
        
        [store stub:@selector(SM_checkNetworkAvailability) andReturn:theValue(YES)];
        
        
        // Sync
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_group_t group = dispatch_group_create();
        
        [testProperties.cds setSyncCallbackQueue:queue];
        [testProperties.cds setDefaultSMMergePolicy:SMMergePolicyClientWins];
        [testProperties.cds setSyncCompletionCallback:^(NSArray *objects) {
            [[objects should] haveCountOf:1];
            if ([objects count] == 1) {
                [[theValue([[objects objectAtIndex:0] actionTaken]) should] equal:theValue(SMSyncActionInsertedOnServer)];
            }
            dispatch_group_leave(group);
        }];
        
        dispatch_group_enter(group);
        
        [testProperties.cds syncWithServer];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:cacheFetch error:&error];
        [[results should] haveCountOf:1];
        [[[[results objectAtIndex:0] valueForKey:@"armor_class"] should] equal:theValue(13)];
        
        // Check server
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *serverFetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:serverFetch error:&error];
        [[results should] haveCountOf:1];
        [[[[results objectAtIndex:0] valueForKey:@"armor_class"] should] equal:theValue(13)];
        
        [[theValue([testProperties.cds isDirtyObject:[[results objectAtIndex:0] objectID]]) should] beNo];
    });
});

describe(@"Writing Default Values Offline, Boolean", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        SM_CACHE_ENABLED = YES;
        testProperties = [[SMTestProperties alloc] init];
    });
    afterEach(^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"randomId == '1234'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [testProperties.moc deleteObject:[results objectAtIndex:0]];
            error = nil;
            [testProperties.moc saveAndWait:&error];
        }
        SM_CACHE_ENABLED = NO;
    });
    it(@"Works before and after sync", ^{
        
        NSArray *persistentStores = [testProperties.cds.persistentStoreCoordinator persistentStores];
        SMIncrementalStore *store = [persistentStores lastObject];
        [store stub:@selector(SM_checkNetworkAvailability) andReturn:theValue(NO)];
        
        NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Random" inManagedObjectContext:testProperties.moc];
        [todo setValue:@"1234" forKey:[todo primaryKeyField]];
        
        NSError *error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        [store stub:@selector(SM_checkNetworkAvailability) andReturn:theValue(YES)];
        
        [[theValue([testProperties.cds isDirtyObject:[todo objectID]]) should] beYes];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"randomId == '1234'"]];
        error = nil;
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [[[[results objectAtIndex:0] valueForKey:@"done"] should] equal:theValue(NO)];
        }
        
        // Sync
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_group_t group = dispatch_group_create();
        
        [testProperties.cds setSyncCallbackQueue:queue];
        [testProperties.cds setDefaultSMMergePolicy:SMMergePolicyClientWins];
        [testProperties.cds setSyncCompletionCallback:^(NSArray *objects) {
            [[objects should] haveCountOf:1];
            if ([objects count] == 1) {
                [[theValue([[objects objectAtIndex:0] actionTaken]) should] equal:theValue(SMSyncActionInsertedOnServer)];
            }
            dispatch_group_leave(group);
        }];
        
        dispatch_group_enter(group);
        
        [testProperties.cds syncWithServer];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:cacheFetch error:&error];
        [[results should] haveCountOf:1];
        [[[[results objectAtIndex:0] valueForKey:@"done"] should] equal:theValue(NO)];
        
        // Check server
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *serverFetch = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:serverFetch error:&error];
        [[results should] haveCountOf:1];
        [[[[results objectAtIndex:0] valueForKey:@"done"] should] equal:theValue(NO)];
        
        [[theValue([testProperties.cds isDirtyObject:[[results objectAtIndex:0] objectID]]) should] beNo];
    });
});

describe(@"Writing Default Values Offline with Udpate, Boolean", ^{
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        SM_CACHE_ENABLED = YES;
        testProperties = [[SMTestProperties alloc] init];
    });
    afterEach(^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"randomId == '1234'"]];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [testProperties.moc deleteObject:[results objectAtIndex:0]];
            error = nil;
            [testProperties.moc saveAndWait:&error];
        }
        SM_CACHE_ENABLED = NO;
    });
    it(@"Works before and after sync", ^{
        
        NSArray *persistentStores = [testProperties.cds.persistentStoreCoordinator persistentStores];
        SMIncrementalStore *store = [persistentStores lastObject];
        [store stub:@selector(SM_checkNetworkAvailability) andReturn:theValue(NO)];
        
        NSManagedObject *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Random" inManagedObjectContext:testProperties.moc];
        [todo setValue:@"1234" forKey:[todo primaryKeyField]];
        [todo setValue:[NSNumber numberWithBool:YES] forKey:@"done"];
        
        NSError *error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        [[theValue([testProperties.cds isDirtyObject:[todo objectID]]) should] beYes];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"randomId == '1234'"]];
        error = nil;
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results should] haveCountOf:1];
        
        if ([results count] == 1) {
            [[[[results objectAtIndex:0] valueForKey:@"done"] should] equal:theValue(YES)];
        }
        
        // Update
        
        NSManagedObject *random = [results objectAtIndex:0];
        [random setValue:@"bobby" forKey:@"name"];
        
        error = nil;
        [testProperties.moc saveAndWait:&error];
        [error shouldBeNil];
        
        [[theValue([testProperties.cds isDirtyObject:[todo objectID]]) should] beYes];
        
        NSFetchRequest *fetch2 = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        [fetch2 setPredicate:[NSPredicate predicateWithFormat:@"randomId == '1234'"]];
        error = nil;
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSArray *results2 = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [[results2 should] haveCountOf:1];
        
        if ([results count] == 1) {
            [[[[results2 objectAtIndex:0] valueForKey:@"done"] should] equal:theValue(YES)];
        }
        
        [store stub:@selector(SM_checkNetworkAvailability) andReturn:theValue(YES)];
        
        // Sync
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_group_t group = dispatch_group_create();
        
        [testProperties.cds setSyncCallbackQueue:queue];
        [testProperties.cds setDefaultSMMergePolicy:SMMergePolicyClientWins];
        [testProperties.cds setSyncCompletionCallback:^(NSArray *objects) {
            [[objects should] haveCountOf:1];
            if ([objects count] == 1) {
                [[theValue([[objects objectAtIndex:0] actionTaken]) should] equal:theValue(SMSyncActionInsertedOnServer)];
            }
            dispatch_group_leave(group);
        }];
        
        dispatch_group_enter(group);
        
        [testProperties.cds syncWithServer];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        // Check cache
        [testProperties.cds setCachePolicy:SMCachePolicyTryCacheOnly];
        NSFetchRequest *cacheFetch = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:cacheFetch error:&error];
        [[results should] haveCountOf:1];
        [[[[results objectAtIndex:0] valueForKey:@"done"] should] equal:theValue(YES)];
        
        // Check server
        [testProperties.cds setCachePolicy:SMCachePolicyTryNetworkOnly];
        NSFetchRequest *serverFetch = [[NSFetchRequest alloc] initWithEntityName:@"Random"];
        error = nil;
        results = [testProperties.moc executeFetchRequestAndWait:serverFetch error:&error];
        [[results should] haveCountOf:1];
        [[[[results objectAtIndex:0] valueForKey:@"done"] should] equal:theValue(YES)];
        
        [[theValue([testProperties.cds isDirtyObject:[[results objectAtIndex:0] objectID]]) should] beNo];
    });
});

describe(@"inserting to a schema with permission Allow any logged in user when we are not logged in", ^{
    __block NSManagedObject *newManagedObject = nil;
    __block SMTestProperties *testProperties = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
    });
    it(@"a call to save: should fail, and the error should contain the info", ^{
        [[testProperties.client.session.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Oauth2test" inManagedObjectContext:testProperties.moc];
        [newManagedObject setValue:@"fail" forKey:@"name"];
        [newManagedObject setValue:[newManagedObject assignObjectId] forKey:[newManagedObject primaryKeyField]];
        
        __block BOOL saveSuccess = NO;
        NSError *anError = nil;
        saveSuccess = [testProperties.moc saveAndWait:&anError];
        [anError shouldNotBeNil];
        [[theValue(saveSuccess) should] beNo];
    });
});

SPEC_END
