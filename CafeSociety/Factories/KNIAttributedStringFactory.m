//
//  KNIAttributedStringFactory.m
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "KNIAttributedStringFactory.h"

@implementation KNIAttributedStringFactory

+ (NSAttributedString *)trackedHeaderText:(NSString *)string
{
    UIFont *font = [UIFont kni_oxygenBoldFontWithSize:14];
    NSDictionary *attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor], NSKernAttributeName : @2};
    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

+ (NSAttributedString *)trackedIssueSubheadlineText:(NSString *)string
{
    UIFont *font = [UIFont kni_oxygenBoldFontWithSize:10];
    NSDictionary *attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor], NSKernAttributeName : @2};
    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

+ (NSAttributedString *)trackedIssueVolumeNumberText:(NSString *)string
{
    UIFont *font = [UIFont kni_oxygenBoldFontWithSize:16];
    NSDictionary *attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor], NSKernAttributeName : @2};
    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

+ (NSAttributedString *)trackedButtonText:(NSString *)buttonText
{
    UIFont *font = [UIFont kni_avenirNextDemiBoldFontWithSize:12];
    NSDictionary *attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor], NSKernAttributeName : @1};
    return [[NSAttributedString alloc] initWithString:buttonText attributes:attributes];
}

@end
