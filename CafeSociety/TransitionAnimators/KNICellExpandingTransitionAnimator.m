//
//  KNICellExpandingTransitionAnimator.m
//  The Knife
//
//  Created by Brian Drell on 11/9/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNICellExpandingTransitionAnimator.h"
#import "KNIIssueCollectionViewCell.h"

@interface KNICellExpandingTransitionAnimator ()

@property (nonatomic, assign) BOOL isPresenting;

@property (nonatomic, strong) UIView *fromView;
@property (nonatomic, strong) UIView *toView;
@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) KNIIssueCollectionViewCell *cell;
@property (nonatomic, assign) CGRect frame;

@end

@implementation KNICellExpandingTransitionAnimator

- (instancetype)initWithCell:(KNIIssueCollectionViewCell *)cell frame:(CGRect)frame
{
    if (self = [super init]) {
        _cell = cell;
        cell.translatesAutoresizingMaskIntoConstraints = YES;
        _frame = frame;
        _isPresenting = YES;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isPresenting)
    {
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        self.fromView = fromViewController.view;
        self.toView = toViewController.view;
        self.container = [transitionContext containerView];
        [self animatePresentation:transitionContext];
    } else {
        [self animateDismissal:transitionContext];
    }
}

- (void)animatePresentation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    __weak __typeof__(self) weakSelf = self;
    
    self.isPresenting = NO;
    self.cell.frame = self.frame;
    [self.container addSubview:self.cell];
    [UIView animateWithDuration:0.3 animations:^{
        self.cell.frame = self.container.bounds;
        [self.cell layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.container insertSubview:self.toView belowSubview:self.cell];
        [self.cell setExpanded:YES completion:^{
            [UIView animateWithDuration:0.1 animations:^{
                weakSelf.cell.alpha = 0;
            } completion:^(BOOL finished) {
                [weakSelf.cell removeFromSuperview];
                [weakSelf.fromView removeFromSuperview];
                [transitionContext completeTransition:YES];
            }];
        }];
    }];
}

- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext
{
    __weak __typeof__(self) weakSelf = self;
    
    [self.container insertSubview:self.fromView belowSubview:self.toView];
    self.cell.frame = self.container.bounds;
    [self.container addSubview:self.cell];
    [UIView animateWithDuration:0.1 animations:^{
        self.cell.alpha = 1;
    } completion:^(BOOL finished) {
        [self.cell setExpanded:NO completion:^{
            [weakSelf.toView removeFromSuperview];
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.cell.frame = weakSelf.frame;
                [weakSelf.cell layoutIfNeeded];
            } completion:^(BOOL finished) {
                [weakSelf.cell removeFromSuperview];
                [weakSelf.toView removeFromSuperview];
                [transitionContext completeTransition:YES];
            }];
        }];
    }];
    
}

@end
