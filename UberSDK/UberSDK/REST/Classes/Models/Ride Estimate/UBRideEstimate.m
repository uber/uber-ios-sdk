//
//  UBRequestEstimate.m
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBRideEstimate.h"

#import "UBUtils.h"

@implementation UBRideEstimate

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBRideEstimate, price) : @"price",
              @instanceKeypath(UBRideEstimate, trip) : @"trip",
              @instanceKeypath(UBRideEstimate, pickupEstimate) : @"pickup_estimate"
              };
}

+ (NSValueTransformer *)priceJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:UBRideEstimatePrice.class];
}

+ (NSValueTransformer *)tripJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:UBRideEstimateTrip.class];
}

@end
