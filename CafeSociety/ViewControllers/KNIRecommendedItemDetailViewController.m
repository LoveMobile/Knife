//
//  KNIRecommendedItemDetailViewController.m
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

@import MapKit;

#import "KNIRecommendedItemDetailViewController.h"
#import "DDDImageUtilities.h"
#import "KNIAttributedStringFactory.h"
#import "KNICloudKitController.h"
#import "KNIFunFactory.h"

static const CGFloat kDarkeningInset = 200;

@interface KNIRecommendedItemDetailViewController () <MKMapViewDelegate, UIScrollViewDelegate, KNITransitioningViewController, UITextViewDelegate>

@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, weak) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UIView *blurImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageActivityIndicator;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *whereAtLabel;
@property (nonatomic, weak) IBOutlet UITextView *bodyCopyTextView;

@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;

@property (nonatomic, weak) IBOutlet UIView *creatorContainerView;
@property (nonatomic, weak) IBOutlet UIImageView *creatorAvatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *creatorNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *creatorBioLabel;

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *adviceContainerView;
@property (weak, nonatomic) IBOutlet UIView *placeContainerView;
@property (weak, nonatomic) IBOutlet UILabel *adviceTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *adviceTextView;

@property (weak, nonatomic) IBOutlet UIView *vignette;
@property (weak, nonatomic) IBOutlet UIView *bottomOfQuoteDiv;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *divHeightConstraints;

@property (nonatomic, assign) BOOL didScrollToBottom;

@property (nonatomic, weak) id errorListener;

@property (weak, nonatomic) IBOutlet UIButton *directionsButton;
@property (weak, nonatomic) IBOutlet UIButton *callAheadButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsSpacerConstraint;

@end

@implementation KNIRecommendedItemDetailViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.blurImageView.alpha = 0;
    
    for (NSLayoutConstraint *constraint in self.divHeightConstraints) {
        constraint.constant = 1. / [[UIScreen mainScreen] scale];
    }
    
    self.creatorAvatarImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.creatorAvatarImageView.layer.borderWidth = 2.;
    
    if (!self.itemImage) [self loadItemImage];
    else {
        self.itemImageView.image = self.itemImage;
        
    }
    
    [self loadImages];
    
    [self populateText];
    
    [self centerMapOnItemLocation];
    
    if (!self.item.tips.count) {
        [self.adviceContainerView removeFromSuperview];
    }
    if (!self.item.creator) {
        [self.creatorContainerView removeFromSuperview];
    }
    if (!self.item.location.streetAddress.length) {
        [self.placeContainerView removeFromSuperview];
    }
    
    __weak __typeof__(self) weakSelf = self;
    self.errorListener = [[NSNotificationCenter defaultCenter] addObserverForName:KNICloudKitControllerDidErrorOutNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSError *error = [note object];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"CloudKit Error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    }];
    
    self.geocoder = [[CLGeocoder alloc] init];
//    [self.geocoder geocodeAddressString:@"2708 Elm Street Dallas, TX 75226" completionHandler:^(NSArray *placemarks, NSError *error) {
//        for (CLPlacemark *placemark in placemarks)
//        {
//            NSLog(@"Coordinates: %@, %@", @(placemark.location.coordinate.latitude), @(placemark.location.coordinate.longitude));
//        }
//    }];
    
    NSAttributedString *attrDirections = [KNIAttributedStringFactory trackedButtonText:[self.directionsButton titleForState:UIControlStateNormal]];
    [self.directionsButton setAttributedTitle:attrDirections forState:UIControlStateNormal];
    
    NSAttributedString *attrCallAhead = [KNIAttributedStringFactory trackedButtonText:[self.callAheadButton titleForState:UIControlStateNormal]];
    [self.callAheadButton setAttributedTitle:attrCallAhead forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KNIFunFactory addParallaxMotionEffectsToView:self.itemImageView parallaxOffset:-25];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.itemImageView removeMotionEffect:[self.itemImageView.motionEffects firstObject]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.errorListener];
}

- (void)setDidScrollToBottom:(BOOL)didScrollToBottom
{
    if (!didScrollToBottom || _didScrollToBottom == didScrollToBottom) return;
    _didScrollToBottom = didScrollToBottom;
    if (_didScrollToBottom)
    {
        [[Mixpanel sharedInstance] track:@"UserScrolledItemToBottom" properties:@{@"Title" : self.item.title ? self.item.title : @"", @"UserRecordID" : [[KNICloudKitController sharedInstance] userIdentifier]}];
    }
}

#pragma mark - IBAction

- (IBAction)directionsTapped:(UIButton *)sender
{
    if (!self.item.location) return;
    __weak __typeof__(self) weakSelf = self;
    [self.geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:self.item.location.coordinate.latitude longitude:self.item.location.coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count) {
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:[placemarks firstObject]];
            CLLocation *fromLocation = mapItem.placemark.location;
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(fromLocation.coordinate, 10000, 10000);
            [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsMapCenterKey : [NSValue valueWithMKCoordinate:region.center], MKLaunchOptionsMapSpanKey : [NSValue valueWithMKCoordinateSpan:region.span]}];
            [[Mixpanel sharedInstance] track:@"UserDidTapAddress" properties:@{@"LocationTitle" : weakSelf.item.title, @"UserRecordID" : [[KNICloudKitController sharedInstance] userIdentifier]}];
        }
    }];
}

- (IBAction)callTapped:(UIButton *)sender
{
    [[Mixpanel sharedInstance] track:@"UserDidTapPhoneNumber" properties:@{@"LocationTitle" : self.item.title, @"UserRecordID" : [[KNICloudKitController sharedInstance] userIdentifier]}];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", self.item.location.phone]]];
}

- (void)populateText
{
    if (!self.item.location.phone.length || !self.item.location.streetAddress.length) {
        [self.directionsButton removeFromSuperview];
        [self.callAheadButton removeFromSuperview];
        self.buttonsSpacerConstraint.constant = 16;
    }
    self.addressTextView.delegate = self;
    self.titleLabel.text = self.item.title;
//    self.whereAtLabel.text = [NSString stringWithFormat:@"%@", [self.item.location.name uppercaseString]];
    self.whereAtLabel.attributedText = [KNIAttributedStringFactory trackedIssueSubheadlineText:[self.item.location.name uppercaseString]];
    self.quoteLabel.text = [NSString stringWithFormat:@"\"%@\"", self.item.quotation];
    self.bodyCopyTextView.text = self.item.bodyCopy;
    
    self.creatorNameLabel.text = self.item.creator.name;
    self.creatorBioLabel.text = self.item.creator.bio;
    
    
//    NSLog(@"Font: %@", self.bodyCopyTextView.font);
    self.bodyCopyTextView.font = [UIFont kni_oxygenRegularFontWithSize:14];
    self.bodyCopyTextView.textColor = [UIColor whiteColor];
    
    NSDictionary *attributes = @{NSFontAttributeName : self.addressTextView.font, NSForegroundColorAttributeName : self.addressTextView.textColor};
    NSMutableAttributedString *addressText;
    if (self.item.location.website) {
        addressText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@, %@ %@\n\n%@\n\n%@", self.item.location.streetAddress, self.item.location.city, self.item.location.state, self.item.location.zipCode, self.item.location.phone, @"On The Web"] attributes:attributes];
        NSRange webRange = [addressText.string rangeOfString:@"On The Web"];
        [addressText addAttribute:NSLinkAttributeName value:self.item.location.website range:webRange];
    } else {
        addressText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@, %@ %@\n\n%@", self.item.location.streetAddress, self.item.location.city, self.item.location.state, self.item.location.zipCode, self.item.location.phone] attributes:attributes];
    }
    
    self.addressTextView.attributedText = addressText;
    
    if (self.item.tips.count) {
        self.adviceTitleLabel.text = self.item.tipsSectionTitle;
        NSMutableString *string = [[NSMutableString alloc] init];
        for (NSString *tip in self.item.tips) {
            [string appendFormat:@"%@\n\n", tip];
        }
        self.adviceTextView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    }
}

#pragma mark - Images

- (void)loadImages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        KNIHumanBeing *creator = self.item.creator;
        if (creator)
        {
            NSData *avatarData = [NSData dataWithContentsOfURL:creator.avatarURL];
            UIImage *avatarImage = [UIImage imageWithData:avatarData];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.creatorAvatarImageView.image = avatarImage;
            });
        }
    });
}

- (void)loadItemImage
{
    if (self.item.imageURL)
    {
        [self setItemImage];
        return;
    }
    [self.imageActivityIndicator startAnimating];
    __weak __typeof__(self) weakSelf = self;
    [self.item downloadImageWithCompletion:^(UIImage *image) {
        weakSelf.itemImageView.image = image;
        weakSelf.itemImage = image;
    }];
}

- (void)setItemImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *mainImageData = [NSData dataWithContentsOfURL:self.item.imageURL];
        UIImage *mainImage = [UIImage imageWithData:mainImageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageActivityIndicator stopAnimating];
            [UIView transitionWithView:self.itemImageView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                self.itemImageView.image = mainImage;
            } completion:nil];
        });
    });
}

- (void)centerMapOnItemLocation
{
    if (self.mapView.annotations)
        [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:self.item.location];
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
}

#pragma mark - ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
//    CGFloat normalizedY = offsetY / CGRectGetHeight(self.view.bounds) * 4;
//    normalizedY = MIN(normalizedY, 1);
//    self.blurImageView.alpha = normalizedY;
//    self.vignette.alpha = 1 - normalizedY;
    [self setBlurImageAlphaForOffsetY:offsetY];
}

- (void)setBlurImageAlphaForOffsetY:(CGFloat)offsetY
{
    CGFloat contentHeight = self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.frame);
    CGFloat normalizedOffset = offsetY / contentHeight;
    if (normalizedOffset > 1) self.didScrollToBottom = YES;
    
    // Darken the screen fully once we've scrolled a screen's height.
    normalizedOffset = offsetY / (CGRectGetHeight(self.scrollView.bounds) - kDarkeningInset);
    normalizedOffset = MAX(0, normalizedOffset);
    normalizedOffset = MIN(1, normalizedOffset);
    self.blurImageView.alpha = normalizedOffset;
    self.vignette.alpha = 1 - normalizedOffset;
}

- (IBAction)backTapped:(UIButton *)sender
{
    if (!self.presentingViewController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

#pragma mark - KNITransitioningViewController

- (void)animatePresentationWithDuration:(NSTimeInterval)duration isFirstViewController:(BOOL)isFirst completion:(void (^)())block
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
    });
}

- (void)animateDismissalWithDuration:(NSTimeInterval)duration isFirstViewController:(BOOL)isFirst completion:(void (^)())block
{
    if (block) block();
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [[Mixpanel sharedInstance] track:@"UserDidTapMapAnnotation" properties:@{@"LocationTitle" : self.item.location.name, @"UserRecordID" : [[KNICloudKitController sharedInstance] userIdentifier]}];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSString *scheme = URL.scheme;
    if ([scheme isEqualToString:@"tel"]) {
        [[Mixpanel sharedInstance] track:@"UserDidTapPhoneNumber" properties:@{@"LocationTitle" : self.item.title, @"UserRecordID" : [[KNICloudKitController sharedInstance] userIdentifier]}];
    } else if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        [[Mixpanel sharedInstance] track:@"UserDidTapWebLink" properties:@{@"URL" : URL, @"LocationTitle" : self.item.title, @"UserRecordID" : [[KNICloudKitController sharedInstance] userIdentifier]}];
    } else if (URL) {
        [[Mixpanel sharedInstance] track:@"UserDidTapAddress" properties:@{@"LocationTitle" : self.item.title, @"UserRecordID" : [[KNICloudKitController sharedInstance] userIdentifier]}];
    }
    return YES;
}

@end
