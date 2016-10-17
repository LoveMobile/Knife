//
//  KNIOffsetAnimator.m
//  The Knife
//
//  Created by Brian Drell on 2/27/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import "KNIOffsetAnimator.h"
#import "DDDAnimator.h"

@interface KNIOffsetAnimator ()

@property (nonatomic, strong) DDDAnimator *animator;

@end

@implementation KNIOffsetAnimator

- (void)scrollView:(UIScrollView *)scrollView setContentOffset:(CGPoint)contentOffset duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))block
{
    CGPoint startingOffset = scrollView.contentOffset;
    self.animator = [DDDAnimator animatorWithDuration:duration animationBlock:^(NSTimeInterval animationPoint) {
        scrollView.contentOffset = [DDDInterpolation interpolatePointWithMinimum:startingOffset maximum:contentOffset animationPoint:animationPoint];
    } completionBlock:^(BOOL finished) {
        if (block) block(finished);
    }];
    [self.animator startAnimating];
}

@end
