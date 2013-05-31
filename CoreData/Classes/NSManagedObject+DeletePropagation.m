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

#import "NSManagedObject+DeletePropagation.h"

@implementation NSManagedObject (DeletePropagation)

- (NSArray *)priorityDeletionRelationships
{
    return nil;
}

- (void)propagateDelete
{
    //__block BOOL success = YES;
    NSEntityDescription *entityDescription = [self entity];
    
    // Get the set of relationships
    NSDictionary *relationships = [entityDescription relationshipsByName];
    NSArray *unsortedKeys = [relationships allKeys];
    NSArray *priorityKeys = [self priorityDeletionRelationships];
    NSArray *keys = nil;
    if ([priorityKeys count] > 0)
    {
        keys = [unsortedKeys mutableCopy];
        [(NSMutableArray *)keys removeObjectsInArray:priorityKeys];
        [(NSMutableArray *)keys replaceObjectsInRange:NSMakeRange(0, 0) withObjectsFromArray:priorityKeys];
    }
    else
    {
        keys = unsortedKeys;
    }
    
    [keys enumerateObjectsUsingBlock:^(id relationshipName, NSUInteger idx, BOOL *stop) {
        
        NSRelationshipDescription *relationshipDescription = [relationships objectForKey:relationshipName];
        
        // If the relationship is not "cascade", then just nullify it.
        if ([relationshipDescription deleteRule] != NSCascadeDeleteRule) {
            if (![relationshipDescription isToMany]) {
                [self setValue:nil forKey:relationshipName];
            }
            else {
                NSMutableSet *relationshipSet = [self mutableSetValueForKey:relationshipName];
                [relationshipSet removeAllObjects];
                
                // Add this?
                //[self setValue:relationshipSet forKey:relationshipName];
            }
        } else if (![relationshipDescription isToMany]) {
            NSManagedObject *destination = [self valueForKey:relationshipName];
            [self setValue:nil forKey:relationshipName];
            [destination propagateDelete];
        } else {
            NSMutableSet *mutableRelationship = [self mutableSetValueForKey:relationshipName];
            NSSet *iterateSet = [mutableRelationship copy];
            [iterateSet enumerateObjectsUsingBlock:^(id setObject, BOOL *iterateStop) {
                [mutableRelationship removeObject:setObject];
                [setObject propagateDelete];
            }];
            
            // Add this?
            //[self setValue:mutableRelationship forKey:relationshipName];
        }
    }];
    
    // Delete this object
    [[self managedObjectContext] deleteObject:self];
    
    
    /*
    // Iterate over the set of relationships
    NSEnumerator *relationshipEnumerator = [keys keyEnumerator];
    NSString *relationshipName = nil;
    while ((relationshipName = [relationshipEnumerator nextObject]) != nil)
    {
        NSRelationshipDescription *relationshipDescription =
        [relationships objectForKey:relationshipName];
        
        // If the relationship is not "cascade", then just nullify it.
        if ([relationshipDescription deleteRule] != NSCascadeDeleteRule)
        {
            if (![relationshipDescription isToMany])
            {
                [self setValue:nil forKey:relationshipName];
            }
            else
            {
                NSMutableSet *relationshipSet =
                [self mutableSetValueForKey:relationshipName];
                [relationshipSet removeAllObjects];
            }
            continue;
        }
        
        // Propagate the delete to the object at the other end of the
        // relationship
        if (![relationshipDescription isToMany])
        {
            NSManagedObject *destination = [self valueForKey:relationshipName];
            [self setValue:nil forKey:relationshipName];
            [destination propagateDelete];
            continue;
        }
        
        // Propagate the delete to every object in the to-many relationship.
        // We copy the set because we plan to change it during iteration.
        NSMutableSet *mutableRelationship =
        [self mutableSetValueForKey:relationshipName];
        NSSet *iterateSet = [[mutableRelationship copy] autorelease];
        NSEnumerator *enumerator = [iterateSet objectEnumerator];
        NSManagedObject *setObject;
        while ((setObject = [enumerator nextObject]) != nil)
        {
            [mutableRelationship removeObject:setObject];
            [setObject propagateDelete];
        }
    }
    */
    
}


@end
