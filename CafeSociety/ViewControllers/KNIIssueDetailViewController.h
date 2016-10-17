//
//  KNIIssueDetailViewController.h
//  TheKnife
//
//  Created by Brian Drell on 10/26/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNIIssue.h"

@class KNICloudKitController;

@interface KNIIssueDetailViewController : UIViewController <KNITransitioningViewController>

@property (nonatomic, strong) KNICloudKitController *cloudKitController;
@property (nonatomic, strong) KNIIssue *issue;
@property (nonatomic, strong) UIImage *image;

@end
