//
//  ViewController.m
//  CafeSociety
//
//  Created by Brian Drell on 9/16/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

#import "CAFERootViewController.h"
#import "CAFEFoursquareDataController.h"
#import "CAFEFoursquareVenue.h"
#import "KNICloudKitController.h"
#import "KNIRecommendedItem.h"
#import "KNIRecommendedItemDetailViewController.h"

@interface CAFERootViewController ()

@property (nonatomic, strong) CAFEFoursquareDataController *foursquareDataController;
@property (nonatomic, strong) KNICloudKitController *cloudKitController;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *issues;

@end

@implementation CAFERootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak __typeof__(self) weakSelf = self;
    
    self.cloudKitController = [[KNICloudKitController alloc] init];
    [self.cloudKitController fetchAllIssuesWithCompletion:^(NSArray *issues, NSError *error) {
        __block NSInteger issueCount = [issues count];
        weakSelf.issues = issues;
        for (KNIIssue *issue in issues) {
            [issue fetchItemsWithCompletion:^(NSError *error) {
                issueCount--;
                __block NSInteger itemCount = [issue.items count];
                for (KNIRecommendedItem *item in issue.items) {
                    [item fetchDetailWithCompletion:^(NSArray *errors) {
                        itemCount--;
                        if (itemCount <= 0 && issueCount <= 0)
                        {
                            [weakSelf performSegueWithIdentifier:@"PresentDetail" sender:nil];
                        }
                    }];
                }
            }];
        }
    }];
}

- (void)runFoursquareTests
{
    self.foursquareDataController = [[CAFEFoursquareDataController alloc] init];
    
    [self.foursquareDataController getFoursquareVenueWithName:@"Monkey King Noodle Co." completion:^(CAFEFoursquareVenue *venue, NSError *error) {
        NSLog(@"Venue: %@", venue);
    }];
    
    [self.foursquareDataController getFoursquareVenuesInDallasWithCompletion:^(NSArray *venues, NSError *error) {
        NSLog(@"Venues: %@", venues);
    }];
    
    NSString *monkeyKingVenueID = @"5234b6c711d25ed09764714f";
    [self.foursquareDataController getFoursquareVenueWithID:monkeyKingVenueID completion:^(CAFEFoursquareVenue *venue, NSError *error) {
        NSLog(@"Venue DETAIL: %@\nDETAIL_END", venue);
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.items = [[self.issues firstObject] items];
    self.items = [self.items sortedArrayUsingComparator:^NSComparisonResult(KNIRecommendedItem *item1, KNIRecommendedItem *item2) {
        return [item1.createdDate compare:item2.createdDate];
    }];
    id vc = [segue destinationViewController];
    if ([vc isKindOfClass:[KNIRecommendedItemDetailViewController class]]) {
        [vc setItem:[self.items lastObject]];
    }
}

@end
