//
//  KNIPagingCollectionViewFlowLayout.h
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KNIPagingCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic) CGFloat flickVelocity;
@property (nonatomic) NSInteger currentPage;

@end
