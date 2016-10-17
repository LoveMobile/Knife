//
//  DDDImageCache.m
//  DDDLibraries
//
//  Created by Brian Drell on 1/18/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

#import "DDDImageCache.h"

static const NSUInteger kMegaByte = 1048576;
static NSString *const kDateArchiveFileName = @"/CacheDateForImageURL";
static NSString *const kImageCacheDirectoryName = @"/DDDImageCache";

@interface DDDImageCache ()

@property (nonatomic, strong) NSURLCache *defaultMemoryOnlyCache;
@property (nonatomic, strong) NSURLCache *defaultDiskBackedMemoryCache;
@property (nonatomic, strong) NSURLCache *cache;
@property (nonatomic, assign) DDDImageCacheType type;
@property (nonatomic, strong) NSDictionary *cacheDateForImageURL;

@end

@implementation DDDImageCache

@synthesize cacheDateForImageURL = _cacheDateForImageURL;

- (instancetype)initWithCacheType:(DDDImageCacheType)cacheType
{
    if (self = [super init]) {
        _type = cacheType;
        [self initializeCacheForType:_type];
    }
    return self;
}

- (void)initializeCacheForType:(DDDImageCacheType)type
{
    switch (type) {
        case DDDImageCacheTypeMemoryOnly: {
            _cache = [self defaultMemoryOnlyCache];
            break;
        }
        case DDDImageCacheTypeDiskBacked: {
            _cache = [self defaultDiskBackedMemoryCache];
            break;
        }
    }
}

#pragma mark - Property overrides

- (NSURLCache *)urlCache
{
    return _cache;
}

- (NSURLCache *)defaultDiskBackedMemoryCache
{
    if (!_defaultDiskBackedMemoryCache) {
        if (_defaultMemoryOnlyCache) _defaultMemoryOnlyCache = nil;
        NSUInteger diskSize = 256*kMegaByte;
        NSUInteger memorySize = 8*kMegaByte;
        _defaultDiskBackedMemoryCache = [self imageCacheWithMemoryCapacity:memorySize diskCapacity:diskSize];
    }
    return _defaultDiskBackedMemoryCache;
}

- (NSURLCache *)defaultMemoryOnlyCache
{
    if (!_defaultMemoryOnlyCache) {
        if (_defaultDiskBackedMemoryCache) _defaultDiskBackedMemoryCache = nil;
        NSUInteger memorySize = 16*kMegaByte;
        _defaultMemoryOnlyCache = [self imageCacheWithMemoryCapacity:memorySize diskCapacity:0];
    }
    return _defaultMemoryOnlyCache;
}

- (NSDictionary *)cacheDateForImageURL
{
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathWithDirectoryName:kDateArchiveFileName]];
    return dictionary;
}

- (void)setCacheDateForImageURL:(NSDictionary *)cacheDateForImageURL
{
    [NSKeyedArchiver archiveRootObject:cacheDateForImageURL toFile:[self cachePathWithDirectoryName:kDateArchiveFileName]];
}

- (void)imageWasFetchedForURL:(NSURL *)url
{
    NSMutableDictionary *dictionary = [[self cacheDateForImageURL] mutableCopy];
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc] init];
    }
    [dictionary setObject:[NSDate date] forKey:url];
    [self setCacheDateForImageURL:[dictionary copy]];
}

- (NSDate *)dateImageURLWasLastFetched:(NSURL *)url
{
    NSDictionary *dateDict = [self cacheDateForImageURL];
    if (dateDict) {
        if (dateDict[url]) {
            return dateDict[url];
        }
    }
    return nil;
}

#pragma mark - Cache creation

- (NSURLCache *)imageCacheWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity
{
    NSString *fullCachePath = [self cachePathWithDirectoryName:kImageCacheDirectoryName];
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:fullCachePath];
    return cache;
}

- (NSString *)cachePathWithDirectoryName:(NSString *)name
{
    NSString *cachePath = [name copy];
    NSString *userPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullCachePath = [[userPath stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:cachePath];
    return fullCachePath;
}

- (void)clear
{
    [self.cache removeAllCachedResponses];
}

- (void)clearForURL:(NSURL *)url
{
    [self.cache removeCachedResponseForRequest:[NSURLRequest requestWithURL:url]];
}

@end
