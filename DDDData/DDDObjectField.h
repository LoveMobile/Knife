//
//  DDDObjectField.h
//  DDDLibraries
//
//  Created by Brian Drell on 12/14/13.
//  Copyright (c) 2013 Brian Drell. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^DDDDataTransformBlock)(id object);

@class DDDObjectMap;

@interface DDDObjectField : NSObject

@property (nonatomic, copy) NSString *fromFieldName;
@property (nonatomic, copy) NSString *toFieldName;
@property (nonatomic, copy) DDDDataTransformBlock block;
@property (nonatomic, copy) DDDDataTransformBlock reverseBlock;
@property (nonatomic, strong) Class objectClass;
@property (nonatomic, strong) DDDObjectMap *objectMap;
@property (nonatomic, assign) BOOL isArrayField;

- (instancetype)initWithFromFieldName:(NSString *)fromFieldName toFieldName:(NSString *)toFieldName transformBlock:(DDDDataTransformBlock)transformBlock reverseBlock:(DDDDataTransformBlock)reverseBlock class:(__unsafe_unretained Class)objectClass;

@end

