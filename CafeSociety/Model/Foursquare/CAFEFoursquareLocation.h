//
//  CAFEFoursquareLocation.h
//  CafeSociety
//
//  Created by Brian Drell on 9/18/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import "DDDModelObject.h"

@interface CAFEFoursquareLocation : DDDModelObject

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *cc;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *crossStreet;
@property (nonatomic, copy) NSNumber *distance;
@property (nonatomic, copy) NSArray *formattedAddress;
@property (nonatomic, copy) NSNumber *lat;
@property (nonatomic, copy) NSNumber *lng;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, copy) NSNumber *postalCode;
@property (nonatomic, copy) NSString *state;

@end
