//
//  KNIImageAssetFetcher.m
//  The Knife
//
//  Created by Brian Drell on 2/11/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import "KNIImageAssetFetcher.h"
#import "KNIImageCache.h"
#import "KNICloudKitController.h"

@interface KNIImageAssetFetcher ()

@property (nonatomic, strong) CKContainer *container;
@property (nonatomic, strong) CKDatabase *publicDatabase;
@property (nonatomic, strong) CKDatabase *userDatabase;

@end

@implementation KNIImageAssetFetcher

- (instancetype)init
{
    if (self = [super init]) {
        _container = [CKContainer containerWithIdentifier:@"iCloud.com.everydream.TheKnife"];
        _publicDatabase = _container.publicCloudDatabase;
        _userDatabase = _container.privateCloudDatabase;
    }
    return self;
}

- (void)fetchImageForAssetRecordID:(CKRecordID *)asset completion:(void(^)(UIImage *image))block
{
    if (!asset) return;
    
    NSParameterAssert(block != nil);
    
    [[KNIImageCache sharedCache] readImageFromCacheAndDecodeForRecordID:asset completion:^(UIImage *image) {
        if (image)
        {
            block(image);
        }
        else
        {
            [self fetchFromWebWithID:asset completion:block];
        }
    }];
}

- (void)fetchFromWebWithID:(CKRecordID *)asset completion:(void(^)(UIImage *image))block
{
    [self.publicDatabase fetchRecordWithID:asset completionHandler:^(CKRecord *record, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CKAsset *asset = record[@"asset"];
            if (!asset) return;
            NSData *data = [NSData dataWithContentsOfURL:asset.fileURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[KNIImageCache sharedCache] decodeImageInBackgroundWithData:data completion:^(UIImage *image) {
                    [[KNIImageCache sharedCache] cacheImage:image forCloudKitRecordID:record.recordID];
                    block(image);
                }];
            });
        });
    }];
}

@end
