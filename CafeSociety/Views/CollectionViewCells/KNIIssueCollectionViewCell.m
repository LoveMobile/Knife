//
//  KNIIssueCollectionViewCell.m
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNIIssueCollectionViewCell.h"
#import "KNIVignetteView.h"
#import "KNIAttributedStringFactory.h"

@interface KNIIssueCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelWidthConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@end

@implementation KNIIssueCollectionViewCell

+ (KNICellCloneView *)clonedCell:(KNIIssueCollectionViewCell *)cell
{
    KNICellCloneView *clonedCell = [[[UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] firstObject];
    clonedCell.label.text = cell.label.text;
//    clonedCell.bottomLabel.text = cell.bottomLabel.text;
//    clonedCell.bottomLabel.frame = cell.bottomLabel.frame;
    clonedCell.imageView.image = cell.imageView.image;
    return clonedCell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.imageViewWidthConstraint.constant = [[UIScreen mainScreen] bounds].size.width;
    self.imageViewHeightConstraint.constant = [[UIScreen mainScreen] bounds].size.height;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.expanded = NO;
    self.labelWidthConstraint.constant = CGRectGetWidth(self.contentView.bounds) - 32;
    self.imageView.image = nil;
}

- (void)setExpanded:(BOOL)expanded completion:(void(^)())block
{
    _expanded = expanded;
    self.bottomLabelHeightConstraint.priority = 760 - 260*expanded;
    if (expanded) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.contentView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.bottomLabel.alpha = 1;
            } completion:^(BOOL finished) {
                if (block) block();
            }];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                [self.contentView layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (block) block();
            }];
        }];
    }
}

- (void)configureWithIssue:(KNIIssue *)issue
{
    __weak __typeof__(self) weakSelf = self;
    [self.activityIndicator startAnimating];
    [issue downloadImageWithCompletion:^(UIImage *image) {
        [UIView transitionWithView:weakSelf.imageView duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [weakSelf.activityIndicator stopAnimating];
            weakSelf.imageView.image = image;
        } completion:^(BOOL finished) {
            
        }];
    }];
    self.label.text = issue.name;
    self.bottomLabel.attributedText = [KNIAttributedStringFactory trackedIssueSubheadlineText:issue.subtitle];
}

- (void)configureWithItem:(KNIRecommendedItem *)item
{
    __weak __typeof__(self) weakSelf = self;
    [self.activityIndicator startAnimating];
    [item downloadImageWithCompletion:^(UIImage *image) {
        [UIView transitionWithView:weakSelf.imageView duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        [weakSelf.activityIndicator stopAnimating];
            weakSelf.imageView.image = image;
        } completion:^(BOOL finished) {
            
        }];
    }];
    self.label.text = item.title;
    self.label.textColor = item.titleTextColor;
    self.bottomLabel.attributedText = [KNIAttributedStringFactory trackedIssueSubheadlineText:item.location.name];
}

- (UIImage *)image
{
    return self.imageView.image;
}

@end
