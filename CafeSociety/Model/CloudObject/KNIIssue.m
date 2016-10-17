//
//  KNIIssue.m
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNIIssue.h"
#import "KNIImageCache.h"
#import "KNIImageAssetFetcher.h"

@interface KNIIssue ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic) NSArray *itemReferences;
@property (nonatomic, strong) CKRecord *record;
@property (nonatomic, strong) CKRecord *imageRecord;
@property (nonatomic, weak) CKDatabase *database;

@end

@implementation KNIIssue

- (instancetype)initWithRecord:(CKRecord *)record database:(CKDatabase *)database
{
    if (self = [super init]) {
        _record = record;
        _database = database;
    }
    return self;
}

- (NSString *)name
{
    return self.record[@"name"];
}

- (NSNumber *)volume
{
    return self.record[@"volume"];
}

- (NSNumber *)number
{
    return self.record[@"number"];
}

- (NSDate *)createDate
{
    return self.record[@"createDate"];
}

- (NSArray *)itemReferences
{
    return self.record[@"items"];
}

- (NSString *)subtitle
{
    return [self.record[@"subtitle"] uppercaseString];
}

- (NSString *)quotation
{
    return [NSString stringWithFormat:@"\"%@\"", self.record[@"quotation"]];
}

- (NSString *)detail
{
    NSMutableString *detail = [NSMutableString string];
    NSArray *paragraphs = [self detailParagraphs];
    if ([[self detailParagraphs] count]) {
        for (NSString *pp in paragraphs) {
            [detail appendString:pp];
            if (pp != [paragraphs lastObject]) {
                [detail appendString:@"\n\n"];
            }
        }
        return detail;
    }
    return self.record[@"detail"];
}

- (NSArray *)detailParagraphs
{
    return self.record[@"detailParagraphs"];
}

- (void)sortItems
{
    self.items = [self.items sortedArrayUsingComparator:^NSComparisonResult(KNIRecommendedItem *item1, KNIRecommendedItem *item2) {
        return [item1.createdDate compare:item2.createdDate];
    }];
}

- (void)fetchItemsWithCompletion:(void (^)(NSError *))block
{
    NSLog(@"fetchItemsWithCompletion");
    __block NSInteger itemCount = [self.itemReferences count];
    __block NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    NSAssert([NSThread isMainThread], @"Must be on the main thread.");
    __weak __typeof__(self) weakSelf = self;
    self.isFetchingItems = YES;
    for (CKReference *itemRef in self.itemReferences) {
        [self.database fetchRecordWithID:itemRef.recordID completionHandler:^(CKRecord *record, NSError *error) {
            if (record)
            {
                KNIRecommendedItem *item = [[KNIRecommendedItem alloc] initWithRecord:record database:weakSelf.database];
                [itemArray addObject:item];
                [item fetchDetailWithCompletion:^(NSArray *errors) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        itemCount--;
                        if (itemCount <= 0) {
                            weakSelf.isFetchingItems = NO;
                            weakSelf.items = [itemArray sortedArrayUsingComparator:^NSComparisonResult(KNIRecommendedItem *obj1, KNIRecommendedItem *obj2) {
                                return [obj1.createdDate compare:obj2.createdDate];
                            }];
                            weakSelf.items = [itemArray copy];
                            block(nil);
                        }
                    });
                }];
            }
        }];
    }
}

- (void)downloadImageWithCompletion:(void (^)(UIImage *image))block
{
    NSParameterAssert(block);
    KNIImageAssetFetcher *fetcher = [[KNIImageAssetFetcher alloc] init];
    CKReference *imageRef = self.record[@"image"];
    [fetcher fetchImageForAssetRecordID:imageRef.recordID completion:[block copy]];
}

- (void)downloadImageWithCompletion_:(void(^)(UIImage *image))block
{
    NSParameterAssert(block);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.imageRecord) {
            CKAsset *asset = self.imageRecord[@"asset"];
            NSData *data = [NSData dataWithContentsOfURL:asset.fileURL];
            UIImage *image = [UIImage imageWithData:data];
            if (!image)
            {
                self.imageRecord = nil;
                [self downloadImageWithCompletion:block];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                block(image);
            });
            
            return;
        }
        
        CKReference *imageRef = self.record[@"image"];
        UIImage *cachedImage = [[KNIImageCache sharedCache] imageForCloudKitRecordID:imageRef.recordID];
        if (cachedImage)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(cachedImage);
            });
            return;
        }
        __weak __typeof__(self) weakSelf = self;
        [self.database fetchRecordWithID:imageRef.recordID completionHandler:^(CKRecord *record, NSError *error) {
            weakSelf.imageRecord = record;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                CKAsset *asset = record[@"asset"];
                NSData *data = [NSData dataWithContentsOfURL:asset.fileURL];
                UIImage *image = [UIImage imageWithData:data];
                [[KNIImageCache sharedCache] cacheImage:image forCloudKitRecordID:record.recordID];
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(image);
                });
            });
        }];
    });
}

@end
