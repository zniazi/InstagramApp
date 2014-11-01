//
//  ZNDataStore.m
//  AudibleChallenge
//
//  Created by Zak Niazi on 10/31/14.
//
//

#import "ZNDataStore.h"

@implementation ZNDataStore
@synthesize managedObjectContext = _managedObjectContext;

- (instancetype)init {
    self = [super init];
    if (self) {
        NSFetchRequest *photoRequest = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        NSSortDescriptor *createdAtSorter = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
        photoRequest.sortDescriptors = @[createdAtSorter];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:photoRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
    
    return self;
}

+ (instancetype)sharedDataStore {
    static ZNDataStore *_sharedDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataStore = [[ZNDataStore alloc] init];
    });
    
    return _sharedDataStore;
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data Stack

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AudibleChallenge.sqlite"];
    
    NSError *error = nil;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AudibleChallenge" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

#pragma mark - Application's Documents Directory

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)fetchData {
    [self.fetchedResultsController performFetch:nil];    
}
@end











