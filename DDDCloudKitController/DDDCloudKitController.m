//
//  DDDCloudKitController.m
//  CafeSociety
//
//  Created by Brian Drell on 9/18/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

#import "DDDCloudKitController.h"

@interface DDDCloudKitController ()

@property (nonatomic, strong) CKContainer *container;
@property (nonatomic, strong) CKDatabase *publicDatabase;
@property (nonatomic, strong) CKDatabase *userDatabase;

@property (nonatomic, strong) CKRecord *userRecord;

@end

@implementation DDDCloudKitController

- (instancetype)init
{
    if (self = [super init]) {
        _container = [CKContainer defaultContainer];
        _publicDatabase = [_container publicCloudDatabase];
        _userDatabase = [_container privateCloudDatabase];
    }
    return self;
}

@end
