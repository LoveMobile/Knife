//
//  KNIOffsetAnimator.h
//  The Knife
//
//  Created by Brian Drell on 2/27/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KNIOffsetAnimator : NSObject

- (void)scrollView:(UIScrollView *)scrollView setContentOffset:(CGPoint)contentOffset duration:(NSTimeInterval)duration completion:(void(^)(BOOL finished))block;

@end
