//
//  UIImageView+CloudKitExtensions.m
//  The Knife
//
//  Created by Brian Drell on 10/28/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "UIImageView+CloudKitExtensions.h"

@implementation UIImageView (CloudKitExtensions)

- (void)setImageAsset:(CKAsset *)asset
{
    static NSCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    UIImage *image = [cache objectForKey:asset.fileURL.absoluteString];
    if (image)
    {
        self.image = image;
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:asset.fileURL];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cache setObject:image forKey:asset.fileURL.absoluteString];
            self.image = image;
        });
    });
}

@end
