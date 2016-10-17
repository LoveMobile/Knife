//
//  KNICellExpandingTransitionAnimator.h
//  The Knife
//
//  Created by Brian Drell on 11/9/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KNIIssueCollectionViewCell;

@interface KNICellExpandingTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

- (instancetype)initWithCell:(KNIIssueCollectionViewCell *)cell frame:(CGRect)frame;

@end
