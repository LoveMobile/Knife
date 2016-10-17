//
//  KNIItemUpvoteListViewController.m
//  The Knife
//
//  Created by Brian Drell on 2/22/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import "KNIItemUpvoteListViewController.h"
#import "KNICloudKitController.h"
#import "KNIRecommendedItem.h"
#import "KNIAttributedStringFactory.h"
#import "KNIRecommendedItemDetailViewController.h"

static NSString *const kItemTableViewCellReuseIdentifier = @"RecommendedItemTableViewCellReuseIdentifier";

@interface KNIItemUpvoteListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *recommendedItems;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *divHeightConstraints;

@end

@implementation KNIItemUpvoteListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[Mixpanel sharedInstance] track:@"UserDidOpenHotlist" properties:@{@"UserRecordID" : [[KNICloudKitController sharedInstance] userIdentifier]}];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    self.tableView.tableFooterView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
    for (NSLayoutConstraint *constraint in self.divHeightConstraints) {
        constraint.constant = 1. / [[UIScreen mainScreen] scale];
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    self.tableView.alpha = 0;
    
    self.recommendedItems = [[KNICloudKitController sharedInstance] recommendedItems];
    if (self.recommendedItems.count)
    {
        [self.tableView reloadData];
        self.tableView.alpha = 1;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[KNICloudKitController sharedInstance] updateAllRecommendedItems];
    
    __weak __typeof__(self) weakSelf = self;
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:KNICloudKitControllerDidUpdateRecommendedItemsListNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakSelf.recommendedItems = [[KNICloudKitController sharedInstance] recommendedItems];
        [weakSelf.tableView reloadData];
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }];
}

- (void)fetchAllDetailsForItems
{
    __block NSInteger count = self.recommendedItems.count;
    self.recommendedItems = [self.recommendedItems sortedArrayUsingComparator:^NSComparisonResult(KNIRecommendedItem *obj1, KNIRecommendedItem *obj2) {
        if (obj1.numberOfUpvotes > obj2.numberOfUpvotes) return NSOrderedAscending;
        else if (obj1.numberOfUpvotes < obj2.numberOfUpvotes)
        {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    for (KNIRecommendedItem *item in self.recommendedItems)
    {
        __weak __typeof__(self) weakSelf = self;
        [item fetchDetailWithCompletion:^(NSArray *errors) {
            if (!errors.count)
            {
                count--;
            }
            if (count <= 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    [UIView animateWithDuration:0.3 animations:^{
                        weakSelf.tableView.alpha = 1;
                    }];
                });
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recommendedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kItemTableViewCellReuseIdentifier];
    cell.textLabel.font = [UIFont kni_abrilFatFaceFontWithSize:22];
    cell.detailTextLabel.font = [UIFont kni_oxygenRegularFontWithSize:14];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];

    KNIRecommendedItem *item = self.recommendedItems[indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.attributedText = [KNIAttributedStringFactory trackedIssueSubheadlineText:item.location.name.uppercaseString];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"UpvoteButton"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didTapUpvoteButton:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 44, 44);
    button.tag = indexPath.row;
    NSString *userID = [[KNICloudKitController sharedInstance] userIdentifier];
    if ([item.upvotedUserIDs containsObject:userID])
    {
        button.enabled = NO;
    }
    cell.accessoryView = button;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    KNIRecommendedItem *item = self.recommendedItems[indexPath.row];
    __weak __typeof__(self) weakSelf = self;
    [item downloadImageWithCompletion:^(UIImage *image) {
        [[Mixpanel sharedInstance] track:@"UserEnteredItemFromHotlist" properties:@{@"Title" : item.title, @"UserRecordID" : [[KNICloudKitController sharedInstance] userIdentifier]}];
        KNIRecommendedItemDetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:NSStringFromClass([KNIRecommendedItemDetailViewController class])];
        detailVC.itemImage = image;
        detailVC.item = item;
        [weakSelf.navigationController pushViewController:detailVC animated:YES];
    }];
}

- (IBAction)didTapUpvoteButton:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    KNIRecommendedItem *item = self.recommendedItems[tag];
    NSMutableArray *userIDs = [item.upvotedUserIDs mutableCopy];
    if (!userIDs)
    {
        userIDs = [[NSMutableArray alloc] init];
    }
    NSString *userID = [[KNICloudKitController sharedInstance] userIdentifier];
    if (userID.length)
    {
        if ([userIDs containsObject:userID]) return;
        
        [[Mixpanel sharedInstance] track:@"UserDidTapUpvote" properties:@{@"Title" : item.title, @"UserRecordID" : userID}];
        
        [userIDs addObject:userID];
        item.upvotedUserIDs = [userIDs copy];
        NSLog(@"UPVOTE! : %@", item);
        sender.enabled = NO;
    }
}

@end
