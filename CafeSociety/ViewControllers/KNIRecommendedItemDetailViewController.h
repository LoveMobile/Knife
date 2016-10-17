//
//  KNIRecommendedItemDetailViewController.h
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

@import UIKit;
#import "KNIRecommendedItem.h"

@interface KNIRecommendedItemDetailViewController : UIViewController

@property (nonatomic, strong) KNIRecommendedItem *item;
@property (nonatomic, strong) UIImage *itemImage;

@end
