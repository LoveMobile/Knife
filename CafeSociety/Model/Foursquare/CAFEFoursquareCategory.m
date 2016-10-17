//
//  CAFEFoursquareCategory.m
//  CafeSociety
//
//  Created by Brian Drell on 9/17/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

#import "CAFEFoursquareCategory.h"

@implementation CAFEFoursquareIcon

@end

@implementation CAFEFoursquareCategory

+ (DDDObjectMap *)defaultObjectMap
{
    DDDObjectMap *map = [super defaultObjectMap];
    [map addField:@"id" to:@"categoryID" class:nil];
    [map addField:@"icon" to:@"icon" class:[CAFEFoursquareIcon class]];
    return map;
}

@end
