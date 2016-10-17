//
//  UIImageView+CloudKitExtensions.h
//  The Knife
//
//  Created by Brian Drell on 10/28/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CloudKit;

@interface UIImageView (CloudKitExtensions)

- (void)setImageAsset:(CKAsset *)asset;

@end
