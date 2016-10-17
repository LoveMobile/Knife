//
//  KNITabBarSlideTransitionAnimator.h
//  The Knife
//
//  Created by Brian Drell on 2/22/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KNITabBarSlideTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning, UITabBarControllerDelegate>

- (instancetype)initWithTabBarController:(UITabBarController *)tabBarController;

@property (nonatomic) NSTimeInterval duration;

@end
