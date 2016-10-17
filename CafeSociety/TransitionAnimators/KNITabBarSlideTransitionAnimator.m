//
//  KNITabBarSlideTransitionAnimator.m
//  The Knife
//
//  Created by Brian Drell on 2/22/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import "KNITabBarSlideTransitionAnimator.h"

@interface KNITabBarSlideTransitionAnimator ()

@property (nonatomic, strong) UITabBarController *tabBarController;

@end

@implementation KNITabBarSlideTransitionAnimator

- (instancetype)initWithTabBarController:(UITabBarController *)tabBarController
{
    if (self = [super init])
    {
        _tabBarController = tabBarController;
        _tabBarController.delegate = self;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _duration ? _duration : 0.4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    NSInteger fromVCIndex = [self.tabBarController.viewControllers indexOfObject:fromVC];
    NSInteger toVCIndex = [self.tabBarController.viewControllers indexOfObject:toVC];
    if (toVCIndex > fromVCIndex) {
        // Slide from right
        CGRect fromVCFrame = fromVC.view.frame;
        CGRect toVCFrame = CGRectOffset(fromVCFrame, fromVCFrame.size.width, 0);
        CGRect finalFromVCFrame = CGRectOffset(fromVCFrame, -fromVCFrame.size.width, 0);
        [container addSubview:toVC.view];
        toVC.view.frame = toVCFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromVC.view.frame = finalFromVCFrame;
            toVC.view.frame = fromVCFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        CGRect fromVCFrame = fromVC.view.frame;
        CGRect toVCFrame = CGRectOffset(fromVCFrame, -fromVCFrame.size.width, 0);
        CGRect finalFromVCFrame = CGRectOffset(fromVCFrame, fromVCFrame.size.width, 0);
        [container addSubview:toVC.view];
        toVC.view.frame = toVCFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromVC.view.frame = finalFromVCFrame;
            toVC.view.frame = fromVCFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    return self;
}

@end
