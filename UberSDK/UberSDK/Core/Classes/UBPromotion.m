//
//  UBPromotion.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBPromotion.h"

#import "UBUtils.h"

@implementation UBPromotion

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBPromotion, displayText) : @"display_text",
             @instanceKeypath(UBPromotion, localizedValue) : @"localized_value",
             @instanceKeypath(UBPromotion, type) : @"type"
             };
}

@end
