//
//  DDDObjectField.m
//  DDDLibraries
//
//  Created by Brian Drell on 12/14/13.
//  Copyright (c) 2013 Brian Drell. All rights reserved.
//

#import "DDDObjectField.h"
#import "DDDModelObject.h"
@import ObjectiveC;

@implementation DDDObjectField

- (instancetype)initWithFromFieldName:(NSString *)fromFieldName toFieldName:(NSString *)toFieldName transformBlock:(DDDDataTransformBlock)transformBlock reverseBlock:(DDDDataTransformBlock)reverseBlock class:(__unsafe_unretained Class)objectClass
{
    if (self = [super init]) {
        _fromFieldName = fromFieldName;
        _toFieldName = toFieldName;
        _block = transformBlock;
        _reverseBlock = reverseBlock;
        _objectClass = objectClass;
    }
    return self;
}

@end
