//
//  DDDImageCache.h
//  DDDLibraries
//
//  Created by Brian Drell on 1/18/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DDDImageCacheType) {
    DDDImageCacheTypeDiskBacked,
    DDDImageCacheTypeMemoryOnly
};

@interface DDDImageCache : NSObject

- (instancetype)initWithCacheType:(DDDImageCacheType)cacheType;

// Image caching is done via an HTTP cache.
@property (nonatomic, readonly) NSURLCache *urlCache;
@property (nonatomic, readonly) DDDImageCacheType type;

// Sets the date of last cache for the
//   provided URL to [NSDate date].
- (void)imageWasFetchedForURL:(NSURL *)url;
// Retrieves the NSDate for the last time
//   the image at the URL was cached.
- (NSDate *)dateImageURLWasLastFetched:(NSURL *)url;

// Clears all images from the cache.
- (void)clear;
// Clears the image for the specified URL
//   from the cache.
- (void)clearForURL:(NSURL *)url;

@end
