//
//  KNIContainerViewController.h
//  The Knife
//
//  Created by Staevan Duckworth on 10/10/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KNIContainerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) UIView *transitioningCell;
@property (nonatomic, assign) CGRect startingCellFrame;
@end
