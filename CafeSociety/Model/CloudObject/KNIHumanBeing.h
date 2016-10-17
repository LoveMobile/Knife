//
//  KNIHumanBeing.h
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

@import UIKit;
@import CloudKit;

@interface KNIHumanBeing : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *bio;
@property (nonatomic, readonly) NSURL *avatarURL;

- (instancetype)initWithRecord:(CKRecord *)record;

@end
