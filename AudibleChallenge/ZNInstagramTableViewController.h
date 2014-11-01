//
//  ZNInstagramTableViewController.h
//  AudibleChallenge
//
//  Created by Zak Niazi on 10/30/14.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ZNDataStore.h"

@interface ZNInstagramTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) ZNDataStore *dataStore;
@end
