//
//  CAFEFoursquareLocation.m
//  CafeSociety
//
//  Created by Brian Drell on 9/18/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

#import "CAFEFoursquareLocation.h"

@implementation CAFEFoursquareLocation

+ (DDDObjectMap *)defaultObjectMap
{
    DDDObjectMap *map = [super defaultObjectMap];
    [map addField:@"formattedAddress" to:@"formattedAddress" block:^id(id object) {
        return object;
    } reverseBlock:^id(id object) {
        return object;
    } class:nil];
    return map;
}

- (CLLocation *)location
{
    if (self.lat && self.lng) {
        return [[CLLocation alloc] initWithLatitude:[self.lat doubleValue] longitude:[self.lng doubleValue]];
    }
    return nil;
}

@end
