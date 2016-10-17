//
//  KNIGradientView.m
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNIGradientView.h"

@implementation KNIGradientView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    CAGradientLayer *layer = (CAGradientLayer *)self.layer;
    layer.colors = @[(__bridge id)[[UIColor kni_backgroundGrayColor] CGColor], (__bridge id)[[UIColor clearColor] CGColor]];
}

@end
