//
//  KNICollapsingHeaderView.h
//  TheKnife
//
//  Created by Brian Drell on 10/26/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface KNICollapsingHeaderView : UIView

@property (nonatomic) IBInspectable CGFloat maximumHeight;
@property (nonatomic) IBInspectable CGFloat minimumHeight;

@end
