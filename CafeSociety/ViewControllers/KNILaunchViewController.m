//
//  KNILaunchViewController.m
//  TheKnife
//
//  Created by Brian Drell on 10/26/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNILaunchViewController.h"

@interface KNILaunchViewController ()

@property (nonatomic, weak) UIImageView *label;

@end

@implementation KNILaunchViewController

- (void)loadView
{
    UIView *view = [[[UINib nibWithNibName:@"LaunchScreen" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] firstObject];
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[UIImageView class]])
        {
            self.label = (UIImageView *)view;
            [self.view removeConstraints:self.view.constraints];
            self.label.translatesAutoresizingMaskIntoConstraints = YES;
            self.label.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.label.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [super viewWillAppear:animated];
}

- (void)animateDismissalWithCompletion:(void (^)())completionBlock
{
    [UIView animateKeyframesWithDuration:0.7 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear | UIViewAnimationOptionCurveEaseIn animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            self.label.frame = self.finalLabelFrame;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.7 relativeDuration:0.5 animations:^{
            self.view.alpha = 0;
        }];
    } completion:^(BOOL finished) {
        if (completionBlock) completionBlock();
    }];
}

@end
