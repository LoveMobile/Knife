//
//  CAFEFoursquareDataController.m
//  CafeSociety
//
//  Created by Brian Drell on 9/16/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

@import CoreLocation;
#import "CAFEFoursquareDataController.h"
#import "CAFEFoursquareVenue.h"

static NSString *const kFoursquareAPISearchBaseURL = @"https://api.foursquare.com/v2/venues/search";
static NSString *const kFoursquareAPIVenueBaseURL = @"https://api.foursquare.com/v2/venues/";

static NSString *const kCAFEClientID = @"TZMIPVN25LXTXPRXNN3PY2BQI4SOVIVKMSPWHMLLKU34TF0Y";
static NSString *const kCAFEClientSecret = @"WN3P2CQETGJT44LNGBSZD0TRD2GYSHRLRM5ZQPJZSDQVVLPU";

@interface CAFEFoursquareDataController () <CLLocationManagerDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation CAFEFoursquareDataController

- (instancetype)init
{
    if (self = [super init]) {
        _session = [NSURLSession sharedSession];
    }
    return self;
}

- (void)getFoursquareVenueWithID:(NSString *)foursquareID completion:(CAFEFoursquareManagerVenueCompletionBlock)block
{
    NSParameterAssert(block != nil);
    NSURL *url = [self urlForVenueFetchWithID:foursquareID];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *parseError;
        CAFEFoursquareVenue *venue = [[CAFEFoursquareVenue alloc] initWithJSONData:data rootKeyPath:@"response.venue" error:&parseError];
        if (parseError) venue = nil;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(venue, error);
        }];
    }];
    [dataTask resume];
}

- (void)getFoursquareVenueWithName:(NSString *)venueName completion:(CAFEFoursquareManagerVenueCompletionBlock)block
{
    NSParameterAssert(block != nil);
    NSURL *url = [self urlForVenueSearchWithQueryString:venueName intent:@"browse" near:nil location:nil radius:20000];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *parseError;
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        NSArray *venues = [(NSDictionary *)object valueForKeyPath:@"response.venues"];
        NSDictionary *dict = [venues firstObject];
        if (dict && [dict isKindOfClass:[NSDictionary class]]) {
            CAFEFoursquareVenue *venue = [[CAFEFoursquareVenue alloc] initWithDictionary:dict];
            if (venue) {
                object = venue;
            } else {
                object = nil;
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(object, error);
        }];
    }];
    [dataTask resume];
}

- (void)getFoursquareVenuesInDallasWithCompletion:(CAFEFoursquareManagerVenueCollectionCompletionBlock)block
{
    NSParameterAssert(block != nil);
    NSURL *url = [self urlForVenueSearchWithQueryString:nil intent:@"browse" near:@"Dallas, TX" location:nil radius:20000];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *parseError;
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        NSArray *venueDicts = [(NSDictionary *)object valueForKeyPath:@"response.venues"];
        NSMutableArray *venues = [@[] mutableCopy];
        for (NSDictionary *dict in venueDicts) {
            CAFEFoursquareVenue *venue = [[CAFEFoursquareVenue alloc] initWithDictionary:dict];
            if (venue) {
                [venues addObject:venue];
            }
        }
        object = [venues count] ? venues : nil;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(object, error);
        }];
    }];
    [dataTask resume];
}

- (NSURL *)urlForVenueSearchWithQueryString:(NSString *)queryString intent:(NSString *)intent near:(NSString *)cityName location:(CLLocation *)location radius:(NSInteger)radius
{
    NSMutableString *urlString = [kFoursquareAPISearchBaseURL mutableCopy];
    [urlString appendFormat:@"?client_id=%@&client_secret=%@", kCAFEClientID, kCAFEClientSecret];
    if ([queryString length])
        [urlString appendFormat:@"&query=%@", queryString];
    if (![intent length])
        intent = @"match";
    [urlString appendFormat:@"&intent=%@", intent];
    if (!location)
        location = [[CLLocation alloc] initWithLatitude:32.7758 longitude:-96.7967];
    if (![cityName length]) {
        [urlString appendFormat:@"&ll=%@,%@", @(location.coordinate.latitude), @(location.coordinate.longitude)];
    } else {
        [urlString appendFormat:@"&near=%@", cityName];
    }
    [urlString appendString:@"&v=20140901"];
    if (!radius)
        radius = 20000;
    [urlString appendFormat:@"&radius=%@", @(radius)];
    urlString = [[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)urlForVenueFetchWithID:(NSString *)venueID
{
    NSMutableString *urlString = [kFoursquareAPIVenueBaseURL mutableCopy];
    [urlString appendString:venueID];
    [urlString appendFormat:@"?client_id=%@&client_secret=%@", kCAFEClientID, kCAFEClientSecret];
    [urlString appendString:@"&v=20140901"];
    urlString = [[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    return [NSURL URLWithString:urlString];
}

@end
