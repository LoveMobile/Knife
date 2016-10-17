//
//  KNIDelegatingTransitionAnimator.m
//  The Knife
//
//  Created by Brian Drell on 11/23/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNIDelegatingTransitionAnimator.h"

@interface KNIDelegatingTransitionAnimator ()

@property (nonatomic) BOOL isPresenting;
@property (nonatomic, weak) UIViewController<KNITransitioningViewController> *presentingViewController;
@property (nonatomic, weak) UIViewController<KNITransitioningViewController> *dismissingViewController;

@end

@implementation KNIDelegatingTransitionAnimator

- (instancetype)init
{
    if (self = [super init]) {
        _duration = 1.2;
        _isPresenting = YES;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isPresenting) {
        self.isPresenting = NO;
        UIViewController *presentingViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        if ([presentingViewController isKindOfClass:[UITabBarController class]])
        {
            UITabBarController *tabBarController = (UITabBarController *)presentingViewController;
            presentingViewController = [[tabBarController viewControllers] objectAtIndex:tabBarController.selectedIndex];
        }
        if ([presentingViewController isKindOfClass:[UINavigationController class]])
        {
            presentingViewController = [[(UINavigationController *)presentingViewController viewControllers] firstObject];
        }
        UIViewController *dismissingViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        if ([dismissingViewController isKindOfClass:[UINavigationController class]])
        {
            dismissingViewController = [[(UINavigationController *)dismissingViewController viewControllers] firstObject];
        }
        NSAssert([presentingViewController conformsToProtocol:@protocol(KNITransitioningViewController)] && [dismissingViewController conformsToProtocol:@protocol(KNITransitioningViewController)], @"ViewControllers MUST conform to KNITransitioningViewController");
        self.presentingViewController = (UIViewController<KNITransitioningViewController> *)presentingViewController;
        self.dismissingViewController = (UIViewController<KNITransitioningViewController> *)dismissingViewController;
        [self animatePresentation:transitionContext];
    } else {
        [self animateDismissal:transitionContext];
    }
}

- (void)animatePresentation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *container = [transitionContext containerView];
    [self.presentingViewController animatePresentationWithDuration:self.duration / 3 isFirstViewController:YES completion:^{
        self.dismissingViewController.view.alpha = 0;
        [container addSubview:self.dismissingViewController.view];
        [UIView animateWithDuration:self.duration / 3 animations:^{
            self.dismissingViewController.view.alpha = 1;
        } completion:^(BOOL finished) {
            [self.presentingViewController.view removeFromSuperview];
            [self.dismissingViewController animatePresentationWithDuration:self.duration / 3 isFirstViewController:NO completion:^{
                [transitionContext completeTransition:YES];
            }];
        }];
//        [UIView transitionFromView:self.presentingViewController.view toView:self.dismissingViewController.view duration:self.duration / 3 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
//            [self.dismissingViewController animateDismissalWithDuration:self.duration / 3 isFirstViewController:NO completion:^{
//                [transitionContext completeTransition:YES];
//            }];
//        }];
    }];
}

- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext
{
    [self.dismissingViewController animateDismissalWithDuration:self.duration / 3 isFirstViewController:YES completion:^{
        [UIView transitionFromView:self.dismissingViewController.view toView:self.presentingViewController.view duration:self.duration / 3 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            [self.presentingViewController animateDismissalWithDuration:self.duration / 3 isFirstViewController:NO completion:^{
                [transitionContext completeTransition:YES];
            }];
        }];
    }];
}

@end
