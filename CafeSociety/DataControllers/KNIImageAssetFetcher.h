//
//  KNIImageAssetFetcher.h
//  The Knife
//
//  Created by Brian Drell on 2/11/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

@import UIKit;
@import CloudKit;

@interface KNIImageAssetFetcher : NSObject

- (void)fetchImageForAssetRecordID:(CKRecordID *)asset completion:(void(^)(UIImage *image))block;

@end
