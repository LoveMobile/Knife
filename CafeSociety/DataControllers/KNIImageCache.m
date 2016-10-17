//
//  KNIImageCache.m
//  The Knife
//
//  Created by Brian Drell on 2/7/15.
//  Copyright (c) 2015 The Knife App Co. All rights reserved.
//

#import "KNIImageCache.h"

@interface KNIImageCache ()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation KNIImageCache

+ (instancetype)sharedCache
{
    static id sharedCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[self alloc] init];
    });
    return sharedCache;
}

- (instancetype)init
{
    if (self = [super init]) {
        _cache = [[NSCache alloc] init];
    }
    return self;
}

+ (NSString *)cacheKeyForRecordID:(CKRecordID *)recordID
{
    return [[recordID.recordName stringByAppendingString:recordID.zoneID.zoneName] stringByAppendingString:recordID.zoneID.ownerName];
}

+ (NSString *)filePathForFileName:(NSString *)fileName
{
    fileName = [[fileName copy] stringByAppendingString:@".png"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    return filePath;
}

- (UIImage *)imageForCloudKitRecordID:(CKRecordID *)recordID
{
    NSString *cacheKey = [[self class] cacheKeyForRecordID:recordID];
    UIImage *image = [self.cache objectForKey:cacheKey];
    if (image) return image;
    
    image = [self imageForFileName:cacheKey];
    if (image)
    {
        [self.cache setObject:image forKey:cacheKey];
    }
    return image;
}

- (void)readImageFromCacheAndDecodeForRecordID:(CKRecordID *)recordID completion:(void(^)(UIImage *image))block
{
    NSParameterAssert(block != nil);
    NSString *cacheKey = [[self class] cacheKeyForRecordID:recordID];
    UIImage *image = [self.cache objectForKey:cacheKey];
    if (image) block(image);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [self dataForFileName:cacheKey];
        if (data)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self decodeImageInBackgroundWithData:data completion:block];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil);
            });
        }
    });
}

- (void)cacheImage:(UIImage *)image forCloudKitRecordID:(CKRecordID *)recordID
{
    NSString *cacheKey = [[self class] cacheKeyForRecordID:recordID];
    [self.cache setObject:image forKey:cacheKey];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self saveImage:image toFileName:cacheKey];
    });
}

- (UIImage *)imageForFileName:(NSString *)fileName
{
    NSString *filePath = [[self class] filePathForFileName:fileName];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return [UIImage imageWithData:data];
}

- (NSData *)dataForFileName:(NSString *)fileName
{
    NSString *filePath = [[self class] filePathForFileName:fileName];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

- (void)saveImage:(UIImage *)image toFileName:(NSString *)fileName
{
    // Create path.
    NSString *filePath = [[self class] filePathForFileName:fileName];
    
    // Save image.
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [self addSkipBackupAttributeToItemAtURL:fileURL];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    if (![[NSFileManager defaultManager] fileExistsAtPath: [URL path]]) return NO;
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
    if (!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (void)decodeImageInBackgroundWithData:(NSData *)data completion:(void(^)(UIImage *image))block
{
    NSParameterAssert(block != nil);
    UIImage *image = [UIImage imageWithData:data];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        const CGImageRef cgImage = [image CGImage];
        
        size_t width = CGImageGetWidth(cgImage);
        size_t height = CGImageGetHeight(cgImage);
        
        const CGColorSpaceRef colorspace = CGImageGetColorSpace(cgImage);
        const CGContextRef context = CGBitmapContextCreate(
                                                           NULL, /* Where to store the data. NULL = don’t care */
                                                           width, height, /* width & height */
                                                           8, width * 4, /* bits per component, bytes per row */
                                                           colorspace, (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
        CGContextRelease(context);
        dispatch_async(dispatch_get_main_queue(), ^{
            block(image);
        });
    });
}

@end
