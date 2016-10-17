//
//  DDDModelObject.h
//  DDDLibraries
//
//  Created by Brian Drell on 12/14/13.
//  Copyright (c) 2013 Brian Drell. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CloudKit;
#import "DDDObjectMap.h"

@interface DDDModelObject : NSObject <NSCoding, NSCopying>

// Optional. If we init with a CKRecord, this will be set so we
//  can reserialize it with changes.
@property (nonatomic, copy) CKRecordID *ckRecordId;

+ (DDDObjectMap *)defaultObjectMap;

// Initialize with a JSON-compliant dictionary
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithCKRecord:(CKRecord *)record;

// Initialize with JSON data
- (instancetype)initWithJSONData:(NSData *)data rootKeyPath:(NSString *)rootKeyPath error:(NSError *__autoreleasing *)error;

// Serializes the object to a JSON-compliant dictionary
- (NSDictionary *)serializeToDictionary;

// Serializes to a CKRecord of a type derived from the class name
- (CKRecord *)serializeToCKRecord;

// Serializes to a JSON-compliant dictionary, inserting [NSNull null] into
//   the fields corresponding to empty properties
- (NSDictionary *)serializeToDictionaryInsertingNulls:(BOOL)insertNulls;

// Serializes directly to JSON data
- (NSData *)serializeToJSONData;

@end
