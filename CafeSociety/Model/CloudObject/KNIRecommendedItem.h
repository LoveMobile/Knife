//
//  KNIRecommendedItem.h
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

@import UIKit;
@import CloudKit;
#import "KNILocation.h"
#import "KNIHumanBeing.h"

@interface KNIRecommendedItem : NSObject

@property (nonatomic, strong) KNIHumanBeing *creator;
@property (nonatomic, strong) KNILocation *location;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *bodyCopy;
@property (nonatomic, readonly) NSArray *tags;
@property (nonatomic, readonly) NSArray *categories;
@property (nonatomic, readonly) NSArray *themes;
@property (nonatomic, readonly) NSDate *createdDate;
@property (nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) NSURL *thumbnailURL;
@property (nonatomic, readonly) NSString *tipsSectionTitle;
@property (nonatomic, readonly) NSArray *tips;
@property (nonatomic, readonly) NSString *quotation;
@property (nonatomic, strong) NSArray *upvotedUserIDs;
@property (nonatomic, readonly) NSInteger numberOfUpvotes;
@property (nonatomic, readonly) UIColor *titleTextColor;

- (instancetype)initWithRecord:(CKRecord *)record database:(CKDatabase *)database;

- (void)fetchDetailWithCompletion:(void(^)(NSArray *errors))block;

- (void)downloadImageWithCompletion:(void(^)(UIImage *image))block;

@end
