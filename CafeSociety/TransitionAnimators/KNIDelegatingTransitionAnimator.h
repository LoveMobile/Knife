//
//  KNIDelegatingTransitionAnimator.h
//  The Knife
//
//  Created by Brian Drell on 11/23/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KNITransitioningViewController <NSObject>

- (void)animatePresentationWithDuration:(NSTimeInterval)duration isFirstViewController:(BOOL)isFirst completion:(void(^)())block;
- (void)animateDismissalWithDuration:(NSTimeInterval)duration isFirstViewController:(BOOL)isFirst completion:(void(^)())block;

@end

@interface KNIDelegatingTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) NSTimeInterval duration;

@end
