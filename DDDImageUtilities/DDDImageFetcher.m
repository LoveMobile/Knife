//
//  DDDImageFetcher.m
//  DDDLibraries
//
//  Created by Brian Drell on 1/18/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

#import "DDDImageFetcher.h"

@interface DDDImageFetcher () <NSURLSessionDataDelegate>

@property (nonatomic, strong) DDDImageCache *imageCache;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSession *noCacheSession;
@property (nonatomic, strong) NSURLSessionConfiguration *configuration;
@property (nonatomic, strong) NSURLSessionConfiguration *noCacheConfiguration;
@property (nonatomic, strong) NSOperationQueue *imageCreationQueue;

@end


@implementation DDDImageFetcher

#pragma mark - Init

+ (instancetype)sharedFetcher
{
    static id sharedFetcher;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFetcher = [[self alloc] init];
    });
    return sharedFetcher;
}

- (instancetype)init
{
    if (self = [super init]) {
        _imageCache = [[DDDImageCache alloc] initWithCacheType:DDDImageCacheTypeDiskBacked];
        _imageCreationQueue = [[NSOperationQueue alloc] init];
        _imageCreationQueue.maxConcurrentOperationCount = 20;
    }
    return self;
}

#pragma mark - Property overrides
#pragma mark Cache
- (NSTimeInterval)imageCacheExpirationDuration
{
    if (!_imageCacheExpirationDuration) {
        // 1 day
        _imageCacheExpirationDuration = (double)60*60*24;
    }
    return _imageCacheExpirationDuration;
}

- (void)setImageCacheType:(DDDImageCacheType)imageCacheType
{
    if (imageCacheType == _imageCacheType) return;
    _imageCacheType = imageCacheType;
    self.imageCache = [[DDDImageCache alloc] initWithCacheType:_imageCacheType];
}

- (DDDImageCache *)imageCache
{
    if (!_imageCache) {
        _imageCache = [[DDDImageCache alloc] initWithCacheType:self.imageCacheType];
    }
    return _imageCache;
}

#pragma mark NSURLSession and config
- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:self.configuration delegate:nil delegateQueue:self.imageCreationQueue];
    }
    return _session;
}

- (NSURLSession *)noCacheSession
{
    if (!_noCacheSession) {
        _noCacheSession = [NSURLSession sessionWithConfiguration:self.noCacheConfiguration delegate:nil delegateQueue:self.imageCreationQueue];
    }
    return _noCacheSession;
}

- (NSURLSessionConfiguration *)configuration
{
    if (!_configuration) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.URLCache = self.imageCache.urlCache;
        configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        _configuration = configuration;
    }
    return _configuration;
}

- (NSURLSessionConfiguration *)noCacheConfiguration
{
    if (!_noCacheConfiguration) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.URLCache = self.imageCache.urlCache;
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        _noCacheConfiguration = configuration;
    }
    return _noCacheConfiguration;
}

#pragma mark - Fetch

- (NSURLSessionDataTask *)fetchImageURL:(NSURL *)url completion:(DDDImageFetchCompletionBlock)block
{
    NSDate *dateLastFetched = [self.imageCache dateImageURLWasLastFetched:url];
    if (dateLastFetched
        && [[NSDate date] timeIntervalSinceDate:dateLastFetched] < self.imageCacheExpirationDuration) {
        return [self fetchCachedImageForURL:url completion:block];
    } else {
        return [self fetchRemoteImageForURL:url completion:block];
    }
}

- (NSURLSessionDataTask *)fetchCachedImageForURL:(NSURL *)url completion:(DDDImageFetchCompletionBlock)block
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (block) {
                    block(image, response, error);
                }
            }];
        }
    }];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)fetchRemoteImageForURL:(NSURL *)url completion:(DDDImageFetchCompletionBlock)block
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [self.noCacheSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            [self.imageCache imageWasFetchedForURL:url];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (!image) {
                    [self fetchCachedImageForURL:url completion:block];
                } else if (block) {
                    block(image, response, error);
                }
            }];
        }
    }];
    [task resume];
    return task;
}

#pragma mark - Cache clearing

- (void)clearImageCache
{
    [self.imageCache clear];
}

- (void)clearImageCacheForURL:(NSURL *)url
{
    [self.imageCache clearForURL:url];
}

@end
