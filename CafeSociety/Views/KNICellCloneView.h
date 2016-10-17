//
//  KNICellCloneView.h
//  The Knife
//
//  Created by Brian Drell on 2/1/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface KNICellCloneView : UIView
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@end
