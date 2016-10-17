//
//  DDDAnimator.h
//  The Knife
//
//  Created by Brian Drell on 12/14/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDDInterpolation : NSObject

+ (double)interpolateDoubleWithMinimum:(double)minimum maximum:(double)maximum animationPoint:(NSTimeInterval)animationPoint;
+ (NSInteger)interpolateIntegerWithMinimum:(NSInteger)minimum maximum:(NSInteger)maximum animationPoint:(NSTimeInterval)animationPoint;
+ (CGPoint)interpolatePointWithMinimum:(CGPoint)minimum maximum:(CGPoint)maximum animationPoint:(NSTimeInterval)animationPoint;
+ (CGSize)interpolateSizeWithMinimum:(CGSize)minimum maximum:(CGSize)maximum animationPoint:(NSTimeInterval)animationPoint;
+ (CGRect)interpolateRectWithMinimum:(CGRect)minimum maximum:(CGRect)maximum animationPoint:(NSTimeInterval)animationPoint;

@end

@interface DDDAnimator : NSObject

+ (instancetype)animatorWithDuration:(NSTimeInterval)duration animationBlock:(void(^)(NSTimeInterval animationPoint))animationBlock completionBlock:(void(^)(BOOL finished))completionBlock;

- (void)animateToAnimationPoint:(NSTimeInterval)animationPoint;
// Calling this while in the middle of an animation will assert and make your app die. So don't do that.
// Does not call the completion block.
- (void)setToAnimationPoint:(NSTimeInterval)animationPoint;
- (void)startAnimating;
// Willl call the completion block with NO as the success parameter.
- (void)stopAnimating;

@end
