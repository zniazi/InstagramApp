//
//  ZNInstagramTableViewController.m
//  AudibleChallenge
//
//  Created by Zak Niazi on 10/30/14.
//
//

#import "ZNInstagramTableViewController.h"
#import "ZNInstagramTableViewCell.h"
#import "ZNInstagramSmallTableViewCell.h"
#import "Photo.h"
#import "ZNDataStore.h"
#import <AFNetworking.h>
#import "ZNImageDetailViewController.h"

@interface ZNInstagramTableViewController()
@property (strong, nonatomic) NSString *minTagID;
@property (atomic) BOOL *loadingData;
@end

@implementation ZNInstagramTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataStore = [ZNDataStore sharedDataStore];
    self.dataStore.fetchedResultsController.delegate = self;
    self.loadingData = NO;
    
    [self.dataStore fetchData];
    if ([self.dataStore.fetchedResultsController.fetchedObjects count] > 0) {
        
    }
    [self getInstagramDataFromMinTagID:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (NSArray *)getInstagramDataFromMinTagID:(NSString *)minTagID {
    NSString *url;
    if (minTagID == nil) {
        url = @"https://api.instagram.com/v1/tags/selfie/media/recent?client_id=2c57ce23a0364d73956f636ad2816130";
    } else {
        url = [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/selfie/media/recent?client_id=2c57ce23a0364d73956f636ad2816130&min_tag_id=%@", minTagID];
    }
    NSLog(@"Starting Fetch");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    self.loadingData = YES;
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Got URLs");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Fetching image data");
            self.minTagID = responseObject[@"pagination"][@"min_tag_id"];
            for (NSInteger i=0; i < [responseObject[@"data"] count]; i++) {
                NSString *urlString = responseObject[@"data"][i][@"images"][@"low_resolution"][@"url"];
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
                Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.dataStore.managedObjectContext];
                photo.createdAt = [NSDate date];
                photo.imageData = imageData;
                photo.minTagID = responseObject[@"pagination"][@"min_tag_id"];
                [self.dataStore saveContext];
            }
            self.loadingData = NO;
            [self.tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.loadingData = NO;
    }];
    NSLog(@"Beyond Fetch");
    
    return nil;
}

# pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 3 == 0) {
        return 259.0;
    } else {
        return 155.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataStore.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataStore.fetchedResultsController.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 3 == 0) {
        ZNInstagramTableViewCell *instagramCell = (ZNInstagramTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"instagramCell"];
        Photo *photo = [self.dataStore.fetchedResultsController objectAtIndexPath:indexPath];
        UIImage *image = [[UIImage alloc] initWithData:photo.imageData];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:imageView action:@selector(performSegueWithIdentifier:sender:)];
        singleTap.numberOfTapsRequired = 1;
        [imageView setUserInteractionEnabled:YES];
        [imageView addGestureRecognizer:singleTap];
        instagramCell.bigImage.image = imageView.image;
        return instagramCell;
    } else {
        ZNInstagramSmallTableViewCell *instagramCell = (ZNInstagramSmallTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"instagramSmallCell"];
        Photo *photo = [self.dataStore.fetchedResultsController objectAtIndexPath:indexPath];
        UIImage *image = [[UIImage alloc] initWithData:photo.imageData];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:imageView action:@selector(performSegueWithIdentifier:sender:)];
        singleTap.numberOfTapsRequired = 1;
        [imageView setUserInteractionEnabled:YES];
        [imageView addGestureRecognizer:singleTap];
        instagramCell.leftImage.image = imageView.image;
        
        return instagramCell;
    }
    
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    if ([indexPaths count] > 0) {
        NSIndexPath *ip = indexPaths[[indexPaths count] - 1];
        if ((ip.row > [self.dataStore.fetchedResultsController.fetchedObjects count] / 2) && self.loadingData == NO) {
            [self getInstagramDataFromMinTagID:self.minTagID];
            NSLog(@"Fetching");
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


 #pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ZNImageDetailViewController *imageDetailVC = segue.destinationViewController;
    if ([sender isKindOfClass:[ZNInstagramTableViewCell class]]) {
        ZNInstagramTableViewCell *tableViewCell = sender;
        imageDetailVC.image = tableViewCell.bigImage.image;
    } else if ([sender isKindOfClass:[ZNInstagramSmallTableViewCell class]]) {
        ZNInstagramSmallTableViewCell *smallTableViewCell = sender;
        imageDetailVC.image = smallTableViewCell.leftImage.image;
    }
}

@end
