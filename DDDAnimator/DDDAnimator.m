//
//  DDDAnimator.m
//  The Knife
//
//  Created by Brian Drell on 12/14/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "DDDAnimator.h"

double interpolate_animation_value(double minimum, double maximum, double animationPoint) {
    return minimum + (maximum - minimum) * animationPoint;
}

@implementation DDDInterpolation

+ (double)interpolateDoubleWithMinimum:(double)minimum maximum:(double)maximum animationPoint:(NSTimeInterval)animationPoint
{
    return interpolate_animation_value(minimum, maximum, animationPoint);
}

+ (NSInteger)interpolateIntegerWithMinimum:(NSInteger)minimum maximum:(NSInteger)maximum animationPoint:(NSTimeInterval)animationPoint
{
    double interpolation = interpolate_animation_value((double)minimum, (double)maximum, animationPoint);
    return round(interpolation);
}

+ (CGPoint)interpolatePointWithMinimum:(CGPoint)minimum maximum:(CGPoint)maximum animationPoint:(NSTimeInterval)animationPoint
{
    double x = interpolate_animation_value(minimum.x, maximum.x, animationPoint);
    double y = interpolate_animation_value(maximum.x, maximum.y, animationPoint);
    return CGPointMake(x, y);
}

+ (CGSize)interpolateSizeWithMinimum:(CGSize)minimum maximum:(CGSize)maximum animationPoint:(NSTimeInterval)animationPoint
{
    double height = interpolate_animation_value(minimum.height, maximum.height, animationPoint);
    double width = interpolate_animation_value(minimum.width, maximum.width, animationPoint);
    return CGSizeMake(width, height);
}

+ (CGRect)interpolateRectWithMinimum:(CGRect)minimum maximum:(CGRect)maximum animationPoint:(NSTimeInterval)animationPoint
{
    CGPoint origin = [self interpolatePointWithMinimum:minimum.origin maximum:maximum.origin animationPoint:animationPoint];
    CGSize size = [self interpolateSizeWithMinimum:minimum.size maximum:maximum.size animationPoint:animationPoint];
    return (CGRect){origin, size};
}

@end

@interface DDDAnimator ()

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval endingAnimationPoint;
@property (nonatomic, weak) CADisplayLink *displayLink;
@property (nonatomic, strong) NSDate *animationStartDate;
@property (nonatomic, copy) void(^animationBlock)(NSTimeInterval animationPoint);
@property (nonatomic, copy) void(^completionBlock)(BOOL finished);

@end

@implementation DDDAnimator

+ (instancetype)animatorWithDuration:(NSTimeInterval)duration animationBlock:(void (^)(NSTimeInterval))animationBlock completionBlock:(void (^)(BOOL))completionBlock
{
    NSParameterAssert(animationBlock != nil);
    NSParameterAssert(completionBlock != nil);
    DDDAnimator *animator = [[self alloc] init];
    animator.duration = duration;
    animator.animationBlock = animationBlock;
    animator.completionBlock = completionBlock;
    return animator;
}

- (void)startAnimating
{
    [self animateToAnimationPoint:1.];
}

- (void)stopAnimating
{
    [self.displayLink invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completionBlock(NO);
    });
}

- (void)animateToAnimationPoint:(NSTimeInterval)animationPoint
{
    self.endingAnimationPoint = animationPoint;
    self.animationStartDate = [NSDate date];
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
    self.displayLink = displayLink;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)setToAnimationPoint:(NSTimeInterval)animationPoint
{
    NSParameterAssert(self.displayLink == nil);
    [self pegAnimationPoint:&animationPoint];
    self.animationBlock(animationPoint);
}

- (void)displayLinkTick:(CADisplayLink *)displayLink
{
    NSTimeInterval currentAnimationPoint = [self currentAnimationPoint];
    BOOL endAnimation = currentAnimationPoint >= self.endingAnimationPoint;
    if (currentAnimationPoint >= self.endingAnimationPoint)
    {
        [self.displayLink invalidate];
    }
    [self pegAnimationPoint:&currentAnimationPoint];
    self.animationBlock(currentAnimationPoint);
    if (endAnimation)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(YES);
        });
    }
}

- (NSTimeInterval)currentAnimationPoint
{
    NSTimeInterval animationPoint = [[NSDate date] timeIntervalSinceDate:self.animationStartDate] / self.duration;
    return animationPoint;
}

- (void)pegAnimationPoint:(NSTimeInterval *)animationPoint
{
    *animationPoint = MAX(*animationPoint, 0.);
    *animationPoint = MIN(*animationPoint, 1.);
}

@end
