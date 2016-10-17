//
//  KNICellCloneView.m
//  The Knife
//
//  Created by Brian Drell on 2/1/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import "KNICellCloneView.h"

@interface KNICellCloneView ()



@end

@implementation KNICellCloneView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.label.hidden = YES;
    self.bottomLabel.hidden = YES;
    self.imageView.translatesAutoresizingMaskIntoConstraints = YES;
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    self.imageView.bounds = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds]));
    self.imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    CGPoint center = CGPointMake(CGRectGetWidth(bounds)/2, CGRectGetHeight(bounds)/2);
    self.imageView.center = center;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    self.imageView.center = center;
}

@end
