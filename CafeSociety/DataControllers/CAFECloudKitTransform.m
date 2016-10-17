//
//  CAFECloudKitTransform.m
//  CafeSociety
//
//  Created by Brian Drell on 9/18/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

#import "CAFECloudKitTransform.h"

@implementation CAFECloudKitTransform

+ (void)populateRecord:(CKRecord *)record fromDictionary:(NSDictionary *)dictionary
{
    
}

+ (NSDictionary *)dictionaryFromRecord:(CKRecord *)record
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (id key in [record allKeys]) {
        id value = record[key];
        if ([value isKindOfClass:[CKRecord class]]) {
            NSDictionary *dict = [self dictionaryFromRecord:value];
            dictionary[key] = dict;
        } else {
            dictionary[key] = value;
        }
    }
    return [dictionary copy];
}

@end
