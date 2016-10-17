//
//  DDDAsynchronousImageView.h
//  DDDLibraries
//
//  Created by Brian Drell on 12/15/13.
//  Copyright (c) 2013 Brian Drell. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DDDAsynchronousImageViewState) {
    DDDAsynchronousImageViewStateStub,
    DDDAsynchronousImageViewStateLoading,
    DDDAsynchronousImageViewStateLoaded,
    DDDAsynchronousImageViewStateFailed
};

typedef NS_OPTIONS(NSInteger, DDDAsynchronousImageViewTransitionStyle) {
    DDDAsynchronousImageViewTransitionStyleNone = 0 << 20,
    DDDAsynchronousImageViewTransitionStyleCrossFade = 5 << 20,
    DDDAsynchronousImageViewTransitionStyleFlipFromLeft = 1 << 20,
    DDDAsynchronousImageViewTransitionStyleFlipFromRight = 2 << 20,
    DDDAsynchronousImageViewTransitionStyleFlipFromTop = 6 << 20,
    DDDAsynchronousImageViewTransitionStyleFlipFromBottom = 7 << 20
};


@protocol DDDAsynchronousImageViewDelegate;


@interface DDDAsynchronousImageView : UIImageView

@property (nonatomic, weak) id<DDDAsynchronousImageViewDelegate> delegate;
@property (nonatomic, readonly) DDDAsynchronousImageViewState state;
@property (nonatomic, assign) DDDAsynchronousImageViewTransitionStyle transitionStyle;
@property (nonatomic, assign) NSTimeInterval transitionDuration;
@property (nonatomic, strong) NSURL *imageURL;

- (void)setImage:(UIImage *)image animated:(BOOL)animated;
- (void)setState:(DDDAsynchronousImageViewState)state immediately:(BOOL)immediately;
- (void)setPlaceholderImage:(UIImage *)image forState:(DDDAsynchronousImageViewState)state;
- (void)cancelCurrentDownloadTask;

@end


@protocol DDDAsynchronousImageViewDelegate <NSObject>

- (void)asynchronousImageView:(DDDAsynchronousImageView *)imageView didTransitionToState:(DDDAsynchronousImageViewState)state;

@end
