//
//  DDDImageFetcher.h
//  DDDLibraries
//
//  Created by Brian Drell on 1/18/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

@import UIKit;
#import "DDDImageCache.h"

typedef void(^DDDImageFetchCompletionBlock)(UIImage *image, NSURLResponse *response, NSError *error);

@interface DDDImageFetcher : NSObject

// Default is a disk-backed memory cache.
// Disk size is 64 MB.
// Memory size is 8 MB.
@property (nonatomic, assign) DDDImageCacheType imageCacheType;
// Default is 1 day
@property (nonatomic, assign) NSTimeInterval imageCacheExpirationDuration;

// Use this as a singleton to put all image fetching on one NSOperationQueue.
+ (instancetype)sharedFetcher;

- (NSURLSessionDataTask *)fetchImageURL:(NSURL *)url completion:(DDDImageFetchCompletionBlock)block;
- (void)clearImageCache;
- (void)clearImageCacheForURL:(NSURL *)url;

@end
