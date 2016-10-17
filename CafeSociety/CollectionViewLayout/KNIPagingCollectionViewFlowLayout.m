//
//  KNIPagingCollectionViewFlowLayout.m
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNIPagingCollectionViewFlowLayout.h"

@implementation KNIPagingCollectionViewFlowLayout

- (instancetype)init
{
    if (self = [super init]) {
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

- (void)commonInit
{
    _flickVelocity = 0.3;
}

- (CGFloat)pageWidth
{
    return self.itemSize.width + self.minimumLineSpacing;
}

- (CGFloat)pageHeight
{
    return self.itemSize.height + self.minimumLineSpacing;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        return [self targetContentOffsetForHorizontalProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
    } else {
        return [self targetContentOffsetForVerticalProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
    }
}

- (CGPoint)targetContentOffsetForVerticalProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat rawPageValue = self.collectionView.contentOffset.y / [self pageHeight];
    CGFloat currentPage = (velocity.y > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
    CGFloat nextPage = (velocity.y > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
    
    BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
    BOOL flicked = fabs(velocity.y) > [self flickVelocity];
    if (pannedLessThanAPage && flicked) {
        proposedContentOffset.y = nextPage * [self pageHeight];
        self.currentPage = nextPage;
    } else {
        proposedContentOffset.y = roundf(rawPageValue) * [self pageHeight];
        self.currentPage = currentPage;
    }
    
    return proposedContentOffset;
}

- (CGPoint)targetContentOffsetForHorizontalProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat rawPageValue = self.collectionView.contentOffset.x / self.pageWidth;
    CGFloat currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
    CGFloat nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
    
    BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
    BOOL flicked = fabs(velocity.x) > [self flickVelocity];
    if (pannedLessThanAPage && flicked) {
        proposedContentOffset.x = nextPage * self.pageWidth;
        self.currentPage = nextPage;
    } else {
        proposedContentOffset.x = roundf(rawPageValue) * self.pageWidth;
        self.currentPage = currentPage;
    }
    
    return proposedContentOffset;
}

@end
