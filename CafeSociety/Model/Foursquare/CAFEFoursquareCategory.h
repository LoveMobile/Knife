//
//  CAFEFoursquareCategory.h
//  CafeSociety
//
//  Created by Brian Drell on 9/17/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

@import Foundation;
#import "DDDModelObject.h"

@interface CAFEFoursquareIcon : DDDModelObject

@property (nonatomic, copy) NSString *prefix;
@property (nonatomic, copy) NSString *suffix;

@end

@interface CAFEFoursquareCategory : DDDModelObject

@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pluralName;
@property (nonatomic, copy) NSString *shortName;
@property (nonatomic, copy) NSNumber *primary;
@property (nonatomic, strong) CAFEFoursquareIcon *icon;

@end
