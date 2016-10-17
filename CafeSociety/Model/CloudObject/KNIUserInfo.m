//
//  KNIUserInfo.m
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNIUserInfo.h"

@interface KNIUserInfo ()

@property (nonatomic, strong) CKContainer *container;

@end

@implementation KNIUserInfo

- (instancetype)initWithContainer:(CKContainer *)container
{
    if (self = [super init]) {
        _container = container;
    }
    return self;
}

@end
