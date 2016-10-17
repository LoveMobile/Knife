//
//  DDDModelObject.m
//  DDDLibraries
//
//  Created by Brian Drell on 12/14/13.
//  Copyright (c) 2013 Brian Drell. All rights reserved.
//

@import ObjectiveC;
#import "DDDModelObject.h"

@implementation DDDModelObject

+ (DDDObjectMap *)defaultObjectMap
{
    DDDObjectMap *map = [[DDDObjectMap alloc] init];
    return map;
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        NSArray *allPropertyNames = [[self class] keysForObject:self];
        DDDObjectMap *map = [[self class] defaultObjectMap];
        for (NSString *propertyName in allPropertyNames)
        {
            DDDObjectField *objectField = [map fieldForPropertyName:propertyName];
            if (!objectField) {
                objectField = [[DDDObjectField alloc] initWithFromFieldName:propertyName toFieldName:propertyName transformBlock:nil reverseBlock:nil class:nil];
            }
            NSString *dictionaryKey = objectField.fromFieldName;
            if (objectField.block) {
                id dictObject = dictionary[dictionaryKey];
                id transformedObject = objectField.block(dictObject);
                [self setValue:transformedObject forKey:propertyName];
                continue;
            }
            id object = [[objectField.objectClass alloc] init];
            if ([object isKindOfClass:[DDDModelObject class]]
                && !objectField.isArrayField) {
                object = [[objectField.objectClass alloc] initWithDictionary:dictionary[dictionaryKey]];
                [self setValue:object forKey:propertyName];
            } else if ([object isKindOfClass:[DDDModelObject class]]
                     && objectField.isArrayField) {
                id arrayFromDictionary = dictionary[dictionaryKey];
                if (![arrayFromDictionary isKindOfClass:[NSArray class]]) {
                    continue;
                }
                NSMutableArray *array = [[NSMutableArray alloc] init];
                for (id subObject in (NSArray *)arrayFromDictionary) {
                    if (objectField.block) {
                        id newObject = objectField.block(subObject);
                        [array addObject:newObject];
                        continue;
                    }
                    id newObject = [[objectField.objectClass alloc] initWithDictionary:subObject];
                    if (newObject) {
                        [array addObject:newObject];
                    }
                }
                [self setValue:[array copy] forKey:propertyName];
            } else if (!object || [object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
                object = dictionary[dictionaryKey];
                if ([object isKindOfClass:[NSNumber class]]
                    || [object isKindOfClass:[NSString class]]) {
                    [self setValue:object forKey:propertyName];
                }
            }
        }
    }
    return self;
}

- (instancetype)initWithCKRecord:(CKRecord *)record
{
    if (self = [super init]) {
        self.ckRecordId = record.recordID;
        
        NSArray *allPropertyNames = [[self class] keysForObject:self];
        DDDObjectMap *map = [[self class] defaultObjectMap];
        for (NSString *propertyName in allPropertyNames)
        {
            DDDObjectField *objectField = [map fieldForPropertyName:propertyName];
            if (!objectField) {
                objectField = [[DDDObjectField alloc] initWithFromFieldName:propertyName toFieldName:propertyName transformBlock:nil reverseBlock:nil class:nil];
            }
            NSString *dictionaryKey = objectField.fromFieldName;
            if (objectField.block) {
                id dictObject = record[dictionaryKey];
                id transformedObject = objectField.block(dictObject);
                [self setValue:transformedObject forKey:propertyName];
                continue;
            }
            id object = [[objectField.objectClass alloc] init];
            if ([object isKindOfClass:[DDDModelObject class]]
                && !objectField.isArrayField) {
                object = [[objectField.objectClass alloc] initWithCKRecord:record[dictionaryKey]];
                [self setValue:object forKey:propertyName];
            } else if ([object isKindOfClass:[DDDModelObject class]]
                       && objectField.isArrayField) {
                id arrayFromDictionary = record[dictionaryKey];
                if (![arrayFromDictionary isKindOfClass:[NSArray class]]) {
                    continue;
                }
                NSMutableArray *array = [[NSMutableArray alloc] init];
                for (id subObject in (NSArray *)arrayFromDictionary) {
                    if (objectField.block) {
                        id newObject = objectField.block(subObject);
                        [array addObject:newObject];
                        continue;
                    }
                    id newObject = [[objectField.objectClass alloc] initWithDictionary:subObject];
                    if (newObject) {
                        [array addObject:newObject];
                    }
                }
                [self setValue:[array copy] forKey:propertyName];
            } else if (!object || [object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
                object = record[dictionaryKey];
                if ([object isKindOfClass:[NSNumber class]]
                    || [object isKindOfClass:[NSString class]]) {
                    [self setValue:object forKey:propertyName];
                }
            }
        }
    }
    return self;
}

- (instancetype)initWithJSONData:(NSData *)data rootKeyPath:(NSString *)rootKeyPath error:(NSError *__autoreleasing *)error
{
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        object = [object valueForKeyPath:rootKeyPath];
    }
    if (*error || ![object isKindOfClass:[NSDictionary class]]) {
        self = [super init];
        return self;
    }
    if (self = [self initWithDictionary:object]) {
        
    }
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSDictionary *dict = [aDecoder decodeObjectForKey:@"object"];
    self = [self initWithDictionary:dict];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSDictionary *serializedSelf = [self serializeToDictionary];
    [aCoder encodeObject:serializedSelf forKey:@"object"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    NSDictionary *serializedSelf = [self serializeToDictionary];
    id copy = [[[self class] alloc] initWithDictionary:serializedSelf];
    return copy;
}

#pragma mark - Serialization

- (NSDictionary *)serializeToDictionary
{
    return [self serializeToDictionaryInsertingNulls:NO];
}

- (NSDictionary *)serializeToDictionaryInsertingNulls:(BOOL)insertNulls
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSArray *allPropertyNames = [[self class] keysForObject:self];
    for (NSString *propertyName in allPropertyNames) {
        id object = [self valueForKey:propertyName];
        DDDObjectField *objectField = [[[self class] defaultObjectMap] fieldForPropertyName:propertyName];
        if (!objectField) {
            objectField = [[DDDObjectField alloc] initWithFromFieldName:propertyName toFieldName:propertyName transformBlock:nil reverseBlock:nil class:nil];
        }
        NSString *dictKey = objectField.fromFieldName;
        
        if (objectField.reverseBlock) {
            id transformedObject = objectField.reverseBlock(object);
            dictionary[dictKey] = transformedObject;
        } else if ([object isKindOfClass:[DDDModelObject class]]) {
            dictionary[dictKey] = [object serializeToDictionary];
        } else if ([object isKindOfClass:[NSArray class]]) {
            NSMutableArray *outArray = [[NSMutableArray alloc] initWithCapacity:[object count]];
            for (id obj in (NSArray *)object) {
                if (objectField.reverseBlock) {
                    id transformedObject = objectField.reverseBlock(obj);
                    [outArray addObject:transformedObject];
                    continue;
                }
                if ([obj isKindOfClass:[DDDModelObject class]]) {
                    [outArray addObject:[obj serializeToDictionary]];
                }
                else if ([obj isKindOfClass:[NSString class]]
                         || [obj isKindOfClass:[NSNumber class]]) {
                    [outArray addObject:[obj copy]];
                }
            }
            dictionary[dictKey] = [outArray copy];
        } else if ([object isKindOfClass:[NSString class]]
                   || [object isKindOfClass:[NSNumber class]]) {
            dictionary[dictKey] = object;
        } else if (!object) {
            if (insertNulls) {
                dictionary[dictKey] = [NSNull null];
            }
        }
    }
    return [dictionary copy];
}

- (CKRecord *)serializeToCKRecord
{
    CKRecord *record;
    if (self.ckRecordId) {
        record = [[CKRecord alloc] initWithRecordType:NSStringFromClass([self class]) recordID:self.ckRecordId];
    } else {
        record = [[CKRecord alloc] initWithRecordType:NSStringFromClass([self class])];
    }
    
    return record;
}

- (NSData *)serializeToJSONData
{
    NSDictionary *dict = [self serializeToDictionary];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (error) return nil;
    return data;
}

#pragma mark - Pretty print

- (NSString *)description
{
    NSString *superDescription = [super description];
    NSDictionary *dictionary = [self serializeToDictionary];
    NSString *description = [dictionary description];
    description = [description stringByReplacingOccurrencesOfString:@"\n" withString:@"\r"];
    return [NSString stringWithFormat:@"%@: %@", superDescription, description];
}

#pragma mark - Utility

+ (NSArray *)keysForObject:(id)object
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    unsigned int outCount;
    
    Class objectClass = [object class];
    
    objc_property_t *properties = class_copyPropertyList(objectClass, &outCount);
    for(unsigned int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            [keys addObject:propertyName];
        }
    }
    free(properties);
    return keys;
}

@end
