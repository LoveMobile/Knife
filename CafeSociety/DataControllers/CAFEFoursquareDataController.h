//
//  CAFEFoursquareDataController.h
//  CafeSociety
//
//  Created by Brian Drell on 9/16/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

@import UIKit;

@class CAFEFoursquareVenue;

typedef void(^CAFEFoursquareManagerVenueCompletionBlock)(CAFEFoursquareVenue *venue, NSError *error);
typedef void(^CAFEFoursquareManagerVenueCollectionCompletionBlock)(NSArray *venues, NSError *error);

@interface CAFEFoursquareDataController : NSObject

- (void)getFoursquareVenueWithID:(NSString *)foursquareID completion:(CAFEFoursquareManagerVenueCompletionBlock)block;
- (void)getFoursquareVenueWithName:(NSString *)venueName completion:(CAFEFoursquareManagerVenueCompletionBlock)block;
- (void)getFoursquareVenuesInDallasWithCompletion:(CAFEFoursquareManagerVenueCollectionCompletionBlock)block;

@end
