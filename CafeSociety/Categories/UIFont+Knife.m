//
//  UIFont+Knife.m
//  TheKnife
//
//  Created by Brian Drell on 10/25/14.
//  Copyright (c) 2014 The Knife App Co. All rights reserved.
//

#import "UIFont+Knife.h"

/*
 "Oxygen-Regular",
 "Oxygen-Bold",
 "Oxygen-Light"
 */

@implementation UIFont (Knife)

+ (UIFont *)kni_abrilFatFaceFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AbrilFatface-Regular" size:size];
}

+ (UIFont *)kni_oxygenRegularFontWithSize:(CGFloat)size
{
//    return [UIFont fontWithName:@"Oxygen-Regular" size:size];
    return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
}

+ (UIFont *)kni_oxygenBoldFontWithSize:(CGFloat)size
{
//    return [UIFont fontWithName:@"Oxygen-Bold" size:size];
    return [UIFont fontWithName:@"AvenirNext-Bold" size:size];
}

+ (UIFont *)kni_avenirNextDemiBoldFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:size];
}

+ (UIFont *)kni_oxygenLightFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Oxygen-Light" size:size];
}

@end
