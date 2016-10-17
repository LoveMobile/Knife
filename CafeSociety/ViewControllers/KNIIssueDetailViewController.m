//
//  KNIIssueDetailViewController.m
//  TheKnife
//
//  Created by Brian Drell on 10/26/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNIIssueDetailViewController.h"
#import "KNICollapsingHeaderView.h"
#import "KNIAttributedStringFactory.h"
#import "DDDImageUtilities.h"
#import "KNIPagingCollectionViewFlowLayout.h"
#import "KNIIssueCollectionViewCell.h"
#import "KNIRecommendedItemDetailViewController.h"
#import "KNIDelegatingTransitionAnimator.h"
#import "KNICloudKitController.h"
#import "KNIOffsetAnimator.h"
#import "KNIFunFactory.h"
#import "KNIContainerViewController.h"

static NSString *const kItemCellReuseID = @"IssueCollectionViewCellReuseIdentifier";
static const CGFloat kDarkeningInset = 200;

@interface KNIIssueDetailViewController () <UIViewControllerTransitioningDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, KNITransitioningViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet KNICollapsingHeaderView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet UIView *headerDiv;
@property (nonatomic) BOOL animatingHeaderCollapse;
@property (nonatomic) BOOL animatingHeaderExpand;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UILabel *issueTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *issueSubtitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *volumeLabel;
@property (nonatomic, weak) IBOutlet UILabel *quotationLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIView *textBoxBackground;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *blurImageView;
@property (weak, nonatomic) IBOutlet UIView *vignette;

@property (weak, nonatomic) IBOutlet UICollectionView *itemCollectionView;
@property (weak, nonatomic) IBOutlet KNIPagingCollectionViewFlowLayout *itemCollectionViewLayout;

@property (nonatomic) CGPoint lastScrollViewContentOffset;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *divHeightConstraints;

@property (nonatomic) BOOL firstLoad;

@property (nonatomic, strong) KNIDelegatingTransitionAnimator *transitionAnimator;
@property (nonatomic, strong) __block UIView *transitioningCell;
@property (nonatomic, assign) __block CGRect startingCellFrame;
@property (nonatomic, strong) __block KNIRecommendedItemDetailViewController *currentDetailViewController;
@property (nonatomic, strong) __block UIView *currentDetailView;

@property (nonatomic, strong) UIPageViewController *detailPageViewController;
@property (nonatomic, strong) NSMutableArray *pages;

@property (nonatomic) BOOL didScrollToBottom;

@property (nonatomic, strong) KNIOffsetAnimator *offsetAnimator;

@property (nonatomic, weak) id errorListener;

@end

@implementation KNIIssueDetailViewController

#pragma mark UIPageViewDatasource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger currentIndex = [self.pages indexOfObject:viewController];
    NSInteger beforeCurrentIndex = (currentIndex - 1) >= 0 ? (currentIndex - 1) : ([self.pages count] - 1);
    return self.pages[beforeCurrentIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger currentIndex = [self.pages indexOfObject:viewController];
    NSInteger afterCurrentIndex = (currentIndex + 1) >= [self.pages count] ? 0 : (currentIndex + 1);
    return self.pages[afterCurrentIndex];
}

#pragma mark - UIPageViewDelegate

// Sent when a gesture-initiated transition begins.
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers NS_AVAILABLE_IOS(6_0)
{
    KNIRecommendedItemDetailViewController *itemDetailVC = [pendingViewControllers firstObject];
    //    [[Mixpanel sharedInstance] track:@"UserDidTapRecommendedItem" properties:@{@"Title" : item.title ? item.title : @"Title Not Found", @"UserRecordID" : self.cloudKitController.userIdentifier}];
    
    self.currentDetailViewController = itemDetailVC;
    [self.itemCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.pages indexOfObject:itemDetailVC] inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:NO];
    KNIIssueCollectionViewCell *cell = (KNIIssueCollectionViewCell *)[self.itemCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[self.pages indexOfObject:itemDetailVC] inSection:0]];
    itemDetailVC.itemImage = cell.image;
    if (self.transitioningCell != nil) {
        [self.transitioningCell removeFromSuperview];
    }
    self.transitioningCell = [KNIIssueCollectionViewCell clonedCell:cell];
    self.transitioningCell.frame = self.view.bounds;
    [self.view insertSubview:self.transitioningCell aboveSubview:self.scrollView];
}

// Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.transitionAnimator = [[KNIDelegatingTransitionAnimator alloc] init];
    
    _detailPageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey : @20.0f}];
    _detailPageViewController.delegate = self;
    _detailPageViewController.dataSource = self;
    //_detailPageViewController.transitioningDelegate = self;
    
    self.textBoxBackground.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.6] CGColor];
    self.textBoxBackground.layer.borderWidth = 0.5;
    
    self.firstLoad = YES;
    self.blurImageView.alpha = 0;
    
    [self populate];
    
    for (NSLayoutConstraint *constraint in self.divHeightConstraints) {
        constraint.constant = 1. / [[UIScreen mainScreen] scale];
    }
    
    self.lastScrollViewContentOffset = self.scrollView.contentOffset;
    
    __weak __typeof__(self) weakSelf = self;
    self.errorListener = [[NSNotificationCenter defaultCenter] addObserverForName:KNICloudKitControllerDidErrorOutNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSError *error = [note object];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"CloudKit Error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    }];
    
    
}

- (void)setDidScrollToBottom:(BOOL)didScrollToBottom
{
    if (!didScrollToBottom || _didScrollToBottom == didScrollToBottom) return;
    _didScrollToBottom = didScrollToBottom;
    if (_didScrollToBottom)
    {
        [[Mixpanel sharedInstance] track:@"UserScrolledIssueToBottom" properties:@{@"Vol" : self.issue.volume, @"No" : self.issue.number, @"Title" : self.issue.name, @"UserRecordID" : [[KNICloudKitController sharedInstance] userIdentifier]}];
    }
}

- (void)dealloc
{
    self.transitioningDelegate = nil;
    self.scrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self.errorListener];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KNIFunFactory addParallaxMotionEffectsToView:self.imageView parallaxOffset:-25];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.imageView removeMotionEffect:[self.imageView.motionEffects firstObject]];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize collectionViewSize = self.itemCollectionView.bounds.size;
    CGSize cellSize = CGSizeMake(collectionViewSize.width - 100, collectionViewSize.height - 40);
    self.itemCollectionViewLayout.itemSize = cellSize;
}

- (void)sortItems
{
    [self.issue sortItems];
}

- (void)populate
{
    if (!self.issue) return;

    __weak __typeof__(self) weakSelf = self;
    if (!self.issue.items && !self.issue.isFetchingItems) {
        [self.issue fetchItemsWithCompletion:^(NSError *error) {
            [weakSelf.issue sortItems];
            [weakSelf.itemCollectionView reloadData];
        }];
    } else if (self.issue.isFetchingItems) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self populate];
        });
        return;
    }
    
    [self.issue sortItems];
    [self.itemCollectionView reloadData];
    self.issueTitleLabel.text = self.issue.name;
    self.issueSubtitleLabel.attributedText = [KNIAttributedStringFactory trackedIssueSubheadlineText:self.issue.subtitle];
    NSString *volumeString = [NSString stringWithFormat:@"VOL %@, NO %@", [self.issue.volume stringValue], [self.issue.number stringValue]];
    self.volumeLabel.attributedText = [KNIAttributedStringFactory trackedIssueVolumeNumberText:volumeString];
    self.quotationLabel.text = self.issue.quotation;
    self.detailLabel.text = self.issue.detail;
    self.imageView.image = self.image;
//    self.blurImageView.image = self.image;
    [DDDImageUtilities applyBlurToImage:self.image withRadius:20 tintColor:[UIColor colorWithWhite:0 alpha:0.2] completion:^(UIImage *image) {
        [UIView transitionWithView:self.blurImageView duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//            self.blurImageView.image = image;
        } completion:^(BOOL finished) {
            
        }];
    }];
    
    self.pages = [[NSMutableArray alloc] initWithCapacity:[self.issue.items count]];
    for (int i = 0; i < [self.issue.items count]; i++) {
        KNIRecommendedItem *item = self.issue.items[i];
        KNIRecommendedItemDetailViewController *itemDetailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([KNIRecommendedItemDetailViewController class])];
        itemDetailVC.item = item;
        itemDetailVC.transitioningDelegate = self;
        //    [[Mixpanel sharedInstance] track:@"UserDidTapRecommendedItem" properties:@{@"Title" : item.title ? item.title : @"Title Not Found", @"UserRecordID" : self.cloudKitController.userIdentifier}];
        //            self.currentDetailViewController = itemDetailVC;
        //            KNIIssueCollectionViewCell *cell = (KNIIssueCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [item downloadImageWithCompletion:^(UIImage *image) {
            itemDetailVC.itemImage = image;
        }];
        
        //            self.transitioningCell = [KNIIssueCollectionViewCell clonedCell:cell];
        //            self.startingCellFrame = [self.itemCollectionView convertRect:cell.frame toView:self.view];
        
        //            self.transitionAnimator = [[KNIDelegatingTransitionAnimator alloc] init];
        //            itemDetailVC.transitioningDelegate = self;
        [self.pages addObject:itemDetailVC];
    }
    NSLog(@"Issue Item Count : %ld", [self.issue.items count]);
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"Issus count: %@",  self.issue.items);
    return [self.issue.items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KNIIssueCollectionViewCell *cell = (KNIIssueCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kItemCellReuseID forIndexPath:indexPath];
    
    KNIRecommendedItem *item = self.issue.items[indexPath.item];
    [cell configureWithItem:item];

//    KNIRecommendedItemDetailViewController *itemDetailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([KNIRecommendedItemDetailViewController class])];
//    itemDetailVC.item = item;
//    itemDetailVC.transitioningDelegate = self;
////    [[Mixpanel sharedInstance] track:@"UserDidTapRecommendedItem" properties:@{@"Title" : item.title ? item.title : @"Title Not Found", @"UserRecordID" : self.cloudKitController.userIdentifier}];
////            self.currentDetailViewController = itemDetailVC;
////            KNIIssueCollectionViewCell *cell = (KNIIssueCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    itemDetailVC.itemImage = cell.image;
////            self.transitioningCell = [KNIIssueCollectionViewCell clonedCell:cell];
////            self.startingCellFrame = [self.itemCollectionView convertRect:cell.frame toView:self.view];
//    
////            self.transitionAnimator = [[KNIDelegatingTransitionAnimator alloc] init];
////            itemDetailVC.transitioningDelegate = self;
//    [self.pages addObject:itemDetailVC];
//    NSLog(@"Page Count: %ld", [self.pages count]);

//            break;
//        }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    KNIRecommendedItemDetailViewController *itemDetailVC = [self.pages objectAtIndex:indexPath.row];
    KNIRecommendedItem *item = itemDetailVC.item;
    [[Mixpanel sharedInstance] track:@"UserDidTapRecommendedItem" properties:@{@"Title" : item.title ? item.title : @"Title Not Found", @"UserRecordID" : self.cloudKitController.userIdentifier}];
    self.currentDetailViewController = itemDetailVC;
    KNIIssueCollectionViewCell *cell = (KNIIssueCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    itemDetailVC.itemImage = cell.image;
    self.transitioningCell = [KNIIssueCollectionViewCell clonedCell:cell];
    self.startingCellFrame = [self.itemCollectionView convertRect:cell.frame toView:self.view];
    
    self.transitionAnimator = [[KNIDelegatingTransitionAnimator alloc] init];
    itemDetailVC.transitioningDelegate = self;

    [self.detailPageViewController setViewControllers:@[itemDetailVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        
    }];

    KNIContainerViewController *containerVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"KNIContainerViewController"];
    [containerVC addChildViewController:self.detailPageViewController];
    [containerVC.view addSubview:self.detailPageViewController.view];
    [containerVC.view sendSubviewToBack:self.detailPageViewController.view];
    containerVC.transitioningDelegate = self;
    [self presentViewController:containerVC animated:YES completion:^{

    }];
//
//    [self presentViewController:itemDetailVC animated:YES completion:^{
//        
//    }];
}

#pragma mark - Scrolling animation

- (void)setBlurImageAlphaForOffsetY:(CGFloat)offsetY
{
    CGFloat contentHeight = self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.frame);
    CGFloat normalizedOffset = offsetY / contentHeight;
    if (normalizedOffset >= 1) self.didScrollToBottom = YES;
    normalizedOffset = offsetY / (CGRectGetHeight(self.scrollView.frame) - kDarkeningInset);
    normalizedOffset = MAX(0, normalizedOffset);
    normalizedOffset = MIN(1, normalizedOffset);
    self.blurImageView.alpha = normalizedOffset;
    self.vignette.alpha = 1 - normalizedOffset;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        [self mainScrollViewDidScroll:scrollView];
    } else if (scrollView == self.itemCollectionView) {
        
    }
}

- (void)mainScrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setBlurImageAlphaForOffsetY:scrollView.contentOffset.y];
    
    CGFloat yTranslation = self.lastScrollViewContentOffset.y - scrollView.contentOffset.y;
    self.lastScrollViewContentOffset = scrollView.contentOffset;
    BOOL collapsingHeader = YES;
    if (scrollView.contentOffset.y > (self.headerView.maximumHeight - self.headerView.minimumHeight) && fabs(self.headerViewHeightConstraint.constant - self.headerView.minimumHeight) < FLT_EPSILON) {
        collapsingHeader = NO;
    }
    if (scrollView.contentOffset.y < 0 && fabs(self.headerViewHeightConstraint.constant - self.headerView.maximumHeight) < FLT_EPSILON) {
        collapsingHeader = NO;;
    }
    
    BOOL animateCollapse = NO;
    BOOL panGestureIsQuiet = fabs([scrollView.panGestureRecognizer velocityInView:self.view].y) < FLT_EPSILON;
    if (panGestureIsQuiet && scrollView.contentOffset.y <= 10) {
        animateCollapse = YES;
    }
    
    // If our velocity is high enough, just animate it off or on.
    if (collapsingHeader || animateCollapse) {
        CGPoint velocity = [self.scrollView.panGestureRecognizer velocityInView:self.view];
        if (velocity.y < -150.0 && !self.animatingHeaderCollapse && fabs(self.headerViewHeightConstraint.constant - self.headerView.minimumHeight) > FLT_EPSILON ) {
            self.headerViewHeightConstraint.constant = self.headerView.minimumHeight;
            self.animatingHeaderCollapse = YES;
            [UIView animateWithDuration:0.2 animations:^{
                [self.headerView layoutIfNeeded];
                self.blurView.alpha = 1;
                self.headerDiv.alpha = 0;
            } completion:^(BOOL finished) {
                self.animatingHeaderCollapse = NO;
            }];
        } else if ((velocity.y > 150.0 && !self.animatingHeaderExpand && fabs(self.headerViewHeightConstraint.constant - self.headerView.maximumHeight) > FLT_EPSILON) || (panGestureIsQuiet && scrollView.contentOffset.y <= 50)) {
            self.headerViewHeightConstraint.constant = self.headerView.maximumHeight;
            self.animatingHeaderExpand = YES;
            [UIView animateWithDuration:0.2 animations:^{
                [self.headerView layoutIfNeeded];
                self.blurView.alpha = 0;
                self.headerDiv.alpha = 1;
            } completion:^(BOOL finished) {
                self.animatingHeaderExpand = NO;
            }];
        }
    }
    
    if (collapsingHeader && !self.animatingHeaderExpand && !self.animatingHeaderCollapse) {
        CGFloat currentHeight = self.headerViewHeightConstraint.constant;
        currentHeight += yTranslation;
        currentHeight = MIN(self.headerView.maximumHeight, currentHeight);
        currentHeight = MAX(self.headerView.minimumHeight, currentHeight);
        
        self.headerViewHeightConstraint.constant = currentHeight;
        [self.headerView layoutIfNeeded];
        
        CGFloat heightDelta = self.headerView.maximumHeight - self.headerView.minimumHeight;
        CGFloat currentDelta = self.headerView.maximumHeight - currentHeight;
        CGFloat alpha = currentDelta / heightDelta;
        self.blurView.alpha = alpha;
        self.headerDiv.alpha = 1. - alpha;
    }
}

- (IBAction)backTapped:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - KNITransitioningViewController

- (void)animatePresentationWithDuration:(NSTimeInterval)duration isFirstViewController:(BOOL)isFirst completion:(void (^)())block
{
    if (!isFirst)
    {
        dispatch_after(duration, dispatch_get_main_queue(), ^{
            block();
            CGRect scrollViewBounds = self.scrollView.bounds;
            scrollViewBounds.origin.y += CGRectGetHeight(self.scrollView.bounds) / 2;
            [UIView animateWithDuration:0.5 animations:^{
                CGFloat height = CGRectGetHeight(self.scrollView.bounds);
                height -= kDarkeningInset;
                self.blurImageView.alpha =  0.5*CGRectGetHeight(self.scrollView.bounds) / height;
                self.scrollView.bounds = scrollViewBounds;
            } completion:^(BOOL finished) {
                
            }];
            
            self.headerViewHeightConstraint.constant = self.headerView.minimumHeight;
            self.animatingHeaderCollapse = YES;
            [UIView animateWithDuration:0.2 animations:^{
                [self.headerView layoutIfNeeded];
                self.blurView.alpha = 1;
                self.headerDiv.alpha = 0;
            } completion:^(BOOL finished) {
                self.animatingHeaderCollapse = NO;
            }];
        });
    }
    else
    {
        self.transitioningCell.frame = self.startingCellFrame;
        self.transitioningCell.alpha = 0;
        [self.view insertSubview:self.transitioningCell aboveSubview:self.scrollView];
        [UIView animateWithDuration:0.1 animations:^{
            self.transitioningCell.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration-0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.transitioningCell.frame = self.view.bounds;
            } completion:^(BOOL finished) {
                block();
                dispatch_after(2*duration, dispatch_get_main_queue(), ^{
                    self.currentDetailView = self.currentDetailViewController.view;
                });
            }];
        }];
    }
}

- (void)animateDismissalWithDuration:(NSTimeInterval)duration isFirstViewController:(BOOL)isFirst completion:(void (^)())block
{
    if (!isFirst)
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
    else
    {
        if (block) block();
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.transitionAnimator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.transitionAnimator;
}

@end
