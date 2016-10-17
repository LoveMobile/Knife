//
//  KNICloudKitController.h
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KNIHumanBeing.h"
#import "KNILocation.h"
#import "KNIHumanBeing.h"
#import "KNIRecommendedItem.h"
#import "KNIUserInfo.h"
#import "KNIIssue.h"

static NSString *const KNICloudKitControllerDidUpdateRecommendedItemsListNotification = @"KNICloudKitControllerDidUpdateRecommendedItemsList";
static NSString *const KNICloudKitControllerDidErrorOutNotification = @"KNICloudKitControllerDidErrorOut";
static NSString *const KNIAppDidLaunchKey = @"TheKnifeDidLaunch";

@class KNICloudKitController;

@protocol KNICloudKitControllerDelegate <NSObject>

- (void)cloudKitControllerDidUpdateModel:(KNICloudKitController *)controller;
- (void)cloudKitController:(KNICloudKitController *)controller updateFailedWithError:(NSError *)error;

@end

@interface KNICloudKitController : NSObject

@property (nonatomic, readonly) CKRecord *userRecord;
@property (nonatomic, readonly) NSString *userIdentifier;
@property (nonatomic, weak) id<KNICloudKitControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *recommendedItems;

+ (instancetype)sharedInstance;

- (void)fetchAllIssuesWithCompletion:(void(^)(NSArray *issues, NSError *error))block;
- (void)fetchAllRecommendedItemsWithCompletion:(void(^)(NSArray *items, NSError *error))block;
- (void)updateAllRecommendedItems;
- (void)updateGlobalRecord:(CKRecord *)record completion:(void(^)(CKRecord *record, NSError *error))block;
- (void)updateUserRecordWithName:(NSString *)name email:(NSString *)email;

@end
