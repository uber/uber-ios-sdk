//
//  UBRideEstimatePrice.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBRideEstimatePrice.h"

#import "UBUtils.h"

@implementation UBRideEstimatePrice

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @instanceKeypath(UBRideEstimatePrice, surgeConfirmationURL) : @"surge_confirmation_href",
              @instanceKeypath(UBRideEstimatePrice, surgeConfirmationId) : @"surge_confirmation_id",
              @instanceKeypath(UBRideEstimatePrice, surgeMultiplier) : @"surge_multiplier",
              @instanceKeypath(UBRideEstimatePrice, highEstimate) : @"high_estimate",
              @instanceKeypath(UBRideEstimatePrice, lowEstimate) : @"low_estimate",
              @instanceKeypath(UBRideEstimatePrice, minimum) : @"minimum",
              @instanceKeypath(UBRideEstimatePrice, display) : @"display",
              @instanceKeypath(UBRideEstimatePrice, currencyCode) : @"currency_code",
              };
}

+ (NSValueTransformer *)surgeConfirmationURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
