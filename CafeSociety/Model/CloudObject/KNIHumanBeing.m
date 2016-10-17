//
//  KNIHumanBeing.m
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNIHumanBeing.h"

@interface KNIHumanBeing ()

@property (nonatomic, strong) CKRecord *record;

@end

@implementation KNIHumanBeing

- (instancetype)initWithRecord:(CKRecord *)record
{
    if (self = [super init]) {
        _record = record;
    }
    return self;
}

- (NSString *)name
{
    return self.record[@"name"];
}

- (NSString *)bio
{
    return self.record[@"bio"];
}

- (NSURL *)avatarURL
{
    CKAsset *asset = self.record[@"avatar"];
    return asset.fileURL;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{name: %@\rbio: %@\ravatarURL: %@}", self.name, self.bio, self.avatarURL];
}

@end
