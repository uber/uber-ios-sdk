//
//  UBServiceFee.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBPriceDetailServiceFee.h"
#import "UBUtils.h"

@implementation UBPriceDetailServiceFee

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
            @instanceKeypath(UBPriceDetailServiceFee, name) : @"name",
            @instanceKeypath(UBPriceDetailServiceFee, fee) : @"fee",
            };
}

@end
