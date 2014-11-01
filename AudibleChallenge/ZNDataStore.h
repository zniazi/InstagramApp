//
//  ZNDataStore.h
//  AudibleChallenge
//
//  Created by Zak Niazi on 10/31/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ZNDataStore : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

+ (instancetype)sharedDataStore;

- (void)saveContext;
- (void)fetchData;
@end
