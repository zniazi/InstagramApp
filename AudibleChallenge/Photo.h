//
//  Photo.h
//  AudibleChallenge
//
//  Created by Zak Niazi on 10/31/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * minTagID;
@property (nonatomic, retain) NSString * maxTagID;

@end
