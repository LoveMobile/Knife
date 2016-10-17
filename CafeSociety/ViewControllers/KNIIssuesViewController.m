//
//  KNIIssuesViewController.m
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNIIssuesViewController.h"
#import "KNIAttributedStringFactory.h"
#import "KNIPagingCollectionViewFlowLayout.h"
#import "KNIIssueCollectionViewCell.h"
#import "KNICloudKitController.h"
#import "KNIIssueDetailViewController.h"
#import "KNICellExpandingTransitionAnimator.h"
#import "KNIInfoCollectionViewController.h"
#import "KNILaunchViewController.h"
#import "KNITabBarSlideTransitionAnimator.h"

static NSString *const kIssueCellReuseIdentifier = @"IssueCollectionViewCellReuseIdentifier";

@interface KNIIssuesViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) KNICloudKitController *cloudKitController;

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet KNIPagingCollectionViewFlowLayout *layout;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *divHeightConstraints;

@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *issueLabel;

@property (nonatomic, strong) NSArray *issues;

@property (nonatomic, strong) KNIIssue *currentIssue;

@property (nonatomic, strong) KNIDelegatingTransitionAnimator *transitionAnimator;

@property (nonatomic, strong) UIView *transitioningCell;
@property (nonatomic) CGRect startingCellFrame;

@property (nonatomic, strong) KNIIssueDetailViewController *currentDetailViewController;
@property (nonatomic, strong) UIView *currentDetailView;

@property (nonatomic, strong) KNILaunchViewController *launchViewController;
@property (nonatomic) BOOL didJustLaunch;
@property (nonatomic, strong) KNITabBarSlideTransitionAnimator *tabBarTransitionAnimator;

@property (nonatomic, weak) id errorListener;
@property (nonatomic, weak) id appBackgroundListener;
@property (nonatomic, weak) id appForegroundListener;
@property (nonatomic) BOOL presentedOnboarding;

@end

@implementation KNIIssuesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[Mixpanel sharedInstance] track:@"AppDidLaunch" properties:@{@"Date" : [NSDate date]}];
    
    self.tabBarTransitionAnimator = [[KNITabBarSlideTransitionAnimator alloc] initWithTabBarController:self.tabBarController];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    
    self.didJustLaunch = YES;
    
    self.launchViewController = [[KNILaunchViewController alloc] init];
    [self addChildViewController:self.launchViewController];
    self.launchViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.launchViewController.view];
    [self.launchViewController didMoveToParentViewController:self];
    
    self.navigationController.delegate = self;
    
    [self fetchIssues];
    
    CGSize itemSize = [[UIScreen mainScreen] bounds].size;
    itemSize.height -= 90;
    itemSize.height -= 36;
    itemSize.height -= 32*2;
    // Use this for when we have a tab bar.
//    itemSize.height -= (190 + 50);
    itemSize.width -= 64;
    self.layout.itemSize = itemSize;
    
    self.volumeLabel.attributedText = nil;// = [KNIAttributedStringFactory trackedHeaderText:@"VOL 1"];
    self.issueLabel.attributedText = nil;// = [KNIAttributedStringFactory trackedHeaderText:@"NOV"];
    
    for (NSLayoutConstraint *constraint in self.divHeightConstraints) {
        constraint.constant = 1. / [[UIScreen mainScreen] scale];
    }
    
    [self setTabBarHidden:YES animated:NO];
    
    self.tabBarItem.title = nil;
    
    __weak __typeof__(self) weakSelf = self;
    self.errorListener = [[NSNotificationCenter defaultCenter] addObserverForName:KNICloudKitControllerDidErrorOutNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSError *error = [note object];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"CloudKit Error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    }];
    
    self.appBackgroundListener = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf startForegroundListener];
    }];
}

- (void)startForegroundListener
{
    __weak __typeof__(self) weakSelf = self;
    self.appForegroundListener = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf fetchIssues];
        [[NSNotificationCenter defaultCenter] removeObserver:weakSelf.appForegroundListener];
    }];
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    CGSize tabBarSize = self.tabBarController.tabBar.frame.size;
    CGRect tabBarFrame;
    if (hidden) {
        tabBarFrame = CGRectMake(0, CGRectGetMaxY(self.view.bounds), tabBarSize.width, tabBarSize.height);
    } else {
        tabBarFrame = CGRectMake(0, CGRectGetMaxY(self.view.bounds) - tabBarSize.height, tabBarSize.width, tabBarSize.height);
    }
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tabBarController.tabBar.frame = tabBarFrame;
        }];
    } else {
        self.tabBarController.tabBar.frame = tabBarFrame;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentDetailViewController = nil;
        self.transitionAnimator = nil;
        self.currentDetailView = nil;
    });
    if (!self.didJustLaunch)
    {
        [self setTabBarHidden:NO animated:YES];
    }
    self.didJustLaunch = NO;
    
    [self presentOnboardingIfNeeded];
}

- (void)presentOnboardingIfNeeded
{
    BOOL doNotPresentOnboarding = [[NSUserDefaults standardUserDefaults] boolForKey:KNIAppDidLaunchKey];
    if (!doNotPresentOnboarding && !self.presentedOnboarding)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.presentedOnboarding = YES;
            KNIInfoCollectionViewController *infoViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:NSStringFromClass([KNIInfoCollectionViewController class])];
            [self presentViewController:infoViewController animated:YES completion:nil];
        });
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.launchViewController.finalLabelFrame = self.titleImageView.frame;
}

- (void)animateLaunchScreenOffIfNeeded
{
    if (self.launchViewController)
    {
        __weak __typeof__(self) weakSelf = self;
        [self.launchViewController animateDismissalWithCompletion:^{
            [weakSelf.launchViewController willMoveToParentViewController:nil];
            [weakSelf.launchViewController.view removeFromSuperview];
            [weakSelf.launchViewController removeFromParentViewController];
            weakSelf.launchViewController = nil;
            
            [weakSelf setTabBarHidden:NO animated:YES];
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setCurrentIssue:(KNIIssue *)currentIssue
{
    if ((_currentIssue && _currentIssue == currentIssue) || !currentIssue) return;
    _currentIssue = currentIssue;
    
    if (currentIssue)
    {
        [[Mixpanel sharedInstance] track:@"UserDidScrollToIssue" properties:@{@"Vol" : currentIssue.volume, @"No" : currentIssue.number, @"Title" : currentIssue.name, @"UserRecordID" : self.cloudKitController.userIdentifier}];
    }
    
    [UIView animateWithDuration:0 animations:^{
        self.volumeLabel.alpha = 0;
        self.issueLabel.alpha = 0;
    } completion:^(BOOL finished) {
        self.volumeLabel.attributedText = [KNIAttributedStringFactory trackedHeaderText:[NSString stringWithFormat:@"VOL %@", _currentIssue.volume]];
        self.issueLabel.attributedText = [KNIAttributedStringFactory trackedHeaderText:[NSString stringWithFormat:@"NO %@", _currentIssue.number]];
        [UIView animateWithDuration:0 animations:^{
            self.volumeLabel.alpha = 1;
            self.issueLabel.alpha = 1;
        }];
    }];
}

- (void)setIssues:(NSArray *)issues
{
    _issues = issues;
    [self setCurrentIssue:[issues firstObject]];
    [self.collectionView reloadData];
}

- (void)fetchIssues
{
    __weak __typeof__(self) weakSelf = self;
    self.cloudKitController = [KNICloudKitController sharedInstance];
    [self.cloudKitController fetchAllIssuesWithCompletion:^(NSArray *issues, NSError *error) {
        if (error) {
            [self presentAlertForError:error];
            if (!issues) return;
        }
        __block NSInteger issueCount = [issues count];
        weakSelf.issues = issues;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf animateLaunchScreenOffIfNeeded];
        });
        for (KNIIssue *issue in issues) {
            [issue downloadImageWithCompletion:^(UIImage *image) {
                
            }];
            [issue fetchItemsWithCompletion:^(NSError *error) {
                issueCount--;
                
            }];
        }
    }];
}

- (void)presentAlertForError:(NSError *)error
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"CloudKit Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.issues count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KNIIssueCollectionViewCell *cell = (KNIIssueCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kIssueCellReuseIdentifier forIndexPath:indexPath];
    [cell configureWithIssue:self.issues[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    KNIIssue *issue = self.issues[indexPath.item];
    [[Mixpanel sharedInstance] track:@"UserDidTapIssue" properties:@{@"Vol" : issue.volume, @"No" : issue.number, @"Title" : issue.name, @"UserRecordID" : self.cloudKitController.userIdentifier}];
    KNIIssueDetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([KNIIssueDetailViewController class])];
    detailVC.cloudKitController = self.cloudKitController;
    self.currentDetailViewController = detailVC;
    detailVC.issue = issue;
    KNIIssueCollectionViewCell *cell = (KNIIssueCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    self.transitioningCell = [KNIIssueCollectionViewCell clonedCell:cell];
    self.startingCellFrame = [self.collectionView convertRect:cell.frame toView:self.view];
    
    detailVC.image = cell.image;
    self.transitionAnimator = [[KNIDelegatingTransitionAnimator alloc] init];
    detailVC.transitioningDelegate = self;
    [self setTabBarHidden:YES animated:YES];
    [self presentViewController:detailVC animated:YES completion:^{
        
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.issues) return;
    CGFloat pageHeight = self.layout.itemSize.height + self.layout.minimumInteritemSpacing;
    NSInteger currentPage = (NSInteger)roundf(scrollView.contentOffset.y / pageHeight);
    currentPage = MAX(currentPage, 0);
    currentPage = MIN(currentPage, self.issues.count - 1);
    KNIIssue *issue = self.issues[currentPage];
    [self setCurrentIssue:issue];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.transitionAnimator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.transitionAnimator;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (fromVC == self || toVC == self)
    {
        return self.transitionAnimator;
    }
    return nil;
}

#pragma mark - KNITransitioningViewController

- (void)animatePresentationWithDuration:(NSTimeInterval)duration isFirstViewController:(BOOL)isFirst completion:(void (^)())block
{
    self.transitioningCell.frame = self.startingCellFrame;
    self.transitioningCell.alpha = 0;
    [self.view insertSubview:self.transitioningCell aboveSubview:self.collectionView];
    [UIView animateWithDuration:0.1 animations:^{
        self.transitioningCell.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transitioningCell.frame = self.view.bounds;
        } completion:^(BOOL finished) {
            block();
            
            dispatch_after(2*duration, dispatch_get_main_queue(), ^{
                self.currentDetailView = self.currentDetailViewController.view;
            });
        }];
    }];
}

- (void)animateDismissalWithDuration:(NSTimeInterval)duration isFirstViewController:(BOOL)isFirst completion:(void (^)())block
{
    [UIView animateWithDuration:duration-0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transitioningCell.frame = self.startingCellFrame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.transitioningCell.alpha = 0;
        } completion:^(BOOL finished) {
            [self.transitioningCell removeFromSuperview];
            self.transitioningCell = nil;
            block();
        }];
    }];
}

@end
