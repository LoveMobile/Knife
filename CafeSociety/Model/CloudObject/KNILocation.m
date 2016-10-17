//
//  KNILocation.m
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNILocation.h"

@interface KNILocation ()

@property (nonatomic, strong) CKRecord *record;

@end

@implementation KNILocation

- (instancetype)initWithRecord:(CKRecord *)record
{
    if (self = [super init]) {
        _record = record;
    }
    return self;
}

- (CLLocation *)mapLocation
{
    return self.record[@"mapLocation"];
}

- (NSString *)name
{
    if (self.record[@"name"])
    {
        return self.record[@"name"];
    }
    return @"";
}

- (NSString *)streetAddress
{
    return self.record[@"streetAddress"];
}

- (NSString *)city
{
    return self.record[@"city"];
}

- (NSString *)state
{
    return self.record[@"state"];
}

- (NSString *)zipCode
{
    return self.record[@"zipCode"];
}

- (NSString *)phone
{
    return self.record[@"phone"];
}

- (NSURL *)website
{
    return [NSURL URLWithString:self.record[@"website"]];
}

- (NSString *)tips
{
    return self.record[@"tips"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ mapLocation: %@\rname: %@\rAddress: %@; %@, %@ %@\rphone: %@\rtips: %@ }", self.mapLocation, self.name, self.streetAddress, self.city, self.state, self.zipCode, self.phone, self.tips];
}

#pragma mark - MKMapAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return self.mapLocation.coordinate;
}

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.streetAddress;
}

@end
