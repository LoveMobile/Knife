//
//  KNICloudKitController.m
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNICloudKitController.h"
#import "KNIAppDelegate.h"
@import CloudKit;
@import CoreLocation;

@interface KNICloudKitController ()

@property (nonatomic, strong) CKContainer *container;
@property (nonatomic, strong) CKDatabase *publicDatabase;
@property (nonatomic, strong) CKDatabase *userDatabase;
@property (nonatomic, strong) CKRecord *userRecord;
@property (nonatomic, weak) id terminateListener;

@end

@implementation KNICloudKitController

+ (instancetype)sharedInstance
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _container = [CKContainer containerWithIdentifier:@"iCloud.com.everydream.TheKnife"];
        _publicDatabase = _container.publicCloudDatabase;
        _userDatabase = _container.privateCloudDatabase;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fetchUserRecordWithCompletion:nil];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateAllRecommendedItems];
            [self listenForTerminate];
        });
    }
    return self;
}

- (void)listenForTerminate
{
    self.terminateListener = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KNIAppDidLaunchKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (void)fetchUserRecordWithCompletion:(void(^)(CKRecord *userRecord))block
{
    __weak __typeof__(self) weakSelf = self;
    [self.container fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
        if (error) NSLog(@"Error fetching user record ID! : %@", error);
        if (recordID)
        {
            [weakSelf.publicDatabase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
                if (record)
                {
                    weakSelf.userRecord = record;
                    [[Mixpanel sharedInstance] identify:record.recordID.recordName];
                    NSData *pushToken = [(KNIAppDelegate *)[[UIApplication sharedApplication] delegate] pushToken];
                    [[[Mixpanel sharedInstance] people] addPushDeviceToken:pushToken];
                }
            }];
        }
    }];
}

- (void)updateUserRecordWithName:(NSString *)name email:(NSString *)email
{
    if (!name.length || !email.length) return;
    if (!self.userRecord) {
        __weak __typeof__(self) weakSelf = self;
        [self fetchUserRecordWithCompletion:^(CKRecord *userRecord) {
            [weakSelf setUserInfoEverywhereWithName:name email:email];
        }];
        return;
    }
    [self setUserInfoEverywhereWithName:name email:email];
}

- (void)setUserInfoEverywhereWithName:(NSString *)name email:(NSString *)email
{
    [self.userRecord setObject:name forKey:@"name"];
    [self.userRecord setObject:email forKey:@"email"];
    __weak __typeof__(self) weakSelf = self;
    [self.publicDatabase saveRecord:self.userRecord completionHandler:^(CKRecord *record, NSError *error) {
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNICloudKitControllerDidErrorOutNotification object:error];
        } else if (record) {
            weakSelf.userRecord = record;
        }
    }];
    
    [[[Mixpanel sharedInstance] people] set:@{@"name" : name, @"email" : email, @"$email" : email}];
}

- (NSString *)userIdentifier
{
    if (self.userRecord)
    {
        return self.userRecord.recordID.recordName;
    }
    return @"NoUserRecordAvailable";
}

- (void)fetchAllIssuesWithCompletion:(void (^)(NSArray *, NSError *))block
{
    NSParameterAssert(block);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"visible > 0"];
    
    // Setup issue subscription.
//    CKSubscription *sub = [[CKSubscription alloc] initWithRecordType:NSStringFromClass([KNIIssue class]) predicate:predicate subscriptionID:@"IssueSubscription" options:CKSubscriptionOptionsFiresOnRecordCreation];
//    CKNotificationInfo *notificationInfo = [[CKNotificationInfo alloc] init];
//    notificationInfo.alertBody = @"There is a new issue of The Knife.";
//    notificationInfo.shouldBadge = YES;
//    notificationInfo.shouldSendContentAvailable = YES;
//    sub.notificationInfo = notificationInfo;
//    
//    [self.publicDatabase saveSubscription:sub completionHandler:^(CKSubscription *subscription, NSError *error) {
//        if (error) {
////            [[NSNotificationCenter defaultCenter] postNotificationName:KNICloudKitControllerDidErrorOutNotification object:error];
//            NSLog(@"Error saving subscription: %@", error);
//        }
//    }];
//    [self.publicDatabase fetchAllSubscriptionsWithCompletionHandler:^(NSArray *subscriptions, NSError *error) {
//        for (CKSubscription *subscription in subscriptions) {
//            [self.publicDatabase deleteSubscriptionWithID:subscription.subscriptionID completionHandler:^(NSString *subscriptionID, NSError *error) {
//                if (error) {
//                    NSLog(@"Error removing subscription");
//                }
//            }];
//        }
//    }];
    
    CKQuery *query = [[CKQuery alloc] initWithRecordType:NSStringFromClass([KNIIssue class]) predicate:predicate];
    __weak __typeof__(self) weakSelf = self;
    [self.publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) NSLog(@"Error fetching issues: %@", error);
        NSMutableArray *issues = [[NSMutableArray alloc] init];
        for (CKRecord *record in results) {
            KNIIssue *issue = [[KNIIssue alloc] initWithRecord:record database:weakSelf.publicDatabase];
            [issues addObject:issue];
        }
        [issues sortUsingComparator:^NSComparisonResult(KNIIssue *obj1, KNIIssue *obj2) {
            NSComparisonResult volumeResult = [obj2.volume compare:obj1.volume];
            if (volumeResult == NSOrderedSame)
            {
                return [obj2.number compare:obj1.number];
            }
            return volumeResult;
        }];
        BOOL didLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:KNIAppDidLaunchKey];
        if (!didLaunch)
        {
            NSArray *tutorialIssues = [issues filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"volume == 0"]];
            KNIIssue *issue = [tutorialIssues firstObject];
            if (issue)
            {
                [issues removeLastObject];
                NSMutableArray *iss = [NSMutableArray arrayWithObject:issue];
                [iss addObjectsFromArray:issues];
                issues = iss;
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block([issues copy], error);
        }];
    }];
}

- (void)fetchAllRecommendedItemsWithCompletion:(void (^)(NSArray *, NSError *))block
{
    NSParameterAssert(block);
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"!(excludeFromHotList > 0)"];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"KNIRecommendedItem" predicate:predicate];
    __weak __typeof__(self) weakSelf = self;
    [self.publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        NSMutableArray *recommendedItems = [[NSMutableArray alloc] init];
        for (CKRecord *record in results) {
            KNIRecommendedItem *item = [[KNIRecommendedItem alloc] initWithRecord:record database:weakSelf.publicDatabase];
            [recommendedItems addObject:item];
        }
        [recommendedItems sortUsingComparator:^NSComparisonResult(KNIRecommendedItem *obj1, KNIRecommendedItem *obj2) {
            return [obj1.createdDate compare:obj2.createdDate];
        }];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block([recommendedItems copy], error);
        }];
    }];
}

- (void)updateAllRecommendedItems
{
    __weak __typeof__(self) weakSelf = self;
    [self fetchAllRecommendedItemsWithCompletion:^(NSArray *items, NSError *error) {
        if ([items isKindOfClass:[NSArray class]])
        {
            weakSelf.recommendedItems = items;
            [weakSelf fetchItemDetails];
        }
    }];
}

- (void)fetchItemDetails
{
    __block NSInteger nIterationsLeft = self.recommendedItems.count;
    for (KNIRecommendedItem *item in self.recommendedItems)
    {
        [item fetchDetailWithCompletion:^(NSArray *errors) {
            nIterationsLeft--;
            if (nIterationsLeft <= 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:KNICloudKitControllerDidUpdateRecommendedItemsListNotification object:nil];
            }
            for (NSError *error in errors)
            {
                NSLog(@"Error fetching detail: %@", error);
            }
        }];
    }
}

- (void)updateGlobalRecord:(CKRecord *)record completion:(void (^)(CKRecord *, NSError *))block
{
    NSParameterAssert(block != nil);
    
    [self.publicDatabase saveRecord:record completionHandler:block];
}

@end
