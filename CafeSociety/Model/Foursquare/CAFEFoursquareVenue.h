//
//  CAFEFoursquareVenue.h
//  CafeSociety
//
//  Created by Brian Drell on 9/17/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

@import Foundation;
#import "CAFEFoursquareContact.h"
#import "CAFEFoursquareLocation.h"

@interface CAFEFoursquareVenue : DDDModelObject

@property (nonatomic, copy) NSString *venueID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *venueDescription;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) CAFEFoursquareContact *contact;
@property (nonatomic, strong) CAFEFoursquareLocation *location;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *canonicalURL;
@property (nonatomic, strong) NSURL *shortURL;
@property (nonatomic, copy) NSString *timeZone;
@property (nonatomic, copy) NSNumber *verified;

// TODO: Create these, detail fields
//@property (nonatomic, strong) CAFEFoursquareHours *hours;
//@property (nonatomic, strong) CAFEFoursquareMenu *menu;

@end

/*
hours =             {
    isOpen = 0;
    status = "Closed until 11:00am";
    timeframes =                 (
                                  {
                                      days = "Mon\U2013Thu";
                                      includesToday = 1;
                                      open =                         (
                                                                      {
                                                                          renderedTime = "11:00 AM\U20132:00 PM";
                                                                      }
                                                                      );
                                      segments =                         (
                                      );
                                  },
                                  {
                                      days = "Fri\U2013Sat";
                                      open =                         (
                                                                      {
                                                                          renderedTime = "11:00 AM\U20132:00 PM";
                                                                      },
                                                                      {
                                                                          renderedTime = "6:00 PM\U201310:00 PM";
                                                                      }
                                                                      );
                                      segments =                         (
                                      );
                                  }
                                  );
};
 */
/*
menu =             {
    anchor = "View Menu";
    label = Menu;
    mobileUrl = "https://foursquare.com/v/5234b6c711d25ed09764714f/device_menu";
    type = Menu;
    url = "https://foursquare.com/v/monkey-king-noodle-co/5234b6c711d25ed09764714f/menu";
};
 */

