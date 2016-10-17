//
//  KNIContainerViewController.m
//  The Knife
//
//  Created by Staevan Duckworth on 10/10/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import "KNIContainerViewController.h"

@interface KNIContainerViewController () <KNITransitioningViewController>

@end

@implementation KNIContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark - KNITransitioningViewController

- (void)animatePresentationWithDuration:(NSTimeInterval)duration isFirstViewController:(BOOL)isFirst completion:(void (^)())block
{
    dispatch_after(duration, dispatch_get_main_queue(), ^{
        block();
    });
}

- (void)animateDismissalWithDuration:(NSTimeInterval)duration isFirstViewController:(BOOL)isFirst completion:(void (^)())block
{
    if (block) block();
}

@end
