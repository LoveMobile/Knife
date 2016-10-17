//
//  DDDAsynchronousImageView.m
//  DDDLibraries
//
//  Created by Brian Drell on 12/15/13.
//  Copyright (c) 2013 Brian Drell. All rights reserved.
//

#import "DDDAsynchronousImageView.h"
#import "DDDImageFetcher.h"

typedef void(^imageDidTransitionBlock)();

@interface DDDAsynchronousImageView ()

@property (nonatomic, assign) DDDAsynchronousImageViewState state;
@property (nonatomic) NSMutableArray *imagesForState;
@property (nonatomic, weak) NSURLSessionDataTask *currentDataTask;

@end

@implementation DDDAsynchronousImageView

#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super initWithImage:image]) {
        [self commonInit];
        _imagesForState[DDDAsynchronousImageViewStateStub] = image;
        _state = DDDAsynchronousImageViewStateStub;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    if (self = [super initWithImage:image highlightedImage:highlightedImage]) {
        [self commonInit];
        _imagesForState[DDDAsynchronousImageViewStateStub] = image;
        _state = DDDAsynchronousImageViewStateStub;
    }
    return self;
}

- (void)commonInit
{
    _imagesForState = [@[@0, @0, @0, @0] mutableCopy];
}

#pragma mark - Setters

- (void)setImage:(UIImage *)image animated:(BOOL)animated
{
    if (animated) [self transitionToImage:image];
    else [self setImage:image];
}

- (void)setState:(DDDAsynchronousImageViewState)state immediately:(BOOL)immediately
{
    self.state = state;
    id image = nil;
    if (state != DDDAsynchronousImageViewStateLoaded) {
        image = self.imagesForState[state];
    }
    
    if ([image isKindOfClass:[UIImage class]])
    {
        [self transitionToImage:image];
    }
}

- (void)setImageURL:(NSURL *)imageURL
{
    [self cancelCurrentDownloadTask];
    if (!imageURL) {
        self.state = DDDAsynchronousImageViewStateStub;
        self.image = [self imageForState:DDDAsynchronousImageViewStateStub];
        imageDidTransitionBlock block = [[self imageTransitionedBlock] copy];
        block();
        return;
    }
    _imageURL = imageURL;
    
    self.state = DDDAsynchronousImageViewStateLoading;
    [self transitionToImage:[self imageForState:DDDAsynchronousImageViewStateLoading]];
    
    __weak __typeof__(self) weakSelf = self;
    _currentDataTask = [[DDDImageFetcher sharedFetcher] fetchImageURL:imageURL completion:^(UIImage *image, NSURLResponse *response, NSError *error) {
        if (!error && image) {
            weakSelf.state = DDDAsynchronousImageViewStateLoaded;
            [weakSelf transitionToImage:image];
        } else {
            weakSelf.state = DDDAsynchronousImageViewStateFailed;
            [weakSelf transitionToImage:[self imageForState:DDDAsynchronousImageViewStateFailed]];
        }
    }];
}

- (void)transitionToImage:(UIImage *)image
{
    imageDidTransitionBlock block = [[self imageTransitionedBlock] copy];
    
    if (self.transitionStyle == DDDAsynchronousImageViewTransitionStyleNone) {
        [self setImage:image];
        block();
    } else {
        [UIView transitionWithView:self duration:self.transitionDuration options:(UIViewAnimationOptions)self.transitionStyle animations:^{
            [self setImage:image];
        } completion:^(BOOL finished) {
            block();
        }];
    }
}

- (UIImage *)imageForState:(DDDAsynchronousImageViewState)state
{
    id image = self.imagesForState[state];
    if ([image isKindOfClass:[UIImage class]]) {
        return image;
    }
    return nil;
}

- (void)setPlaceholderImage:(UIImage *)image forState:(DDDAsynchronousImageViewState)state
{
    self.imagesForState[state] = image;
}

- (void)cancelCurrentDownloadTask
{
    [self.currentDataTask cancel];
}

- (imageDidTransitionBlock)imageTransitionedBlock
{
    __weak __typeof__(self) weakSelf = self;
    return [^{
        if ([weakSelf.delegate respondsToSelector:@selector(asynchronousImageView:didTransitionToState:)]) {
            [weakSelf.delegate asynchronousImageView:weakSelf didTransitionToState:weakSelf.state];
        }
    } copy];
}

@end
