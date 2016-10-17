//
//  CAFEFoursquareVenue.m
//  CafeSociety
//
//  Created by Brian Drell on 9/17/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

#import "CAFEFoursquareVenue.h"
#import "CAFEFoursquareCategory.h"

@implementation CAFEFoursquareVenue

+ (DDDObjectMap *)defaultObjectMap
{
    DDDObjectMap *map = [super defaultObjectMap];
    [map addField:@"id" to:@"venueID" class:nil];
    [map addField:@"description" to:@"venueDescription" class:nil];
    [map addArrayField:@"categories" to:@"categories" class:[CAFEFoursquareCategory class]];
    [map addField:@"contact" to:@"contact" class:[CAFEFoursquareContact class]];
    [map addField:@"location" to:@"location" class:[CAFEFoursquareLocation class]];
    [map addURLField:@"url" to:@"url"];
    [map addURLField:@"canonicalUrl" to:@"canonicalURL"];
    [map addURLField:@"shortUrl" to:@"shortURL"];
    return map;
}

@end
