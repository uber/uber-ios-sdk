//
//  UBPriceDetail.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBProductPriceDetail.h"

#import "UBPriceDetailServiceFee.h"
#import "UBUtils.h"

@implementation UBProductPriceDetail

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBProductPriceDetail, distanceUnit) : @"distance_unit",
             @instanceKeypath(UBProductPriceDetail, currencyCode) : @"currency_code",
             @instanceKeypath(UBProductPriceDetail, minimum) : @"minimum",
             @instanceKeypath(UBProductPriceDetail, base) : @"base",
             @instanceKeypath(UBProductPriceDetail, costPerMinute) : @"cost_per_minute",
             @instanceKeypath(UBProductPriceDetail, costPerDistance) : @"cost_per_distance",
             @instanceKeypath(UBProductPriceDetail, cancellationFee) : @"cancellation_fee",
             @instanceKeypath(UBProductPriceDetail, serviceFees) : @"service_fees",
             };
}

+ (NSValueTransformer *)serviceFeesJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:UBPriceDetailServiceFee.class];
}

@end
