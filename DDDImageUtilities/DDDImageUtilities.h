//
//  DDDImageUtilities.h
//  DDDLibraries
//
//  Created by Brian Drell on 3/5/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

@import UIKit;

typedef void(^DDDImageCompletionBlock)(UIImage *image);


@interface DDDImageUtilities : NSObject

+ (void)applyExtraLightEffectToImage:(UIImage *)image completion:(DDDImageCompletionBlock)block;
+ (void)applyExtraLightEffectToView:(UIView *)view inRect:(CGRect)rect completion:(DDDImageCompletionBlock)block;
+ (void)applyExtraLightEffectToImageWithURL:(NSURL *)url completion:(DDDImageCompletionBlock)block;

+ (void)applyLightEffectToImage:(UIImage *)image completion:(DDDImageCompletionBlock)block;
+ (void)applyLightEffectToView:(UIView *)view inRect:(CGRect)rect completion:(DDDImageCompletionBlock)block;
+ (void)applyLightEffectToImageWithURL:(NSURL *)url completion:(DDDImageCompletionBlock)block;

+ (void)applyDarkEffectToImage:(UIImage *)image completion:(DDDImageCompletionBlock)block;
+ (void)applyDarkEffectToView:(UIView *)view inRect:(CGRect)rect completion:(DDDImageCompletionBlock)block;
+ (void)applyDarkEffectToImageWithURL:(NSURL *)url completion:(DDDImageCompletionBlock)block;

+ (void)applyBlurToImage:(UIImage *)image withRadius:(CGFloat)radius tintColor:(UIColor *)tintColor completion:(DDDImageCompletionBlock)block;

+ (UIImage *)croppedImage:(UIImage *)image inRect:(CGRect)cropRect;

@end
