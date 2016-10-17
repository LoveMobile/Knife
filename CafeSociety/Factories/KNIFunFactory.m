//
//  KNIFunFactory.m
//  The Knife
//
//  Created by Brian Drell on 2/28/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import "KNIFunFactory.h"

@implementation KNIFunFactory

+ (void)addParallaxMotionEffectsToView:(UIView *)view parallaxOffset:(CGFloat)parallaxOffset
{
    UIInterpolatingMotionEffect *hMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    hMotionEffect.minimumRelativeValue = @(-parallaxOffset);
    hMotionEffect.maximumRelativeValue = @(parallaxOffset);
    
    UIInterpolatingMotionEffect *vMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    vMotionEffect.minimumRelativeValue = @(-parallaxOffset);
    vMotionEffect.maximumRelativeValue = @(parallaxOffset);
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[hMotionEffect, vMotionEffect];
    
    [view addMotionEffect:group];
}

@end
