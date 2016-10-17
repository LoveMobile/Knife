//
//  KNILocation.h
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

@import UIKit;
@import CloudKit;
@import MapKit;

@interface KNILocation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocation *mapLocation;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *streetAddress;
@property (nonatomic, readonly) NSString *city;
@property (nonatomic, readonly) NSString *state;
@property (nonatomic, readonly) NSString *zipCode;
@property (nonatomic, readonly) NSString *phone;
@property (nonatomic, readonly) NSURL *website;
@property (nonatomic, readonly) NSArray *tips;

- (instancetype)initWithRecord:(CKRecord *)record;

@end
