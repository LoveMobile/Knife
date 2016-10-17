//
//  KNIIssue.h
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

@import CloudKit;
@import UIKit;

#import "KNIRecommendedItem.h"

@interface KNIIssue : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSNumber *volume;
@property (nonatomic, readonly) NSNumber *number;
@property (nonatomic, readonly) NSDate *createDate;
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) NSString *quotation;
@property (nonatomic, readonly) NSString *detail;


- (instancetype)initWithRecord:(CKRecord *)record database:(CKDatabase *)database;

@property (nonatomic, assign) BOOL isFetchingItems;
- (void)fetchItemsWithCompletion:(void(^)(NSError *error))block;
- (void)downloadImageWithCompletion:(void(^)(UIImage *image))block;
- (void)sortItems;
@end
