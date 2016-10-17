//
//  DDDObjectMap.h
//  DDDLibraries
//
//  Created by Brian Drell on 12/14/13.
//  Copyright (c) 2013 Brian Drell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDDObjectField.h"

@interface DDDObjectMap : NSObject

// Fields for DDDModelObjects (and subclasses), NSStrings, and NSNumbers
// Other classes can be accomodated by using the forward and reverse transform
// blocks.
- (void)addField:(NSString *)fromField to:(NSString *)toField class:(__unsafe_unretained Class)objectClass;
- (void)addField:(NSString *)fromField to:(NSString *)toField block:(DDDDataTransformBlock)block class:(__unsafe_unretained Class)objectClass;
- (void)addField:(NSString *)fromField to:(NSString *)toField block:(DDDDataTransformBlock)block reverseBlock:(DDDDataTransformBlock)reverseBlock class:(__unsafe_unretained Class)objectClass;

// Array fields, like those above
- (void)addArrayField:(NSString *)fromField to:(NSString *)toField class:(__unsafe_unretained Class)objectClass;
- (void)addArrayField:(NSString *)fromField to:(NSString *)toField block:(DDDDataTransformBlock)block class:(__unsafe_unretained Class)objectClass;
- (void)addArrayField:(NSString *)fromField to:(NSString *)toField block:(DDDDataTransformBlock)block reverseBlock:(DDDDataTransformBlock)reverseBlock class:(__unsafe_unretained Class)objectClass;

// Convenience methods for creating some commonly used object fields
- (void)addDateField:(NSString *)fromField to:(NSString *)toField;
- (void)addURLField:(NSString *)fromField to:(NSString *)toField;

- (DDDObjectField *)fieldForKey:(NSString *)key;
- (DDDObjectField *)fieldForPropertyName:(NSString *)propertyName;

@end
