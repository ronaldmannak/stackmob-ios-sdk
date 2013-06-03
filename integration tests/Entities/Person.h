//
//  Person.h
//  stackmob-ios-sdk
//
//  Created by Matt Vaznaian on 5/29/13.
//  Copyright (c) 2013 StackMob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Superpower;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSNumber * armor_class;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSString * person_id;
@property (nonatomic, retain) NSSet *favorites;
@property (nonatomic, retain) NSSet *interests;
@property (nonatomic, retain) Superpower *superpower;
@property (nonatomic, retain) NSSet *todos;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addFavoritesObject:(NSManagedObject *)value;
- (void)removeFavoritesObject:(NSManagedObject *)value;
- (void)addFavorites:(NSSet *)values;
- (void)removeFavorites:(NSSet *)values;
- (void)addInterestsObject:(NSManagedObject *)value;
- (void)removeInterestsObject:(NSManagedObject *)value;
- (void)addInterests:(NSSet *)values;
- (void)removeInterests:(NSSet *)values;
- (void)addTodosObject:(NSManagedObject *)value;
- (void)removeTodosObject:(NSManagedObject *)value;
- (void)addTodos:(NSSet *)values;
- (void)removeTodos:(NSSet *)values;
@end
