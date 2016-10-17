//
//  KNILaunchViewController.h
//  TheKnife
//
//  Created by Brian Drell on 10/26/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KNILaunchViewController : UIViewController

@property (nonatomic) CGRect finalLabelFrame;

- (void)animateDismissalWithCompletion:(void(^)())completionBlock;

@end
