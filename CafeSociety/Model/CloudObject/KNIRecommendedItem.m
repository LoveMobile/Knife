//
//  KNIRecommendedItem.m
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNIRecommendedItem.h"
#import "KNIImageCache.h"
#import "KNIImageAssetFetcher.h"
#import "KNICloudKitController.h"

@interface KNIRecommendedItem ()

@property (nonatomic, strong) CKRecord *record;
@property (nonatomic, weak) CKDatabase *database;

@property (nonatomic, strong) CKRecord *imageRecord;

@end

@implementation KNIRecommendedItem

- (instancetype)initWithRecord:(CKRecord *)record database:(CKDatabase *)database
{
    if (self = [super init])
    {
        _record = record;
        _database = database;
    }
    return self;
}

- (KNILocation *)location
{
    if (_location) return _location;
    KNILocation *location1 = [[KNILocation alloc] init];
    return location1;
}

- (void)fetchDetailWithCompletion:(void (^)(NSArray *))block
{
    __block NSInteger nOperations = 2;
    __block BOOL didCallCompletionBlock = NO;
    __block NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    [self fetchCreatorWithCompletion:^(NSError *error){
        nOperations--;
        if (error) [errors addObject:error];
        if (nOperations <= 0 && !didCallCompletionBlock) {
            didCallCompletionBlock = YES;
            block(errors);
        }
    }];
    
    [self fetchLocationWithCompletion:^(NSError *error){
        nOperations--;
        if (error) [errors addObject:error];
        if (nOperations <= 0 && !didCallCompletionBlock) {
            didCallCompletionBlock = YES;
            block(errors);
        }
    }];
    
//    [self fetchImageWithCompletion:^(NSURL *url, NSError *error) {
//        nOperations--;
//        if (error) [errors addObject:error];
//        if (nOperations <= 0 && !didCallCompletionBlock) {
//            didCallCompletionBlock = YES;
//            block(errors);
//        }
//    }];
    [self downloadImageWithCompletion:^(UIImage *image) {
        
    }];
}

- (void)fetchCreatorWithCompletion:(void(^)(NSError *error))block
{
    NSParameterAssert(block);
    
    CKReference *creatorRef = self.record[@"creator"];
    if (!creatorRef) {
        block(nil);
        return;
    }
    
    __weak __typeof__(self) weakSelf = self;
    [self.database fetchRecordWithID:creatorRef.recordID completionHandler:^(CKRecord *record, NSError *error) {
        if (record) {
            KNIHumanBeing *creator = [[KNIHumanBeing alloc] initWithRecord:record];
            weakSelf.creator = creator;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                block(error);
            }];
        }
    }];
}

- (void)fetchLocationWithCompletion:(void(^)(NSError *error))block
{
    NSParameterAssert(block);
    
    CKReference *locationRef = self.record[@"location"];
    if (!locationRef) {
        block(nil);
        return;
    }
    __weak __typeof__(self) weakSelf = self;
    [self.database fetchRecordWithID:locationRef.recordID completionHandler:^(CKRecord *record, NSError *error) {
        if (record) {
            KNILocation *location = [[KNILocation alloc] initWithRecord:record];
            weakSelf.location = location;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                block(error);
            }];
        }
    }];
}

- (void)downloadImageWithCompletion:(void (^)(UIImage *image))block
{
    NSParameterAssert(block);
    KNIImageAssetFetcher *fetcher = [[KNIImageAssetFetcher alloc] init];
    CKReference *imageRef = self.record[@"image"];
    [fetcher fetchImageForAssetRecordID:imageRef.recordID completion:block];
}

- (void)downloadImageWithCompletion_:(void(^)(UIImage *image))block
{
    NSParameterAssert(block);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.imageRecord) {
            CKAsset *asset = self.imageRecord[@"asset"];
            NSData *data = [NSData dataWithContentsOfURL:asset.fileURL];
            UIImage *image = [UIImage imageWithData:data];
            if (!image)
            {
                self.imageRecord = nil;
                [self downloadImageWithCompletion:block];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                block(image);
            });
            
            return;
        }
        
        CKReference *imageRef = self.record[@"image"];
        UIImage *cachedImage = [[KNIImageCache sharedCache] imageForCloudKitRecordID:imageRef.recordID];
        if (cachedImage)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(cachedImage);
            });
            return;
        }
        __weak __typeof__(self) weakSelf = self;
        [self.database fetchRecordWithID:imageRef.recordID completionHandler:^(CKRecord *record, NSError *error) {
            weakSelf.imageRecord = record;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                CKAsset *asset = record[@"asset"];
                NSData *data = [NSData dataWithContentsOfURL:asset.fileURL];
                UIImage *image = [UIImage imageWithData:data];
                [[KNIImageCache sharedCache] cacheImage:image forCloudKitRecordID:record.recordID];
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(image);
                });
            });
        }];
    });
}

- (NSString *)title
{
    return self.record[@"title"];
}

- (NSString *)bodyCopy
{
    if ([self.record[@"bodyCopyParagraphs"] count]) {
        NSArray *paragraphs = self.record[@"bodyCopyParagraphs"];
        NSMutableString *bodyCopy = [NSMutableString string];
        for (NSString *paragraph in paragraphs) {
            [bodyCopy appendString:paragraph];
            if (paragraph != [paragraphs lastObject]) {
                [bodyCopy appendString:@"\n\n"];
            }
        }
        return [bodyCopy copy];
    }
    return self.record[@"bodyCopy"];
}

- (NSArray *)tags
{
    return self.record[@"tags"];
}

- (NSArray *)categories
{
    return self.record[@"categories"];
}

- (NSArray *)themes
{
    return self.record[@"themes"];
}

- (NSDate *)createdDate
{
    return self.record[@"createdDate"];
}

- (NSString *)quotation
{
    return self.record[@"quotation"];
}

- (NSString *)tipsSectionTitle
{
    return self.record[@"tipsSectionTitle"];
}

- (NSArray *)tips
{
    return self.record[@"tips"];
}

- (NSURL *)imageURL
{
    CKAsset *asset = self.imageRecord[@"asset"];
    if (!asset) return nil;
    return asset.fileURL;
}

- (NSURL *)thumbnailURL
{
    if (!self.imageRecord) return nil;
    
    CKAsset *asset = self.imageRecord[@"thumbnail"];
    return asset.fileURL;
}

- (NSArray *)upvotedUserIDs
{
    return self.record[@"upvotedUserIDs"];
}

- (UIColor *)titleTextColor
{
    NSArray *colorArray = self.record[@"cellTextColor"];
    UIColor *color = [UIColor whiteColor];
    if (colorArray.count == 4) {
        color = [UIColor colorWithRed:[colorArray[0] doubleValue] green:[colorArray[1] doubleValue] blue:[colorArray[2] doubleValue] alpha:[colorArray[3] doubleValue]];
    } else if (colorArray.count == 3) {
        color = [UIColor colorWithRed:[colorArray[0] doubleValue] green:[colorArray[1] doubleValue] blue:[colorArray[2] doubleValue] alpha:1];
    }
    return color;
}

- (void)setUpvotedUserIDs:(NSArray *)upvotedUserIDs
{
    self.record[@"upvotedUserIDs"] = upvotedUserIDs;
    [[KNICloudKitController sharedInstance] updateGlobalRecord:self.record completion:^(CKRecord *record, NSError *error) {
        if (!error)
        {
            self.record = record;
            NSLog(@"Registered upvote: %@", self.upvotedUserIDs);
        }
    }];
}

- (NSInteger)numberOfUpvotes
{
    return self.upvotedUserIDs.count;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{\rtitle: %@\rbodyCopy: %@\rtags: %@\rcategories: %@\rthemes: %@\rcreatedDate: %@\r imageURL: %@\r thumbnailURL: %@\rcreator: %@\rlocation: %@\r}", self.title, self.bodyCopy, self.tags, self.categories, self.themes, self.createdDate, self.imageURL, self.thumbnailURL, self.creator, self.location];
}

@end
