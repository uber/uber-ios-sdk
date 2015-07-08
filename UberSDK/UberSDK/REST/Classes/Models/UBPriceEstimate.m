//
//  UBPriceEstimate.h
//  UberSDK
//
//  Copyright (c) 2015 Uber Technolgies, Inc. All rights reserved.
//

#import "UBPriceEstimate.h"

@implementation UBPriceEstimate

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"productId": @"product_id",
             @"currencyCode": @"currency_code",
             @"displayName": @"display_name",
             @"estimate": @"estimate",
             @"lowEstimate": @"low_estimate",
             @"highEstimate": @"high_estimate",
             @"surgeMultiplier": @"surge_multiplier",
             @"duration": @"duration",
             @"distance": @"distance"
             };
}

@end
