//
//  KNIAttributedStringFactory.h
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KNIAttributedStringFactory : NSObject

+ (NSAttributedString *)trackedHeaderText:(NSString *)string;
+ (NSAttributedString *)trackedIssueSubheadlineText:(NSString *)string;
+ (NSAttributedString *)trackedIssueVolumeNumberText:(NSString *)string;
+ (NSAttributedString *)trackedButtonText:(NSString *)buttonText;

@end
