//
//  KNIImageCache.h
//  The Knife
//
//  Created by Brian Drell on 2/7/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CloudKit;

@interface KNIImageCache : UIView

+ (instancetype)sharedCache;

- (UIImage *)imageForCloudKitRecordID:(CKRecordID *)recordID;
- (void)readImageFromCacheAndDecodeForRecordID:(CKRecordID *)recordID completion:(void(^)(UIImage *image))block;

- (void)cacheImage:(UIImage *)image forCloudKitRecordID:(CKRecordID *)recordID;

- (void)decodeImageInBackgroundWithData:(NSData *)data completion:(void(^)(UIImage *image))block;

@end
