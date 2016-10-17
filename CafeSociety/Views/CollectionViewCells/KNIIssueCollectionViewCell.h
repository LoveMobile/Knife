//
//  KNIIssueCollectionViewCell.h
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNIIssue.h"
#import "KNIRecommendedItem.h"
#import "KNICellCloneView.h"

@interface KNIIssueCollectionViewCell : UICollectionViewCell

@property (nonatomic, readonly) UIImage *image;

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
- (void)setExpanded:(BOOL)expanded completion:(void(^)())block;

+ (KNICellCloneView *)clonedCell:(KNIIssueCollectionViewCell *)cell;

- (void)configureWithIssue:(KNIIssue *)issue;
- (void)configureWithItem:(KNIRecommendedItem *)item;

@end
