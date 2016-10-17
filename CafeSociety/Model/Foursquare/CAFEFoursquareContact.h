//
//  CAFEFoursquareContact.h
//  CafeSociety
//
//  Created by Brian Drell on 9/18/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

@import Foundation;
#import "DDDModelObject.h"

@interface CAFEFoursquareContact : DDDModelObject

@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *formattedPhone;
@property (nonatomic, copy) NSString *twitter;

@end
