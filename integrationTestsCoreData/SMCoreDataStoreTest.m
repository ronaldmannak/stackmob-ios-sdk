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
    __block NSManagedObject *aPerson = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
        [[testProperties.client.session.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
    });
    afterEach(^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [testProperties.moc deleteObject:obj];
        }];
        if ([testProperties.moc hasChanges]) {
            error = nil;
            BOOL success = [testProperties.moc saveAndWait:&error];
            [[theValue(success) should] beYes];
        }
    });
    it(@"the context should have inserted objects", ^{
        aPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:testProperties.moc];
        [aPerson setValue:@"the" forKey:@"first_name"];
        [aPerson setValue:@"dude" forKey:@"last_name"];
        [aPerson setValue:[aPerson assignObjectId] forKey:[aPerson primaryKeyField]];
        [[theValue([[testProperties.moc insertedObjects] count]) should] beGreaterThan:theValue(0)];
        [[testProperties.client.session.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        [SMCoreDataIntegrationTestHelpers executeSynchronousSave:testProperties.moc withBlock:^(NSError *error) {
            [error shouldBeNil];
            [[theValue([[testProperties.moc insertedObjects] count]) should] equal:theValue(0)];
        }];
    });
});

describe(@"with a managedObjectContext from SMCoreDataStore", ^{
    __block SMTestProperties *testProperties = nil;
    __block NSManagedObject *aPerson = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
        [[testProperties.client.session.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        
        aPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:testProperties.moc];
        [aPerson setValue:@"the" forKey:@"first_name"];
        [aPerson setValue:@"dude" forKey:@"last_name"];
        [aPerson setValue:[aPerson assignObjectId] forKey:[aPerson primaryKeyField]];
        [[theValue([[testProperties.moc insertedObjects] count]) should] beGreaterThan:theValue(0)];
        [[testProperties.client.session.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        [SMCoreDataIntegrationTestHelpers executeSynchronousSave:testProperties.moc withBlock:^(NSError *error) {
            [error shouldBeNil];
            [[theValue([[testProperties.moc insertedObjects] count]) should] equal:theValue(0)];
        }];
        
    });
    afterEach(^{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [testProperties.moc deleteObject:obj];
        }];
        if ([testProperties.moc hasChanges]) {
            error = nil;
            BOOL success = [testProperties.moc saveAndWait:&error];
            [[theValue(success) should] beYes];
        }
    });
    it(@"reads the object", ^{
        [[testProperties.client.session.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"last_name = 'dude'"];
        [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:testProperties.moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate context:testProperties.moc] andBlock:^(NSArray *results, NSError *error) {
            [error shouldBeNil];
            [[theValue([results count]) should] equal:theValue(1)];
            NSManagedObject *theDude = [results objectAtIndex:0];
            [[[theDude valueForKey:@"first_name"] should] equal:@"the"];
        }];
    });
    it(@"updates the object", ^{
        [[testProperties.client.session.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        [aPerson setValue:@"matt" forKey:@"first_name"];
        [aPerson setValue:@"StackMob" forKey:@"company"];
        [[theValue([[testProperties.moc updatedObjects] count]) should] beGreaterThan:theValue(0)];
        [SMCoreDataIntegrationTestHelpers executeSynchronousSave:testProperties.moc withBlock:^(NSError *error) {
            [error shouldBeNil];
        }];
    });
});

describe(@"read, update", ^{
    __block SMTestProperties *testProperties = nil;
    __block NSManagedObject *aPerson = nil;
    beforeEach(^{
        testProperties = [[SMTestProperties alloc] init];
        [[testProperties.client.session.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        aPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:testProperties.moc];
        [aPerson setValue:@"the" forKey:@"first_name"];
        [aPerson setValue:@"dude" forKey:@"last_name"];
        [aPerson setValue:[aPerson assignObjectId] forKey:[aPerson primaryKeyField]];
        [SMCoreDataIntegrationTestHelpers executeSynchronousSave:testProperties.moc withBlock:^(NSError *error) {
            [error shouldBeNil];
        }];
    });
    afterEach(^{
        [[testProperties.client.session.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        NSError *error = nil;
        NSArray *results = [testProperties.moc executeFetchRequestAndWait:fetch error:&error];
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [testProperties.moc deleteObject:obj];
        }];
        if ([testProperties.moc hasChanges]) {
            error = nil;
            BOOL success = [testProperties.moc saveAndWait:&error];
            [[theValue(success) should] beYes];
        }
    });
    describe(@"after sending a request for a field that doesn't exist", ^{
        __block NSFetchRequest *theRequest = nil;
        beforeEach(^{
            [[testProperties.client.session.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"not_a_field = 'hello'"];
            theRequest = [SMCoreDataIntegrationTestHelpers makeFavoriteFetchRequest:predicate context:testProperties.moc];
        });
        it(@"the fetch request should fail, and the error should contain the info", ^{
            [[testProperties.client.session.networkMonitor stubAndReturn:theValue(1)] currentNetworkStatus];
            __block NSArray *results = nil;
            NSError *error = nil;
            results = [testProperties.moc executeFetchRequestAndWait:theRequest error:&error];
            [error shouldNotBeNil];
            [results shouldBeNil];
        });
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
