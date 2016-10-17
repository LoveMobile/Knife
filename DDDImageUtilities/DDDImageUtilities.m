//
//  DDDImageUtilities.m
//  DDDLibraries
//
//  Created by Brian Drell on 3/5/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

#import "DDDImageUtilities.h"
#import "DDDImageFetcher.h"
#import "UIImage+ImageEffects.h"

@interface DDDImageUtilities ()

@end


@implementation DDDImageUtilities

+ (void)applyExtraLightEffectToImage:(UIImage *)image completion:(DDDImageCompletionBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *blurredImage = [image applyExtraLightEffect];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(blurredImage);
        });
    });
}

+ (void)applyExtraLightEffectToView:(UIView *)view inRect:(CGRect)rect completion:(DDDImageCompletionBlock)block
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    snapshot = [self croppedImage:snapshot inRect:rect];
    [self applyExtraLightEffectToImage:snapshot completion:block];
}

+ (void)applyExtraLightEffectToImageWithURL:(NSURL *)url completion:(DDDImageCompletionBlock)block
{
    [[DDDImageFetcher sharedFetcher] fetchImageURL:url completion:^(UIImage *image, NSURLResponse *response, NSError *error) {
        if (!error && image)
        {
            [self applyExtraLightEffectToImage:image completion:block];
        }
    }];
}

+ (void)applyLightEffectToImage:(UIImage *)image completion:(DDDImageCompletionBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *blurredImage = [image applyLightEffect];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(blurredImage);
        });
    });
}

+ (void)applyLightEffectToView:(UIView *)view inRect:(CGRect)rect completion:(DDDImageCompletionBlock)block
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    snapshot = [self croppedImage:snapshot inRect:rect];
    [self applyLightEffectToImage:snapshot completion:block];
}

+ (void)applyLightEffectToImageWithURL:(NSURL *)url completion:(DDDImageCompletionBlock)block
{
    [[DDDImageFetcher sharedFetcher] fetchImageURL:url completion:^(UIImage *image, NSURLResponse *response, NSError *error) {
        if (!error && image)
        {
            [self applyLightEffectToImage:image completion:block];
        }
    }];
}

+ (void)applyDarkEffectToImage:(UIImage *)image completion:(DDDImageCompletionBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *blurredImage = [image applyDarkEffect];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(blurredImage);
        });
    });
}

+ (void)applyDarkEffectToView:(UIView *)view inRect:(CGRect)rect completion:(DDDImageCompletionBlock)block
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    snapshot = [self croppedImage:snapshot inRect:rect];
    [self applyDarkEffectToImage:snapshot completion:block];
}

+ (void)applyDarkEffectToImageWithURL:(NSURL *)url completion:(DDDImageCompletionBlock)block
{
    [[DDDImageFetcher sharedFetcher] fetchImageURL:url completion:^(UIImage *image, NSURLResponse *response, NSError *error) {
        if (!error && image)
        {
            [self applyDarkEffectToImage:image completion:block];
        }
    }];
}

+ (void)applyBlurToImage:(UIImage *)image withRadius:(CGFloat)radius tintColor:(UIColor *)tintColor completion:(DDDImageCompletionBlock)block
{
    NSParameterAssert(block);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *blurredImage = [image applyBlurWithRadius:radius tintColor:tintColor saturationDeltaFactor:1 maskImage:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(blurredImage);
        });
    });
}

+ (UIImage *)croppedImage:(UIImage *)image inRect:(CGRect)cropRect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CFRelease(imageRef);
    return croppedImage;
}

@end
