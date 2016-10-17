//
//  KNIUserInfo.h
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CloudKit;

@interface KNIUserInfo : NSObject

- (instancetype)initWithContainer:(CKContainer *)container;

@end
