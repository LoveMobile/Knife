//
//  CAFECloudKitTransform.h
//  CafeSociety
//
//  Created by Brian Drell on 9/18/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

@import Foundation;
@import CloudKit;

@interface CAFECloudKitTransform : NSObject

+ (void)populateRecord:(CKRecord *)record fromDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)dictionaryFromRecord:(CKRecord *)record;

@end
