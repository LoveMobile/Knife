//
//  DDDObjectMap.m
//  DDDLibraries
//
//  Created by Brian Drell on 12/14/13.
//  Copyright (c) 2013 Brian Drell. All rights reserved.
//

#import "DDDObjectMap.h"

@interface DDDObjectMap ()

@property (nonatomic, strong) NSMutableDictionary *fromToMap;
@property (nonatomic, strong) NSMutableDictionary *toFromMap;
@property (nonatomic, strong) NSMutableDictionary *objectFields;
@property (nonatomic, strong) Class objectClass;

@end

@implementation DDDObjectMap

- (instancetype)init
{
    if (self = [super init]) {
        _fromToMap = [[NSMutableDictionary alloc] init];
        _toFromMap = [[NSMutableDictionary alloc] init];
        _objectFields = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithClass:(__unsafe_unretained Class)objectClass
{
    if (self = [self init]) {
        _objectClass = objectClass;
    }
    return self;
}

- (void)addField:(NSString *)fromField to:(NSString *)toField class:(__unsafe_unretained Class)objectClass
{
    [self mapField:fromField toField:toField];
    DDDObjectField *objectField = [[DDDObjectField alloc] initWithFromFieldName:fromField toFieldName:toField transformBlock:nil reverseBlock:nil class:objectClass];
    self.objectFields[toField] = objectField;
}

- (void)addField:(NSString *)fromField to:(NSString *)toField block:(DDDDataTransformBlock)block class:(__unsafe_unretained Class)objectClass
{
    [self mapField:fromField toField:toField];
    DDDObjectField *objectField = [[DDDObjectField alloc] initWithFromFieldName:fromField toFieldName:toField transformBlock:block reverseBlock:nil class:objectClass];
    self.objectFields[toField] = objectField;
}

- (void)addField:(NSString *)fromField to:(NSString *)toField block:(DDDDataTransformBlock)block reverseBlock:(DDDDataTransformBlock)reverseBlock class:(__unsafe_unretained Class)objectClass
{
    [self mapField:fromField toField:toField];
    DDDObjectField *objectField = [[DDDObjectField alloc] initWithFromFieldName:fromField toFieldName:toField transformBlock:block reverseBlock:reverseBlock class:objectClass];
    self.objectFields[toField] = objectField;
}

#pragma mark - Array field

- (void)addArrayField:(NSString *)fromField to:(NSString *)toField class:(__unsafe_unretained Class)objectClass
{
    [self mapField:fromField toField:toField];
    DDDObjectField *objectField = [[DDDObjectField alloc] initWithFromFieldName:fromField toFieldName:toField transformBlock:nil reverseBlock:nil class:objectClass];
    objectField.isArrayField = YES;
    self.objectFields[toField] = objectField;
}

- (void)addArrayField:(NSString *)fromField to:(NSString *)toField block:(DDDDataTransformBlock)block class:(__unsafe_unretained Class)objectClass
{
    [self mapField:fromField toField:toField];
    DDDObjectField *objectField = [[DDDObjectField alloc] initWithFromFieldName:fromField toFieldName:toField transformBlock:block reverseBlock:nil class:objectClass];
    objectField.isArrayField = YES;
    self.objectFields[toField] = objectField;
}

- (void)addArrayField:(NSString *)fromField to:(NSString *)toField block:(DDDDataTransformBlock)block reverseBlock:(DDDDataTransformBlock)reverseBlock class:(__unsafe_unretained Class)objectClass
{
    [self mapField:fromField toField:toField];
    DDDObjectField *objectField = [[DDDObjectField alloc] initWithFromFieldName:fromField toFieldName:toField transformBlock:block reverseBlock:reverseBlock class:objectClass];
    objectField.isArrayField = YES;
    self.objectFields[toField] = objectField;
}

#pragma mark - Specific field classes

- (void)addDateField:(NSString *)fromField to:(NSString *)toField
{
    [self addField:fromField to:toField block:^id(id object) {
        if ([object isKindOfClass:[NSNull class]]) {
            return nil;
        }
        NSTimeInterval num = [object doubleValue];
        return [NSDate dateWithTimeIntervalSince1970:num];
    } reverseBlock:^id(id object) {
        NSDate *date = object;
        NSTimeInterval interval = [date timeIntervalSince1970];
        if (interval < 1) return [NSNull null];
        return @([date timeIntervalSince1970]);
    } class:[NSDate class]];
}

- (void)addURLField:(NSString *)fromField to:(NSString *)toField
{
    [self addField:fromField to:toField block:^id(id object) {
        if ([object isKindOfClass:[NSNull class]]) {
            return nil;
        }
        NSString *urlString = object;
        return [NSURL URLWithString:urlString];
    } reverseBlock:^id(id object) {
        NSURL *url = object;
        if (url)
            return [url.absoluteString copy];
        return [NSNull null];
    } class:[NSURL class]];
}

#pragma mark - Helpers

- (void)mapField:(NSString *)field1 toField:(NSString *)field2
{
    self.fromToMap[field1] = field2;
    self.toFromMap[field2] = field1;
}

- (DDDObjectField *)fieldForKey:(NSString *)key
{
    NSString *newKey = self.toFromMap[key];
    DDDObjectField *field = self.objectFields[newKey];
    return field;
}

- (DDDObjectField *)fieldForPropertyName:(NSString *)propertyName
{
    DDDObjectField *field = self.objectFields[propertyName];
    return field;
}

@end
